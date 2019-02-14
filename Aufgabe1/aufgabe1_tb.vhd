
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe1_test IS
   -- empty
END aufgabe1_test;

ARCHITECTURE test OF aufgabe1_test IS
   CONSTANT RSTDEF: std_ulogic := '1';
   CONSTANT tpd: time := 20 ns; -- 1/50 MHz

   COMPONENT aufgabe1 IS
      PORT(rst:  IN  std_logic;                     -- User Reset (BTN3)
           clk:  IN  std_logic;                     -- 50 MHz crystal oscillator clock source
           btn0: IN  std_logic;                     -- push button BTN0
           btn1: IN  std_logic;                     -- push button BTN1
           sw:   IN  std_logic_vector(7 DOWNTO 0);  -- 8 slide switches: SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
           an:   OUT std_logic_vector(3 DOWNTO 0);  -- 4 digit enable (anode control) signals (active low)
           seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 FPGA connections to seven-segment display (active low)
           dp:   OUT std_logic);                    -- 1 FPGA connection to digit doint (active low)
   END COMPONENT;

   SIGNAL rst:  std_logic := RSTDEF;
   SIGNAL clk:  std_logic := '0';
   SIGNAL hlt:  std_logic := '0';

   SIGNAL sw:   std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL an:   std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
   SIGNAL seg:  std_logic_vector(7 DOWNTO 1) := (OTHERS => '0');
   SIGNAL dp:   std_logic := '0';
   SIGNAL btn0: std_logic := '0';
   SIGNAL btn1: std_logic := '0';

BEGIN
   rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
   clk <= clk WHEN hlt='1' ELSE '1' AFTER tpd/2 WHEN clk='0' ELSE '0' AFTER tpd/2;

   u1: aufgabe1
   PORT MAP(rst  => rst,
            clk  => clk,
            btn0 => btn0,
            btn1 => btn1,
            sw   => sw,
            an   => an,
            seg  => seg,
            dp   => dp);

   main: PROCESS

      PROCEDURE test1 IS
      BEGIN
         ASSERT FALSE REPORT "test1..." SEVERITY note;
         WAIT UNTIL clk'EVENT AND clk='1' AND an(0)='0';
         WHILE an(0)='0' LOOP
            ASSERT an="1110" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND an(1)='0';
         WHILE an(1)='0' LOOP
            ASSERT an="1101" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND an(2)='0';
         WHILE an(2)='0' LOOP
            ASSERT an="1011" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND an(3)='0';
         WHILE an(3)='0' LOOP
            ASSERT an="0111" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
      END PROCEDURE;

      PROCEDURE test2 IS
         TYPE frame IS RECORD
            an   : std_logic_vector(3 DOWNTO 0);
            btn  : std_logic_vector(1 DOWNTO 0);
            dp   : std_logic;
         END RECORD;
         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
         CONSTANT testtab: frames := (
            ("1110", "00", '1'),
            ("1101", "00", '1'),
            ("1011", "00", '1'),
            ("0111", "00", '1'),

            ("1110", "00", '1'),
            ("1110", "01", '0'),
            ("1110", "10", '1'),
            ("1110", "11", '0'),
            ("1110", "00", '1'),

            ("1101", "00", '1'),
            ("1101", "01", '0'),
            ("1101", "10", '1'),
            ("1101", "11", '0'),
            ("1101", "00", '1'),

            ("1011", "00", '1'),
            ("1011", "01", '1'),
            ("1011", "10", '0'),
            ("1011", "11", '0'),
            ("1011", "00", '1'),

            ("0111", "00", '1'),
            ("0111", "01", '1'),
            ("0111", "10", '0'),
            ("0111", "11", '0'),
            ("0111", "00", '1'),

            ("1110", "01", '0'),
            ("1101", "01", '0'),
            ("1011", "01", '1'),
            ("0111", "01", '1'),

            ("1110", "10", '1'),
            ("1101", "10", '1'),
            ("1011", "10", '0'),
            ("0111", "10", '0'),

            ("1110", "11", '0'),
            ("1101", "11", '0'),
            ("1011", "11", '0'),
            ("0111", "11", '0')

         );
         PROCEDURE step (i: natural) IS
         BEGIN
            WAIT UNTIL clk'EVENT AND clk='1' AND an=testtab(i).an;
            btn1 <= testtab(i).btn(1);
            btn0 <= testtab(i).btn(0);
            WAIT UNTIL clk'EVENT AND clk='1';
            ASSERT dp=testtab(i).dp REPORT "wrong decimal point" SEVERITY error;
         END PROCEDURE;
      BEGIN
         ASSERT FALSE REPORT "test2..." SEVERITY note;
         FOR i IN testtab'RANGE LOOP
            step(i);
         END LOOP;
      END PROCEDURE;

      PROCEDURE test3 IS
         TYPE frame IS RECORD
            an   : std_logic_vector(3 DOWNTO 0);
            sw   : std_logic_vector(7 DOWNTO 0);
            seg  : std_logic_vector(7 DOWNTO 1);
         END RECORD;
         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
         CONSTANT testtab: frames := (
            ("0111", "11001101", "0110001" ),
            ("0111", "11011110", "1000010" ),
            ("0111", "11101111", "0110000" ),
            ("0111", "11110000", "0111000" ),

            ("1011", "11001101", "1000010" ),
            ("1011", "11011110", "0110000" ),
            ("1011", "11101111", "0111000" ),
            ("1011", "11110000", "0000001" ),

            ("1101", "11001101", "0110001" ),
            ("1101", "11011110", "1000010" ),
            ("1101", "11101111", "0110000" ),
            ("1101", "11110000", "0111000" ),

            ("1110", "11001101", "1000010" ),
            ("1110", "11011110", "0110000" ),
            ("1110", "11101111", "0111000" ),
            ("1110", "11110000", "0000001" )
         );

         PROCEDURE step (i: natural) IS
         BEGIN
            WAIT UNTIL clk'EVENT AND clk='1' AND an=testtab(i).an;
            sw <= testtab(i).sw;
            WAIT UNTIL clk'EVENT AND clk='1';
            ASSERT seg=testtab(i).seg REPORT "wrong segment" SEVERITY error;
         END PROCEDURE;
      BEGIN
         ASSERT FALSE REPORT "test3..." SEVERITY note;
         FOR i IN testtab'RANGE LOOP
            step(i);
         END LOOP;
      END PROCEDURE;

      PROCEDURE test4 IS
         TYPE frame IS RECORD
            an   : std_logic_vector(3 DOWNTO 0);
            sw   : std_logic_vector(7 DOWNTO 0);
            seg  : std_logic_vector(7 DOWNTO 1);
         END RECORD;
         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
         CONSTANT testtab: frames := (
            ("0111", "00000001", "0000001"),
            ("1011", "00000001", "1001111"),
            ("1101", "00000001", "0000001"),
            ("1110", "00000001", "1001111"),

            ("0111", "00010010", "1001111"),
            ("1011", "00010010", "0010010"),
            ("1101", "00010010", "1001111"),
            ("1110", "00010010", "0010010"),

            ("0111", "00100011", "0010010"),
            ("1011", "00100011", "0000110"),
            ("1101", "00100011", "0010010"),
            ("1110", "00100011", "0000110"),

            ("0111", "00110100", "0000110"),
            ("1011", "00110100", "1001100"),
            ("1101", "00110100", "0000110"),
            ("1110", "00110100", "1001100"),

            ("0111", "01000101", "1001100"),
            ("1011", "01000101", "0100100"),
            ("1101", "01000101", "1001100"),
            ("1110", "01000101", "0100100"),

            ("0111", "01010110", "0100100"),
            ("1011", "01010110", "0100000"),
            ("1101", "01010110", "0100100"),
            ("1110", "01010110", "0100000"),

            ("0111", "01100111", "0100000"),
            ("1011", "01100111", "0001111"),
            ("1101", "01100111", "0100000"),
            ("1110", "01100111", "0001111"),

            ("0111", "01111000", "0001111"),
            ("1011", "01111000", "0000000"),
            ("1101", "01111000", "0001111"),
            ("1110", "01111000", "0000000"),

            ("0111", "10001001", "0000000"),
            ("1011", "10001001", "0000100"),
            ("1101", "10001001", "0000000"),
            ("1110", "10001001", "0000100"),

            ("0111", "10011010", "0000100"),
            ("1011", "10011010", "0001000"),
            ("1101", "10011010", "0000100"),
            ("1110", "10011010", "0001000"),

            ("0111", "10101011", "0001000"),
            ("1011", "10101011", "1100000"),
            ("1101", "10101011", "0001000"),
            ("1110", "10101011", "1100000"),

            ("0111", "10111100", "1100000"),
            ("1011", "10111100", "0110001"),
            ("1101", "10111100", "1100000"),
            ("1110", "10111100", "0110001")
         );

         PROCEDURE step (i: natural) IS
         BEGIN
            WAIT UNTIL clk'EVENT AND clk='1' AND an=testtab(i).an;
            sw <= testtab(i).sw;
            WAIT UNTIL clk'EVENT AND clk='1';
            ASSERT seg=testtab(i).seg REPORT "wrong segment" SEVERITY error;
         END PROCEDURE;
      BEGIN
         ASSERT FALSE REPORT "test4..." SEVERITY note;
         FOR i IN testtab'RANGE LOOP
            step(i);
         END LOOP;
      END PROCEDURE;

   BEGIN
      WAIT UNTIL clk'EVENT AND clk='1' AND rst=(NOT RSTDEF);

      test1;
      test2;
      test3;
      test4;

      ASSERT FALSE REPORT "done" SEVERITY note;

      hlt <= '1';
      WAIT;
   END PROCESS;

END test;