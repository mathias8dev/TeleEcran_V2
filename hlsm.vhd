LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY hlsm IS
	GENERIC (
		mx_lines : INTEGER := 16;
		mx_ppline : INTEGER := 32;
		mx_enc_depth : INTEGER := 8);

	PORT (
		ar : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		mx_LE : OUT STD_LOGIC;
		mx_OE : OUT STD_LOGIC;
		mx_clock : OUT STD_LOGIC;
		mx_CBA : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines)))) - 2 DOWNTO 0);
		ram_add_t : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
		ram_add_b : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
		pwm_cnt : OUT STD_LOGIC_VECTOR(mx_enc_depth - 1 DOWNTO 0);
		end_frame : OUT STD_LOGIC
	);
END hlsm;

ARCHITECTURE arch OF hlsm IS
	TYPE statetype IS (ATT, CHFL, FFL, FL);
	SIGNAL state, next_state : statetype;
	SIGNAL lines, lines_next : INTEGER RANGE 0 TO (mx_lines / 2) - 1 := 0;
	SIGNAL pixel, pixel_next : INTEGER RANGE 0 TO mx_ppline - 1 := 0;
	SIGNAL ram_add, ram_add_next : UNSIGNED(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 2 DOWNTO 0) := (OTHERS => '0');
	SIGNAL cnt, cnt_next : INTEGER RANGE 0 TO 8 := 0;
	SIGNAL cnt_pwm, cnt_pwm_next : unsigned(mx_enc_depth - 1 DOWNTO 0) := (OTHERS => '0');

	CONSTANT ram_add_max : INTEGER := 2 ** (ram_add'length) - 1;
BEGIN

	-------------------------------------------------------------------------
	-- REGISTERS
	-------------------------------------------------------------------------
	registers_process : PROCESS (ar, clock)
	BEGIN
		IF ar = '1' THEN
			state <= ATT;
			lines <= 0;
			pixel <= 0;
			ram_add <= (OTHERS => '0');
			cnt <= 0;
			cnt_pwm <= (OTHERS => '0');

		ELSIF clock'EVENT AND clock = '1' THEN
			state <= next_state;
			pixel <= pixel_next;
			lines <= lines_next;
			ram_add <= ram_add_next;
			cnt <= cnt_next;
			cnt_pwm <= cnt_pwm_next;
		END IF;
	END PROCESS;
	-----------------
	-- STATE NEXT
	-----------------

	---------------------------------------
	-- lines_next
	---------------------------------------
	state_next_lines_next_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				lines_next <= 0;
			WHEN CHFL =>
				lines_next <= lines;
			WHEN FFL =>
				lines_next <= lines;
			WHEN FL =>
				IF cnt = 0 THEN
					IF lines < (mx_lines / 2) - 1 THEN
						lines_next <= lines + 1;
					ELSE
						lines_next <= 0;
					END IF;
				ELSE
					lines_next <= lines;
				END IF;
		END CASE;
	END PROCESS state_next_lines_next_process;

	---------------------------------------
	-- next_state
	---------------------------------------
	state_next_next_state_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				next_state <= CHFL;
			WHEN CHFL =>
				IF (pixel = mx_ppline - 1) AND (cnt = 3) THEN
					IF (cnt_pwm /= 2 ** mx_enc_depth - 2) THEN
						next_state <= FFL;
					ELSE
						next_state <= FL;
					END IF;
				ELSE
					next_state <= state;
				END IF;
			WHEN OTHERS =>
				IF cnt = 8 THEN
					next_state <= CHFL;
				ELSE
					next_state <= state;
				END IF;
		END CASE;
	END PROCESS state_next_next_state_process;

	---------------------------------------
	-- pixel_next
	---------------------------------------
	state_next_pixel_next_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				pixel_next <= 0;
			WHEN CHFL =>
				IF pixel < mx_ppline - 1 AND cnt = 3 THEN
					pixel_next <= pixel + 1;
				ELSE
					pixel_next <= pixel;
				END IF;

			WHEN OTHERS =>
				IF cnt = 0 THEN
					pixel_next <= 0;
				ELSE
					pixel_next <= pixel;
				END IF;
		END CASE;
	END PROCESS state_next_pixel_next_process;

	---------------------------------------
	-- ram_add_next
	---------------------------------------
	state_next_ram_add_next_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				ram_add_next <= (OTHERS => '0');
			WHEN CHFL =>
				IF pixel < (mx_ppline - 1) AND cnt = 3 THEN
					ram_add_next <= ram_add + 1;
				ELSE
					ram_add_next <= ram_add;
				END IF;
			WHEN FFL =>
				IF cnt = 0 THEN
					-- Encore égale à ram_add_next <= ram_add - mx_ppline + 1
					ram_add_next <= to_unsigned(lines * (mx_ppline), ram_add_next'length);
				ELSE
					ram_add_next <= ram_add;
				END IF;
			WHEN FL =>
				IF cnt = 0 THEN
					IF ram_add < ram_add_max THEN
						ram_add_next <= ram_add + 1;
					ELSE
						ram_add_next <= (OTHERS => '0');
					END IF;
				ELSE
					ram_add_next <= ram_add;
				END IF;
		END CASE;
	END PROCESS state_next_ram_add_next_process;

	---------------------------------------
	-- cnt_next
	---------------------------------------

	state_next_cnt_next_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				cnt_next <= 0;
			WHEN CHFL =>
				IF cnt < 3 THEN
					cnt_next <= cnt + 1;
				ELSE
					cnt_next <= 0;
				END IF;
			WHEN OTHERS =>
				IF cnt < 8 THEN
					cnt_next <= cnt + 1;
				ELSE
					cnt_next <= 0;
				END IF;
		END CASE;
	END PROCESS state_next_cnt_next_process;

	---------------------------------------
	-- cnt_pwm_next
	---------------------------------------

	state_next_cnt_pwm_next_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				cnt_pwm_next <= (OTHERS => '0');
			WHEN CHFL =>
				cnt_pwm_next <= cnt_pwm;
			WHEN FFL =>
				IF cnt = 0 THEN
					cnt_pwm_next <= cnt_pwm + 1;
				ELSE
					cnt_pwm_next <= cnt_pwm;
				END IF;
			WHEN FL =>
				cnt_pwm_next <= (OTHERS => '0');
		END CASE;
	END PROCESS state_next_cnt_pwm_next_process;
	-----------------
	-- OUTPUT
	-----------------

	---------------------------------------
	-- mx_clock
	---------------------------------------
	output_mx_clock_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				mx_clock <= '1';
			WHEN CHFL =>
				IF cnt < 2 THEN
					mx_clock <= '1';
				ELSE
					mx_clock <= '0';
				END IF;
			WHEN FFL =>
				mx_clock <= '1';
			WHEN FL =>
				mx_clock <= '1';
		END CASE;
	END PROCESS output_mx_clock_process;

	---------------------------------------
	-- mx_OE
	---------------------------------------
	output_mx_OE_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				mx_OE <= '1';
			WHEN CHFL =>
				mx_OE <= '0';
			WHEN FFL =>
				mx_OE <= '0';
			WHEN FL =>
				mx_OE <= '1';
		END CASE;
	END PROCESS output_mx_OE_process;

	---------------------------------------
	-- mx_LE
	---------------------------------------
	output_mx_LE_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN ATT =>
				mx_LE <= '0';
			WHEN CHFL =>
				mx_LE <= '0';
			WHEN FFL =>
				IF cnt > 2 AND cnt < 6 THEN
					mx_LE <= '1';
				ELSE
					mx_LE <= '0';
				END IF;

			WHEN FL =>
				IF cnt > 2 AND cnt < 6 THEN
					mx_LE <= '1';
				ELSE
					mx_LE <= '0';
				END IF;
		END CASE;
	END PROCESS output_mx_LE_process;

	output_end_frame_process : PROCESS (clock)
	BEGIN
		CASE state IS
			WHEN FL =>
				end_frame <= '1';
			WHEN OTHERS =>
				end_frame <= '0';
		END CASE;
	END PROCESS;

	ram_add_t <= STD_LOGIC_VECTOR('0' & ram_add);
	ram_add_b <= STD_LOGIC_VECTOR('1' & ram_add);

	mx_CBA <= STD_LOGIC_VECTOR(to_unsigned(lines, mx_CBA'length));
	pwm_cnt <= STD_LOGIC_VECTOR(cnt_pwm);
END arch;