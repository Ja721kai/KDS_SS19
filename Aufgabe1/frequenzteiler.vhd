
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY frequenzteiler IS
	GENERIC(RSTDEF:  std_logic := '0');
	PORT(rst:	IN  std_logic;
		  clk:	IN  std_logic;
		  strb:  OUT std_logic);  -- Ausgangssignal für mod-4-Zähler
END frequenzteiler;

ARCHITECTURE struktur OF frequenzteiler IS
	constant N: natural := 2**14;
	signal cnt: integer range 0 to N-1;
	
BEGIN
	process(rst, clk) IS
	begin
		if rst=RSTDEF then
			cnt <= 0;
			strb <= '0';
		elsif rising_edge(clk) then
			strb <= '0';
			if cnt=N-1 then
				cnt <= 0;
				strb <= '1';
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
END struktur;