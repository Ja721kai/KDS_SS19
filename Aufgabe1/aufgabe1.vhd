
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe1 IS
   PORT(rst:  IN  std_logic;                     -- User Reset (BTN3)
        clk:  IN  std_logic;                     -- 50 MHz crystal oscillator clock source
        btn0: IN  std_logic;                     -- user push button BTN0
        btn1: IN  std_logic;                     -- user push button BTN1
        sw:   IN  std_logic_vector(7 DOWNTO 0);  -- 8 slide switches: SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
        an:   OUT std_logic_vector(3 DOWNTO 0);  -- 4 digit enable (anode control) signals (active low)
        seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 FPGA connections to seven-segment display (active low)
        dp:   OUT std_logic);                    -- 1 FPGA connection to digit doint (active low)
END aufgabe1;

ARCHITECTURE struktur OF aufgabe1 IS
   CONSTANT RSTDEF: std_logic := '1';
   CONSTANT swrst:  std_logic := NOT RSTDEF;

   COMPONENT hex4x7seg IS
      GENERIC(RSTDEF:  std_logic);
      PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
           clk:   IN  std_logic;                       -- clock,           rising edge
           en:    IN  std_logic;                       -- enable,          active high
           swrst: IN  std_logic;                       -- software reset,  active RSTDEF
           data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
           dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
           an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
           dp:    OUT std_logic;                       -- decimal point output,                        active low
           seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
   END COMPONENT;

   SIGNAL data: std_logic_vector(15 DOWNTO 0);
   SIGNAL dpin: std_logic_vector( 3 DOWNTO 0);
BEGIN
  
   dpin <= btn1 & btn1 & btn0 & btn0;
   data <= sw & sw;  
    
   u1: hex4x7seg
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => '1',
            swrst => swrst,
            data  => data,
            dpin  => dpin,
            an    => an,
            dp    => dp,
            seg   => seg);

END struktur;
