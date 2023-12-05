LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

ENTITY TeleEcran_tb IS
END TeleEcran_tb;

ARCHITECTURE arch OF TeleEcran_tb IS

	COMPONENT TeleEcran IS

	GENERIC (
        mx_lines : INTEGER := 16;
        mx_ppline : INTEGER := 32;
        enc_depth : INTEGER := 8;
        debounce_time : INTEGER := 50000;
        overflow : BOOLEAN := false
    );
    PORT (
        clock_50 : IN STD_LOGIC;
        global_ar : IN STD_LOGIC;
        xre_clk : IN STD_LOGIC;
        xre_dt : IN STD_LOGIC;
        yre_clk : IN STD_LOGIC;
        yre_dt : IN STD_LOGIC;
        redre_clk : IN STD_LOGIC;
        redre_dt : IN STD_LOGIC;
        greenre_clk : IN STD_LOGIC;
        greenre_dt : IN STD_LOGIC;
        bluere_clk : IN STD_LOGIC;
        bluere_dt : IN STD_LOGIC;
        mx_clock : OUT STD_LOGIC;
        mx_CBA : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines)))) - 2 DOWNTO 0);
        mx_R1 : OUT STD_LOGIC;
        mx_R2 : OUT STD_LOGIC;
        mx_V1 : OUT STD_LOGIC;
        mx_v2 : OUT STD_LOGIC;
        mx_B1 : OUT STD_LOGIC;
        mx_B2 : OUT STD_LOGIC;
        mx_LE : OUT STD_LOGIC;
        mx_OE : OUT STD_LOGIC
    );
	END COMPONENT;


	CONSTANT mx_lines : INTEGER := 16;
	CONSTANT mx_ppline : INTEGER := 32;
	CONSTANT enc_depth : INTEGER := 8;
	CONSTANT debounce_time : INTEGER := 2600;
	CONSTANT overflow: boolean := false;
	
	CONSTANT clock_period : TIME := 20 ns; -- 20ns -> f_clock=50 MHz
	CONSTANT clock_period2 : TIME := 250 ns; -- 250ns -> f_clock=4 MHz


	SIGNAL clock_50 : STD_LOGIC;
	SIGNAL global_ar : STD_LOGIC;
	SIGNAL xre_clk : STD_LOGIC;
	SIGNAL yre_clk : STD_LOGIC;
	SIGNAL xre_dt : STD_LOGIC;
	SIGNAL yre_dt : STD_LOGIC;
	SIGNAL xre_sw : STD_LOGIC;
	SIGNAL yre_sw : STD_LOGIC;
	SIGNAL redre_clk : STD_LOGIC;
	SIGNAL greenre_clk : STD_LOGIC;
	SIGNAL bluere_clk : STD_LOGIC;
	SIGNAL redre_dt : STD_LOGIC;
	SIGNAL greenre_dt : STD_LOGIC;
	SIGNAL bluere_dt : STD_LOGIC;
	SIGNAL mx_clock : STD_LOGIC;
	SIGNAL mx_LE : STD_LOGIC;
	SIGNAL mx_OE : STD_LOGIC;
	SIGNAL mx_CBA : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines)))) - 2 DOWNTO 0);
	SIGNAL mx_R1 : STD_LOGIC;
	SIGNAL mx_V1 : STD_LOGIC;
	SIGNAL mx_B1 : STD_LOGIC;
	SIGNAL mx_R2 : STD_LOGIC;
	SIGNAL mx_V2 : STD_LOGIC;
	SIGNAL mx_B2 : STD_LOGIC;

	SIGNAL xre_dt_delayed, yre_dt_delayed, redre_dt_delayed, greenre_dt_delayed, bluere_dt_delayed : BOOLEAN := false;
	
	

BEGIN

	TeleEcran_inst : TeleEcran
	GENERIC MAP(
		mx_lines => mx_lines,
		mx_ppline => mx_ppline,
		enc_depth => enc_depth,
		debounce_time => 1200,
		overflow => overflow
	)
	PORT MAP

	(
	clock_50 => clock_50,
	global_ar => global_ar,
	xre_clk => xre_clk,
	yre_clk => yre_clk,
	xre_dt => xre_dt,
	yre_dt => yre_dt,
	redre_clk => redre_clk,
	greenre_clk => greenre_clk,
	bluere_clk => bluere_clk,
	redre_dt => redre_dt,
	greenre_dt => greenre_dt,
	bluere_dt => bluere_dt,
	mx_clock => mx_clock,
	mx_LE => mx_LE,
	mx_OE => mx_OE,
	mx_CBA => mx_CBA,
	mx_R1 => mx_R1,
	mx_V1 => mx_V1,
	mx_B1 => mx_B1,
	mx_R2 => mx_R2,
	mx_V2 => mx_V2,
	mx_B2 => mx_B2
	);

	ar2 : PROCESS
	BEGIN
		global_ar <= '1';
		WAIT FOR 500 ns;
		global_ar <= '0';
		WAIT;
	END PROCESS ar2;

	clock : PROCESS
	BEGIN
		clock_50 <= '0';
		WAIT FOR clock_period/2;
		clock_50 <= '1';
		WAIT FOR clock_period/2;
	END PROCESS clock;

	xre_clk_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 20;
		xre_clk <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		xre_clk <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	xre_dt_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 20;
		IF NOT xre_dt_delayed THEN
			xre_dt <= '0';
			WAIT FOR clock_period2 * debounce_time * 2;
			xre_dt_delayed <= true;
		END IF;
		xre_dt <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		xre_dt <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	yre_clk_process : PROCESS
	BEGIN
		yre_clk <= '0';
		WAIT;
		yre_clk <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		yre_clk <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	yre_dt_process : PROCESS
	BEGIN
		yre_dt <= '0';
		WAIT;
		IF NOT yre_dt_delayed THEN
			yre_dt <= '0';
			WAIT FOR clock_period2 * debounce_time * 2;
			yre_dt_delayed <= true;
		END IF;
		yre_dt <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		yre_dt <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	redre_clk_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 30;
		redre_clk <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		redre_clk <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	redre_dt_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 30;
		IF NOT redre_dt_delayed THEN
			redre_dt <= '0';
			WAIT FOR clock_period2 * debounce_time * 2;
			redre_dt_delayed <= true;
		END IF;
		redre_dt <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		redre_dt <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	greenre_clk_process : PROCESS
	BEGIN
		greenre_clk <= '0';
		WAIT;
		greenre_clk <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		greenre_clk <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	greenre_dt_process : PROCESS
	BEGIN
		greenre_dt <= '0';
		WAIT;
		IF NOT greenre_dt_delayed THEN
			greenre_dt <= '0';
			WAIT FOR clock_period2 * debounce_time * 2;
			greenre_dt_delayed <= true;
		END IF;
		greenre_dt <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		greenre_dt <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	bluere_clk_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 70;
		bluere_clk <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		bluere_clk <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

	bluere_dt_process : PROCESS
	BEGIN
		WAIT FOR clock_period2 * 70;
		IF NOT bluere_dt_delayed THEN
			bluere_dt <= '0';
			WAIT FOR clock_period2 * debounce_time * 2;
			bluere_dt_delayed <= true;
		END IF;
		bluere_dt <= '1';
		WAIT FOR clock_period2 * debounce_time * 4;
		bluere_dt <= '0';
		WAIT FOR clock_period2 * debounce_time * 4;
	END PROCESS;

END arch;