
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY mod4zaehler IS
	GENERIC(RSTDEF:  std_logic := '0');
	PORT(rst:	IN  std_logic;
		  swrst: IN  std_logic;
		  clk:	IN  std_logic;
		  strb:  IN  std_logic;
		  mod4:   OUT std_logic_vector(1 downto 0));  -- Ausgangssignal für mod-4-Zähler
END mod4zaehler;

ARCHITECTURE struktur OF mod4zaehler IS
	signal mod4in: std_logic_vector(1 downto 0);

BEGIN

	process (rst, swrst, clk) begin
		if rst=RSTDEF then
			mod4in <= "00";
		elsif rising_edge(clk) then
			if mod4in="11" then
				if strb='1' then
					mod4in <= "00";
				end if;
			else
				mod4in <= mod4in + strb;
			end if;
			if swrst=RSTDEF then
				mod4in <= "00";
			end if;
		end if;
		mod4 <= mod4in;
	 end process;
END struktur;