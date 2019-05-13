LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sync_module_tb IS
END sync_module_tb;

ARCHITECTURE verhalten OF sync_module_tb IS
   CONSTANT RSTDEF: std_logic := '1';
   CONSTANT FRQ:    natural   := 50e6;
   CONSTANT tcyc:   time      := 1 sec / FRQ;

   COMPONENT sync_module
   GENERIC(RSTDEF: std_logic);
   PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN0:  IN  std_logic;  -- push button -> load
        BTN1:  IN  std_logic;  -- push button -> dec
        BTN2:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
   END COMPONENT;

   SIGNAL rst:   std_logic := RSTDEF;
   SIGNAL clk:   std_logic := '0';
   SIGNAL swrst: std_logic := NOT RSTDEF;
   SIGNAL BTN0, BTN1, BTN2: std_logic := '0';
   SIGNAL load:  std_logic := '0';
   SIGNAL dec:   std_logic := '0';
   SIGNAL inc:   std_logic := '0';
   
BEGIN

   rst <= RSTDEF, NOT RSTDEF AFTER 1 us;
   clk <= NOT clk AFTER tcyc/2;
   
   BTN1 <= '0', '1' AFTER 2 us, '0' AFTER 3 us, '1' AFTER 4 us;
   
   dut: sync_module
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst => rst,
            clk => clk,
            swrst => swrst,
            BTN0 => BTN0,
            BTN1 => BTN1,
            BTN2 => BTN2,
            load => load,
            dec => dec,
            inc => inc);
	
END verhalten;