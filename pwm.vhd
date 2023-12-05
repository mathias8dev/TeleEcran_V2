LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pwm IS

	GENERIC (mx_enc_depth : INTEGER := 8);

	PORT (
		mx_clock : IN STD_LOGIC;
		cnt_pwm : IN STD_LOGIC_VECTOR(mx_enc_depth - 1 DOWNTO 0);
		color_cp : IN STD_LOGIC_VECTOR(mx_enc_depth - 1 DOWNTO 0); -- color_cp: Color component. The same color_cp is received at the frequency of 32 périodes of clock hor 256 times.
		color_cpm : OUT STD_LOGIC -- color_cpm: Color Component modulated
	);
END pwm;

ARCHITECTURE arch OF pwm IS
BEGIN

	state_process : PROCESS (mx_clock, cnt_pwm)
	BEGIN
		IF rising_edge(mx_clock) AND mx_clock = '1' THEN
			IF unsigned(color_cp) > 0 AND  unsigned(color_cp) >= unsigned(cnt_pwm) THEN
				color_cpm <= '1';
			ELSE
				color_cpm <= '0';
			END IF;
		END IF;
	END PROCESS state_process;

END ARCHITECTURE arch;