
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF:  std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        en:    IN  std_logic;                       -- enable,          active high
        swrst: IN  std_logic;                       -- software reset,  active RSTDEF
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
        dp:    OUT std_logic;                       -- 1 decimal point output,                      active low
        seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS

  COMPONENT frequenzteiler IS
		GENERIC(RSTDEF:  std_logic);
		PORT(rst:	IN  std_logic;
			  clk:	IN  std_logic;
			  strb:	OUT std_logic);
	END COMPONENT;
	
	COMPONENT mod4zaehler IS
		GENERIC(RSTDEF:  std_logic);
		PORT(rst:	IN  std_logic;
			  swrst: IN  std_logic;
			  clk:	IN  std_logic;
			  strb:	IN  std_logic;
			  mod4:  OUT std_logic_vector(1 downto 0));
	END COMPONENT;
	
	  -- hier sind benutzerdefinierte Konstanten und Signale einzutragen
  signal t: std_logic;  -- für 1 aus 4 dpin multiplexer
  
  signal strb: std_logic;  -- Startsignal für mod4 Zähler
  
  signal mod4: std_logic_vector(1 downto 0);  -- mod4 Zähler
  
  signal seg_sel: std_logic_vector(3 downto 0);  -- für 1-aus-4-4Bit-Multiplexer & Input für 7-aus-4-Decoder
  

BEGIN -- en wird als '1' angenommen, siehe Portmap aufgabe1.vhd

   -- Modulo-2**14-Zaehler als Prozess
	 -- > siehe KDS1.pdf Folie 65 (Design-Muster) / Frequenz-Teiler Folie 66
	 u1:frequenzteiler
	 GENERIC MAP(RSTDEF => RSTDEF)
	 PORT MAP(rst	=> rst,
				 clk	=> clk,
				 strb => strb);
	
	
   -- Modulo-4-Zaehler als Prozess
	 -- > siehe KDS1.pdf Folie 65 (Design-Muster) 
	 u2:mod4zaehler
	 GENERIC MAP(RSTDEF => RSTDEF)
	 PORT MAP(rst	 => rst,
				 swrst => swrst,
				 clk	 => clk,
				 strb  => strb,
				 mod4  => mod4);


   -- 1-aus-4-Dekoder als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 52 (Entwurfsmuster)
	 with mod4 & rst select
		an <= "1110" when "000",
				"1101" when "010",
				"1011" when "100",
				"0111" when "110",
				"1111" when others;
		-- vielleicht lieber so implementieren: ???
		-- an <= "1111" when rst=RSTDEF;
		-- an <= "1111" when swrst=RSTDEF
				

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 51 (Entwurfsmuster)
	with mod4 select
		t  <= dpin(0) when "00",
				dpin(1) when "01",
				dpin(2) when "10",
				dpin(3) when others;
		dp <= not t;  -- da low active (buttons senden high signal)
	 
	 
   -- 1-aus-4-4Bit-Multiplexer als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 51 (Entwurfsmuster)
	 with mod4 select
		seg_sel <= data( 3 downto 0 ) when "00",  -- rechte Anzeige
					  data( 7 downto 4 ) when "01",  -- zweite von rechts
					  data(11 downto 8 ) when "10",  -- zweite von links
					  data(15 downto 12) when others;  -- linke Anzeige
					  
	
	-- 7-aus-4-Dekoder als selektierte Signalzuweisung
    -- > siehe KDS1.pdf Folie 52 (Entwurfsmuster)
	 with seg_sel select
		seg <= "0000001" when "0000",
				 "1001111" when "0001",
				 "0010010" when "0010",
				 "0000110" when "0011",
				 "1001100" when "0100",
				 "0100100" when "0101",
				 "0100000" when "0110",
				 "0001111" when "0111",
				 "0000000" when "1000",
				 "0000100" when "1001",
				 "0001000" when "1010",
				 "1100000" when "1011",
				 "0110001" when "1100",
				 "1000010" when "1101",
				 "0110000" when "1110",
				 "0111000" when others;
				 
END struktur;