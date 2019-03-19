LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY system IS
   PORT(op1:  IN  std_logic_vector(3 DOWNTO 0); -- 1. operand
        op2:  IN  std_logic_vector(3 DOWNTO 0); -- 2. operand
        sum:  OUT std_logic_vector(3 DOWNTO 0); -- result
        cout: OUT std_logic);                   -- carry output
END system;

ARCHITECTURE structure OF system IS
   CONSTANT N: natural := 4;
   
   COMPONENT full_adder_N
      GENERIC(N: natural);
      PORT(cin:  IN  std_logic; -- carry input
           op1:  IN  std_logic_vector(N-1 DOWNTO 0); -- 1. operand
           op2:  IN  std_logic_vector(N-1 DOWNTO 0); -- 2. operand
           sum:  OUT std_logic_vector(N-1 DOWNTO 0); -- result
           cout: OUT std_logic -- carry output
      );
   END COMPONENT;
   
BEGIN
    
   u1: full_adder_N
   GENERIC MAP(N => N)
   PORT MAP(cin  => '0',
            op1  => op1,
            op2  => op2,
            sum  => sum,
            cout => cout);
           
END structure;