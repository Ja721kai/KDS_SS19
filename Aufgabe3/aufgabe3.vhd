
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe3 IS
   PORT(rst:  IN  std_logic;                     -- (BTN3) User Reset
        clk:  IN  std_logic;                     -- 50 MHz crystal oscillator clock source
        BTN0: IN  std_logic;                     -- start
        sw:   IN  std_logic_vector(7 DOWNTO 0);  -- 8 slide switches: SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
        an:   OUT std_logic_vector(3 DOWNTO 0);  -- 4 digit enable (anode control) signals (active low)
        seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 FPGA connections to seven-segment display (active low)
        dp:   OUT std_logic;                     -- 1 FPGA connection to digit doint (active low)
        LD0:  OUT std_logic);                    -- Done LED, 1 if done
END aufgabe3;

ARCHITECTURE structure OF aufgabe3 IS
   CONSTANT RSTDEF: std_logic := '1';

   COMPONENT core
      GENERIC(RSTDEF: std_logic);
      PORT(rst:   IN  std_logic;                      -- reset,          RSTDEF active
           clk:   IN  std_logic;                      -- clock,          rising edge
           swrst: IN  std_logic;                      -- software reset, RSTDEF active
           strt:  IN  std_logic;                      -- start,          high active
           sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- length counter, input
           res:   OUT std_logic_vector(43 DOWNTO 0);  -- result
           done:  OUT std_logic);                     -- done,           high active
   END COMPONENT;

   COMPONENT sync_module IS
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

   CONSTANT swrst: std_logic := NOT RSTDEF;

   SIGNAL strt:   std_logic;
   SIGNAL res:    std_logic_vector(43 DOWNTO 0);
   
BEGIN

   u1: sync_module
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            swrst => swrst,
            BTN0  => BTN0,
            BTN1  => '0',
            BTN2  => '0',
            load  => strt,
            dec   => OPEN,
            inc   => OPEN);
               
   u2: core
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            swrst => swrst,
            strt  => strt,
            sw    => sw,
            res   => res,
            done  => LD0);

   u3: hex4x7seg
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => '1',
            swrst => swrst,
            data  => res(15 DOWNTO 0),
            dpin  => "0000",
            an    => an,
            dp    => dp,
            seg   => seg);
   
END structure;
