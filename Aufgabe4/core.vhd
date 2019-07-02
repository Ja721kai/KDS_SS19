
LIBRARY ieee, unisim;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--USE ieee.std_logic_arith.ALL;
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
	
	-- state machine for outer loop and scalar multiplication
	type TState IS (SPIN, INCR, NOP, FIN);
	SIGNAL stwrk_state: TState := SPIN;
	SIGNAL lp_state: TState := SPIN;
	
	-- RAM
   SIGNAL addrb_ram: std_logic_VECTOR(9 DOWNTO 0);   -- address to read out from
	SIGNAL doutb_ram: std_logic_VECTOR(15 DOWNTO 0);  -- register to hold read value
	SIGNAL counter_ram: std_logic_vector(9 DOWNTO 0); -- address to write into RAM
	SIGNAL en_write: std_logic;							  -- write enable
	SIGNAL en_ram: std_logic;								  -- enable Port A
	-- no read enable for RAM Port B, read enable is set to '1' (Port B)
	
	-- ROM
	SIGNAL addra_rom: std_logic_VECTOR(9 DOWNTO 0);     -- read from ROM 0x0000 to 0x00FF
   SIGNAL addrb_rom: std_logic_VECTOR(9 DOWNTO 0);		 -- read from ROM 0x0100 to 0x01FF
	SIGNAL douta_rom: std_logic_VECTOR(15 DOWNTO 0);	 -- holds value from read on Matrix A
	SIGNAL doutb_rom: std_logic_VECTOR(15 DOWNTO 0);    -- holds value from read on Matrix B
	SIGNAL extdouta_rom: std_logic_VECTOR(17 DOWNTO 0); -- extended value (16 to 18 bits)
	SIGNAL extdoutb_rom: std_logic_VECTOR(17 DOWNTO 0); -- extended value (16 to 18 bits)
   SIGNAL en_rom:   std_logic;								 -- read enable
	
	-- akkumulator variables
	SIGNAL en_add:   std_logic;						   -- add enable
	SIGNAL multres: std_logic_vector(35 DOWNTO 0);  -- holds multiplication result which is accumulated on add_res
	SIGNAL add_res: std_logic_vector(43 DOWNTO 0);  -- holds accumulated value of scalar multiplication
	 
	-- scalar multiplication and outer loop
	SIGNAL res: std_logic_vector(15 DOWNTO 0);  				-- holds addition result of scalar multiplication
	SIGNAL counter_rom: std_logic_vector(7 DOWNTO 0); 		-- 7-4: A, 3-0:B, ROM Port start addresses
	SIGNAL start: std_logic;										-- handshake signal for scalar multiplication
	SIGNAL done: std_logic;											-- handshake signal for outer loop
	constant N: natural := 16;										-- matrix size
	constant Z: natural := 0;
	constant O: natural := 1;
	
	

BEGIN

	rb: ram_block
	PORT MAP(
	  douta 	=> OPEN,
	  doutb	=> doutb_ram,
	  dina	=> res,
	  addra	=> counter_ram,
	  addrb	=> addrb_ram,
	  clka	=> clk,
	  clkb	=> clk,
	  ena		=> en_ram,
	  enb		=> '1',
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
	
	-- Vektorgröße erhöhen
	extdouta_rom <= "00" & douta_rom;
	extdoutb_rom <= "00" & doutb_rom;
	
	--xapp463 entnommen
	mult: MULT18X18
	PORT MAP(
		A => extdouta_rom,
		B => extdoutb_rom,
		P => multres
	);
	
	-- display numbers on 7 segment display
	addrb_ram <= "00" & sw;
	dout <= doutb_ram;
	
	outerloop: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			start <= '0';
			rdy <= '0';
			counter_rom <= (others => '0');
			counter_ram <= (others => '0');
			en_ram <= '0';
			en_write <= '0';
			lp_state <= SPIN;
		elsif rising_edge(clk) then
			case lp_state is
				when SPIN =>
				
					if strt = '1' then	
						start <= '1';
						lp_state <= NOP;
					end if;
					
				when INCR =>
				
					lp_state <= NOP;
					en_write <= '0';
					en_ram <= '0';
					counter_ram <= counter_ram + '1';
				
				when NOP =>
					start <= '0';
					if done = '1' then
						lp_state <= INCR;
						en_write <= '1';
						en_ram <= '1';
						start <= '1';
						if counter_rom = "11111111" then  -- letzter Wert?
							start <= '0';
							rdy <= '1';
							lp_state <= SPIN;
						else
							counter_rom <= counter_rom + '1';
						end if;
					end if;
					
				when FIN =>
					-- do nothing
			
			end case;
		end if;
	END PROCESS;
			 
	scalar_multiplication: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			stwrk_state <= SPIN;
			en_rom <= '0';
			en_add <= '0';
			done <= '0';
			res <= (others => '0');
			addra_rom <= (others => '0');
			addrb_rom <= (others => '0');
		elsif rising_edge(clk) then
				case stwrk_state is
					when SPIN =>
						if start = '1' then
							en_rom <= '1';
							addra_rom(7 DOWNTO 0) <= counter_rom(7 DOWNTO 4) & "0000";
							addrb_rom <= "010000" & counter_rom(3 DOWNTO 0);
							done <= '0';
							stwrk_state <= INCR;
						end if;
					when INCR =>
					
						addra_rom <= addra_rom + '1';  -- + 1, nächste Spalte in A
						addrb_rom <= addrb_rom + N;  -- + N, nächste Zeile in B
						en_add <= '1';
						if addra_rom(3 DOWNTO 0) = "1111" then
							en_rom <= '0';
							stwrk_state <= NOP;
							addra_rom <= addra_rom;
						end if;
						
					when NOP =>
					
							stwrk_state <= FIN;
							en_add <= '0';
							done <= '1';
						
					when FIN =>
					
							res <= add_res(15 DOWNTO 0);
							stwrk_state <= SPIN;
						
				end case;
		end if;
	END PROCESS;

	addierer_akk: PROCESS(rst, clk)
	BEGIN
		if rst = RSTDEF then
			add_res <= (others => '0');
		elsif rising_edge(clk) then
			if en_add = '1' then
				add_res <= add_res + ("00000000" & multres);
			else
				add_res <= (others => '0');
			end if;
		end if;
	END PROCESS;
		
END structure;
