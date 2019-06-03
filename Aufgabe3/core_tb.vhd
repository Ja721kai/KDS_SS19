
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY core_tb IS
   -- empty
END core_tb;

ARCHITECTURE verhalten OF core_tb IS
   CONSTANT RSTDEF: std_ulogic := '1';
   CONSTANT tpd: time := 20 ns; -- 1/50 MHz

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

   SIGNAL rst:    std_logic := RSTDEF;
   SIGNAL clk:    std_logic := '0';
   SIGNAL hlt:    std_logic := '0';
   SIGNAL swrst:  std_logic := not RSTDEF;

   SIGNAL strt:   std_logic := '0';
   SIGNAL done:   std_logic := '0';
   SIGNAL cnt:    natural   := 0;
   SIGNAL sw:     std_logic_vector( 7 DOWNTO 0) := (OTHERS => '0');
   SIGNAL res:    std_logic_vector(43 DOWNTO 0) := (OTHERS => '0');
BEGIN

   rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
   clk <= '1' AFTER tpd/2 WHEN clk='0' AND hlt='0' ELSE '0' AFTER tpd/2;

   u1: core
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            swrst => swrst,
            strt  => strt,
            sw    => sw,
            res   => res,
            done  => done);

   main: PROCESS
      TYPE frame IS RECORD
         sw   : std_logic_vector(0 TO  7);
         res  : std_logic_vector(1 TO 44);
         msg  : string(1 TO 6);
      END RECORD;

      TYPE frames IS ARRAY(natural RANGE <>) OF frame;
      CONSTANT test: frames := (
         ("00000000", X"00000000000", "test 1"),
         ("00000001", X"FFFFFFFFEE1", "test 2"),
         ("00000010", X"FFFFFFFE8D6", "test 3"),
         ("00001010", X"000000002C9", "test 4"),
         ("00111000", X"FFFFFFFF602", "test 5"),
         ("01111111", X"00000007D4E", "test 6"),
         ("11111111", X"00000000096", "test 7")
      );

      PROCEDURE clock (n: natural) IS
      BEGIN
         FOR i IN 1 TO n LOOP
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
      END PROCEDURE;
   
      PROCEDURE step(i: natural) IS
         VARIABLE cnt: natural;
      BEGIN
         REPORT test(i).msg SEVERITY note;
         sw   <= test(i).sw;
         strt <= '1';
         cnt  := 0;
         clock(1);
         strt <= '0';
         cnt  := cnt + 1;
         clock(1);
         WHILE (done='0') LOOP
            cnt := cnt + 1;
            clock(1);
         END LOOP;
         sw <= (OTHERS => '0');
         verhalten.cnt <= cnt;
         ASSERT res=test(i).res REPORT "wrong result" SEVERITY error;
      END PROCEDURE;

   BEGIN
      hlt  <= '0';
      WAIT UNTIL clk'EVENT AND clk='1' AND rst=(NOT RSTDEF);

      FOR i IN test'RANGE LOOP
         step(i); 
         clock(10);
      END LOOP;
      REPORT "test done..." SEVERITY note;
      
      hlt <= '1';
      WAIT;
   END PROCESS;

END verhalten;
