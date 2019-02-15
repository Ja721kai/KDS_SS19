
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
  -- hier sind benutzerdefinierte Konstanten und Signale einzutragen
  signal t: std_logic;
  signal mod4: std_logic_vector(1 DOWNTO 0);

BEGIN

   -- Modulo-2**14-Zaehler als Prozess
	 -- > siehe KDS1.pdf Folie 65 (Design-Muster)  / Frequenz-Teiler??
   
	
   -- Modulo-4-Zaehler als Prozess
	 -- > siehe KDS1.pdf Folie 65 (Design-Muster)


   -- 1-aus-4-Dekoder als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 52 (Entwurfsmuster)


   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 51 (Entwurfsmuster)
	with mod4 select
		t <=  dpin(0) when "00",
				dpin(1) when "01",
				dpin(2) when others; -- da dpin(2) und dpin(3) identisch
		dp <= not t; 
	 
	 
   -- 7-aus-4-Dekoder als selektierte Signalzuweisung
    -- > siehe KDS1.pdf Folie 52 (Entwurfsmuster)
	
   
   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung
	 -- > siehe KDS1.pdf Folie 51 (Entwurfsmuster)



-- Frequenzteiler? Je nachdem wo benötigt oder schon vorhanden: siehe KDS1.pdf Folie 66 (Design-Muster)
END struktur;