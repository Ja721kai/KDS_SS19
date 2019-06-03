
LIBRARY ieee, unisim;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE unisim.VComponents.ALL;
USE ieee.std_logic_unsigned.ALL;

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


ARCHITECTURE structure OF core IS

	COMPONENT ram_block IS
    PORT (addra: IN  std_logic_VECTOR(9 DOWNTO 0);
         addrb:  IN  std_logic_VECTOR(9 DOWNTO 0);
         clka:   IN  std_logic;
         clkb:   IN  std_logic;
         douta:  OUT std_logic_VECTOR(15 DOWNTO 0);
         doutb:  OUT std_logic_VECTOR(15 DOWNTO 0);
         ena:    IN  std_logic;
         enb:    IN  std_logic);
	END COMPONENT;
	
	COMPONENT MULT18X18
		PORT ( P : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
				 A : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
				 B : IN STD_LOGIC_VECTOR (17 DOWNTO 0));
	END COMPONENT;
	
	type TState IS (SPIN, S1, S2, S3, NOP, FIN);
	SIGNAL state: TState := SPIN;
	
	SIGNAL addra: std_logic_VECTOR(9 DOWNTO 0);
   SIGNAL addrb: std_logic_VECTOR(9 DOWNTO 0);
	SIGNAL douta: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL doutb: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL extdouta: std_logic_VECTOR(17 DOWNTO 0);
	SIGNAL extdoutb: std_logic_VECTOR(17 DOWNTO 0);
   SIGNAL en_ram:   std_logic;
	SIGNAL en_add: std_logic;	
	
	SIGNAL multres: std_logic_vector(35 DOWNTO 0);
	SIGNAL add_res: std_logic_vector(43 DOWNTO 0);
	SIGNAL counter: std_logic_vector(7 DOWNTO 0);
	

BEGIN

	rb: ram_block
	PORT MAP(
	  douta 	=> douta,
	  doutb	=> doutb,
	  addra	=> addra,
	  addrb	=> addrb,
	  clka	=> clk,
	  clkb	=> clk,
	  ena		=> en_ram,
	  enb		=> en_ram
	);
	extdouta <= SXT(douta,18);
	extdoutb <= SXT(doutb,18);
	
	mult: MULT18X18
	PORT MAP(
		A => extdouta,
		B => extdoutb,
		P => multres
	);
			 
	steuerwerk: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			state <= SPIN;
			en_ram <= '0';
			done <= '0';
			en_add <= '0';
			res <= (others => '0');
		elsif rising_edge(clk) then
				case state is
					when SPIN =>
						en_ram <= '0';
						en_add <= '0';
						counter <= (others => '0');
						if strt = '1' then
							res <= (others => '0');
							if sw /= "00000000" then
								done <= '0';
								addra <= (others => '0');
								addrb <= "0100000000";
								en_ram <= '1';
								counter <= counter + '1';
								if sw = "00000001" then
									state <= S1;
								else
									state <= S2;
								end if;
							else
								state <= NOP;
							end if;
						end if;
					when S2 =>
						addra(7 DOWNTO 0) <= counter;
						addrb(7 DOWNTO 0) <= counter;
						counter <= counter + '1';
						en_add <= '1';
						if sw = "00000010" then
							state <= S1;
						else
							state <= S3;
						end if;
					when S3 =>
						addra(7 DOWNTO 0) <= counter;
						addrb(7 DOWNTO 0) <= counter;
						counter <= counter + '1';
						if counter = sw then
							en_ram <= '0';
							state <= NOP;
						end if;
					when NOP =>
						state <= FIN;
					when S1 =>
						en_ram <= '0';
						en_add <= '1';
						state <= NOP;
					when FIN =>
						en_add <= '0';
						done <= '1';
						res <= add_res;
						state <= SPIN;
				end case;
		end if;
	END PROCESS;
	
	
	addierer_akk: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			add_res <= (others => '0');
		elsif rising_edge(clk) then
			if en_add = '1' then
				add_res <= add_res + SXT(multres, 44);
			else
				add_res <= (others => '0');
			end if;
		end if;
	END PROCESS;
		
END structure;
