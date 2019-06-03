
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_buffer implementiert werden.
--
ARCHITECTURE struktur OF sync_buffer IS
	 SIGNAL q: std_logic;
	 SIGNAL q2: std_logic;
	 SIGNAL q3: std_logic;
	 SIGNAL hyst: std_logic;
	 type TState IS (S0, S1);
	 signal state: TState;
	 SIGNAL cnt: integer range 0 to 31;
BEGIN
	PROCESS(rst, clk) IS
	BEGIN
		if rst=RSTDEF then
			q <= '0';
		elsif rising_edge(clk) then
			q <= din;
			if swrst = RSTDEF then
				q <= '0';
			end if;
		end if;		
	END PROCESS;
 
	PROCESS(rst, clk) IS
	BEGIN
		if rst=RSTDEF then
			q2 <= '0';
		elsif rising_edge(clk) then
			q2 <= q;
			if swrst = RSTDEF then
				q2 <= '0';
			end if;
		end if;		
	END PROCESS;

	PROCESS(rst, clk) IS
	BEGIN
		if rst=RSTDEF then
			hyst <= '0';
			state <= S0;
			cnt <= 0;
		elsif rising_edge(clk) then
			if en = '1' then
				case state is
					when S0 =>
						hyst <= '0';
						if q2 = '1' then
							if cnt < 31 then
								cnt <= cnt + 1;
							else
								state <= S1;
							end if;
						else
							if cnt > 0 then
								cnt <= cnt - 1;
							end if;
						end if;
					when S1 =>
						hyst <= '1';
						if q2 = '1' then
							if cnt < 31 then
								cnt <= cnt + 1;
							end if;
					    else
							if cnt > 0 then
								cnt <= cnt - 1;
							else
								state <= S0;
							end if;
						end if;
				end case;
			end if;
			if swrst = RSTDEF then
				hyst <= '0';
				state <= S0;
				cnt <= 0;
			end if;
		end if;
	END PROCESS;
	
	PROCESS(rst, clk) IS
	BEGIN
		if rst=RSTDEF then
			q3 <= '0';
		elsif rising_edge(clk) then
			q3 <= hyst;
			if swrst = RSTDEF then
				q3 <= '0';
			end if;
		end if;		
	END PROCESS;
	
	fedge <= not hyst and q3;
	dout  <= q3;
	redge <= not q3 and hyst;
END struktur;