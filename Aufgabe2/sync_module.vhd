
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_module IS
   GENERIC(RSTDEF: std_logic := '1');
   PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN0:  IN  std_logic;  -- push button -> load
        BTN1:  IN  std_logic;  -- push button -> dec
        BTN2:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
END sync_module;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_module implementiert werden.
--
ARCHITECTURE struktur OF sync_module IS

	COMPONENT sync_buffer IS
		GENERIC(RSTDEF:  std_logic);
		PORT( 	rst:    IN  std_logic;  -- reset, RSTDEF active
				clk:    IN  std_logic;  -- clock, rising edge
				en:     IN  std_logic;  -- enable, high active
				swrst:  IN  std_logic;  -- software reset, RSTDEF active
				din:    IN  std_logic;  -- data bit, input
				dout:   OUT std_logic;  -- data bit, output
				redge:  OUT std_logic;  -- rising  edge on din detected
				fedge:  OUT std_logic); -- falling edge on din detected
	END COMPONENT;
	
	SIGNAL en: std_logic;
	signal counter: integer range 0 to 2**15-1;

BEGIN
	
	-- Frequenzteiler 2**15
	process (rst, swrst, clk) is
	begin
		if rst=RSTDEF then
			counter <= 0;
			en <= '0';
		elsif rising_edge(clk) then	
			counter <= (counter+1)mod 2**15;
			en <= '0';
			if counter = 0 then
				en <= '1';	
			end if;
			if swrst=RSTDEF then
				counter <= 0;
				en <= '0';
			end if;
		end if;
	end process;
	
	sb0: sync_buffer
	GENERIC MAP(RSTDEF => RSTDEF)
	PORT MAP(rst   => rst,
			 clk   => clk,
			 swrst => swrst,
			 en    => en,
			 din   => BTN0,
			 dout  => OPEN,
			 redge => load,
			 fedge => OPEN);
	
	sb1: sync_buffer
	GENERIC MAP(RSTDEF => RSTDEF)
	PORT MAP(rst   => rst,
			 clk   => clk,
			 swrst => swrst,
			 en    => en,
			 din   => BTN1,
			 dout  => OPEN,
			 redge => dec,
			 fedge => OPEN);
				
	sb2: sync_buffer
	GENERIC MAP(RSTDEF => RSTDEF)
	PORT MAP(rst   => rst,
			 clk   => clk,
			 swrst => swrst,
			 en    => en,
			 din   => BTN2,
			 dout  => OPEN,
			 redge => inc,
			 fedge => OPEN);
				
			
				
			
END struktur;