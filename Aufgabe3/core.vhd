
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY core IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                      -- reset,          RSTDEF active
        clk:   IN  std_logic;                      -- clock,          rising edge
        swrst: IN  std_logic;                      -- software reset, RSTDEF active
        strt:  IN  std_logic;                      -- start,          high active
        sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- length counter, input
        res:   OUT std_logic_vector(43 DOWNTO 0);  -- result
        done:  OUT std_logic);                     -- done,           high active
END core;
