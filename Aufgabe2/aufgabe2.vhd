
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe2 IS
   PORT(rst:  IN  std_logic;                     -- (BTN3) User Reset
        clk:  IN  std_logic;                     -- 50 MHz crystal oscillator clock source
        BTN0: IN  std_logic;                     -- load
        BTN1: IN  std_logic;                     -- decrement
        BTN2: IN  std_logic;                     -- increment
        sw:   IN  std_logic_vector(7 DOWNTO 0);  -- 8 slide switches: SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
        an:   OUT std_logic_vector(3 DOWNTO 0);  -- 4 digit enable (anode control) signals (active low)
        seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 FPGA connections to seven-segment display (active low)
        dp:   OUT std_logic;                     -- 1 FPGA connection to digit doint (active low)
        LD0:  OUT std_logic);                    -- 1 FPGA connection to LD0 (carry output)
END aufgabe2;

ARCHITECTURE structure OF aufgabe2 IS
   CONSTANT RSTDEF: std_logic := '1';
   CONSTANT CNTLEN: natural := 16;

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

   COMPONENT std_counter IS
      GENERIC(RSTDEF: std_logic;
              CNTLEN: natural);
      PORT(rst:   IN  std_logic;  -- reset,           RSTDEF active
           clk:   IN  std_logic;  -- clock,           rising edge
           en:    IN  std_logic;  -- enable,          high active
           inc:   IN  std_logic;  -- increment,       high active
           dec:   IN  std_logic;  -- decrement,       high active
           load:  IN  std_logic;  -- load value,      high active
           swrst: IN  std_logic;  -- software reset,  RSTDEF active
           cout:  OUT std_logic;  -- carry,           high active
           din:   IN  std_logic_vector(CNTLEN-1 DOWNTO 0);
           dout:  OUT std_logic_vector(CNTLEN-1 DOWNTO 0));
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

   SIGNAL swrst:  std_logic;
   SIGNAL inc:    std_logic;
   SIGNAL dec:    std_logic;
   SIGNAL load:   std_logic;
   SIGNAL cnt:    std_logic_vector(CNTLEN-1 DOWNTO 0);
   SIGNAL din:    std_logic_vector(CNTLEN-1 DOWNTO 0);

BEGIN

   swrst <= NOT RSTDEF;

   din <= "00000000" & sw;

   u1: sync_module
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            swrst => swrst,
            BTN0  => BTN0,
            BTN1  => BTN1,
            BTN2  => BTN2,
            load  => load,
            dec   => dec,
            inc   => inc);

   u2: std_counter
   GENERIC MAP(RSTDEF => RSTDEF,
               CNTLEN => CNTLEN)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => '1',
            inc   => inc,
            dec   => dec,
            load  => load,
            swrst => swrst,
            cout  => LD0,
            din   => din,
            dout  => cnt);

   u3: hex4x7seg
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => '1',
            swrst => swrst,
            data  => cnt,
            dpin  => "0000",
            an    => an,
            dp    => dp,
            seg   => seg);

END structure;
