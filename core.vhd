
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
        rdy :  OUT std_logic;                      -- ready,          high active
		  sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- address input
		  dout:  OUT std_logic_vector(15 DOWNTO 0));  -- result output
END core;


ARCHITECTURE structure OF core IS

	COMPONENT ram_block IS
    PORT (addra: IN  std_logic_VECTOR(9 DOWNTO 0);
         addrb: IN  std_logic_VECTOR(9 DOWNTO 0);
         clka:  IN  std_logic;
         clkb:  IN  std_logic;
         dina:  IN  std_logic_VECTOR(15 downto 0);
         douta: OUT std_logic_VECTOR(15 DOWNTO 0);
         doutb: OUT std_logic_VECTOR(15 DOWNTO 0);
         ena:   IN  std_logic;
         enb:   IN  std_logic;
         wea:   IN  std_logic);
	END COMPONENT;
	
	COMPONENT rom_block IS
    PORT (addra: IN  std_logic_VECTOR(9 DOWNTO 0);
         addrb:  IN  std_logic_VECTOR(9 DOWNTO 0);
         clka:   IN  std_logic;
         clkb:   IN  std_logic;
         douta:  OUT std_logic_VECTOR(15 DOWNTO 0);
         doutb:  OUT std_logic_VECTOR(15 DOWNTO 0);
         ena:    IN  std_logic;
         enb:    IN  std_logic);
	END COMPONENT;
	
	--xapp463 entnommene Komponente
	COMPONENT MULT18X18
		PORT ( P : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
				 A : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
				 B : IN STD_LOGIC_VECTOR (17 DOWNTO 0));
	END COMPONENT;
	
	type TState IS (SPIN, INCR, NOP, FIN);
	SIGNAL stwrk_state: TState := SPIN;
	SIGNAL lp_state: TState := SPIN;
	
	SIGNAL addra_ram: std_logic_VECTOR(9 DOWNTO 0);
   SIGNAL addrb_ram: std_logic_VECTOR(9 DOWNTO 0);
	SIGNAL douta_ram: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL doutb_ram: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL dina_ram:  std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL extdouta_ram: std_logic_VECTOR(17 DOWNTO 0);
	SIGNAL extdoutb_ram: std_logic_VECTOR(17 DOWNTO 0);
   SIGNAL en_ram:   std_logic;
	SIGNAL en_add:   std_logic;	
	SIGNAL en_write: std_logic;
	
	 ------------------------
	SIGNAL addra_rom: std_logic_VECTOR(9 DOWNTO 0);
   SIGNAL addrb_rom: std_logic_VECTOR(9 DOWNTO 0);
	SIGNAL douta_rom: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL doutb_rom: std_logic_VECTOR(15 DOWNTO 0);
	SIGNAL extdouta_rom: std_logic_VECTOR(17 DOWNTO 0);
	SIGNAL extdoutb_rom: std_logic_VECTOR(17 DOWNTO 0);
   SIGNAL en_rom:   std_logic;
	 ------------------------
	 
	SIGNAL res: std_logic_vector(43 DOWNTO 0);
	SIGNAL multres: std_logic_vector(35 DOWNTO 0);  -- 36 bits da 18 * 18 bits
	SIGNAL add_res: std_logic_vector(43 DOWNTO 0);
	SIGNAL counter_ram: std_logic_vector(9 DOWNTO 0);
	SIGNAL counter_rom_a: std_logic_vector(9 DOWNTO 0);
	SIGNAL counter_rom_b: std_logic_vector(9 DOWNTO 0);
	SIGNAL start: std_logic;
	SIGNAL done: std_logic;
	constant N: natural := 16;
	
	

BEGIN

	rb: ram_block
	PORT MAP(
	  douta 	=> douta_ram,
	  doutb	=> doutb_ram,
	  dina	=> res(15 DOWNTO 0),
	  addra	=> counter_ram,
	  addrb	=> addrb_ram,
	  clka	=> clk,
	  clkb	=> clk,
	  ena		=> en_ram,
	  enb		=> en_ram,
	  wea		=> en_write
	);
	
	rb2: rom_block
	PORT MAP(
	  douta 	=> douta_rom,
	  doutb	=> doutb_rom,
	  addra	=> addra_rom,
	  addrb	=> addrb_rom,
	  clka	=> clk,
	  clkb	=> clk,
	  ena		=> en_rom,
	  enb		=> en_rom
	);
	
	-- Vectorgröße erhöhen
	-- rom
	extdouta_rom <= SXT(douta_rom,18);
	extdoutb_rom <= SXT(doutb_rom,18);
	-- ram
	extdouta_ram <= SXT(douta_ram,18);
	extdoutb_ram <= SXT(doutb_ram,18);
	
	--xapp463 entnommen
	mult: MULT18X18
	PORT MAP(
		A => extdouta_rom,
		B => extdoutb_rom,
		P => multres
	);
	
	
	outerloop: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			start <= '0';
			rdy <= '0';
			en_write <= '0';
		elsif rising_edge(clk) then
			case lp_state is
				when SPIN =>
					en_write <= '0';
					if strt = '1' then
						counter_ram <= (others => '0');			-- ergebnismatrix zähler		
						counter_rom_a <= (others => '0');     -- SINGLE PORT ROM A
						counter_rom_b <= "0100000000";      -- SINGLE PORT ROM B
						start <= '1';
						lp_state <= NOP;
					end if;
					
				when INCR =>
				
					en_write <= '0';
					if counter_rom_b(7 DOWNTO 0) + '1' = N then  -- Matrix B letzte Spalte?
						counter_rom_b <= (others => '0');
						if counter_rom_a + '1' = N then  -- 256 bereits ausgerechnet
							counter_ram <= std_logic_vector(unsigned(counter_rom_a) * N + unsigned(counter_rom_b));
							en_write <= '1';
							rdy <= '1';
							lp_state <= SPIN;
						else										
							counter_rom_a <= counter_rom_a + '1';  -- nächste Zeile in Matrix A
							start <= '1';
							lp_state <= FIN;
						end if;
				   else
						counter_rom_b <= counter_rom_b + '1';
						start <= '1';
						lp_state <= FIN;
					end if;
				
				when NOP =>
					start <= '0';
					if done = '1' then
						counter_ram <= std_logic_vector(unsigned(counter_rom_a) * N + unsigned(counter_rom_b(7 DOWNTO 0)));
						en_write <= '1';
						lp_state <= INCR;
					end if;
					
				when FIN =>
					if done = '0' then
						lp_state <= NOP;
					end if;
			
			end case;
		end if;
	END PROCESS;
			 
	steuerwerk: PROCESS(rst, clk)
	variable cnt: integer := 0;
	BEGIN
		if rst = RSTDEF then
			stwrk_state <= SPIN;
			en_rom <= '0';
			en_add <= '0';
			done <= '0';
			res <= (others => '0');
		elsif rising_edge(clk) then
				case stwrk_state is
					when SPIN =>
					
						if start = '1' then
							res <= (others => '0');
							en_rom <= '1';
							en_add <= '0';
							addra_rom <= counter_rom_a;
							addrb_rom <= counter_rom_b;
							done <= '0';
							stwrk_state <= INCR;
							
						end if;
					when INCR =>
					
						addra_rom <= addra_rom + "0000000001";  -- + 1, nächste Spalte in A
						addrb_rom <= addrb_rom + "0000000010";  -- + N, nächste Zeile in B
						en_add <= '1';
						cnt := cnt+1;
						if cnt = N-1 then
							stwrk_state <= FIN;
						end if;
						
					when NOP =>
					
						en_add <= '0';
						stwrk_state <= FIN;

					when FIN =>
						done <= '1';
						res <= add_res;
						stwrk_state <= SPIN;
				end case;
		end if;
	END PROCESS;
	
	display: PROCESS(rst, clk, sw)
	BEGIN

		en_ram <= '1';
		addrb_ram <= "00" & sw;  -- read from RAM
		dout <= doutb_ram;

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
