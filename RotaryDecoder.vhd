LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RotaryDecoder IS
	GENERIC (
		debounceTime : INTEGER := 10;
		encoderResolution : INTEGER := 4
	);
	PORT (
		clk, rst : IN STD_LOGIC;
		a, b : IN STD_LOGIC;
		a_deb, b_deb : OUT STD_LOGIC;
		dir : OUT STD_LOGIC;
		posi : OUT STD_LOGIC_VECTOR(encoderResolution - 1 DOWNTO 0)
	);
END RotaryDecoder;

ARCHITECTURE RotaryDecoder_arch OF RotaryDecoder IS
	SIGNAL a_vect, b_vect : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL cnt_clr, cnt_ena : STD_LOGIC;
	SIGNAL cnt : INTEGER RANGE 0 TO debounceTime;
	SIGNAL reg_ena : STD_LOGIC;
	SIGNAL posi_ena : STD_LOGIC;
	SIGNAL posi_int : UNSIGNED (encoderResolution - 1 DOWNTO 0);
	SIGNAL dir_int : STD_LOGIC;
	SIGNAL a_deb_int, b_deb_int : STD_LOGIC;
BEGIN

	reg_ena <= '1' WHEN cnt = debounceTime ELSE
		'0';
	cnt_clr <= (a_vect(0) XOR a_vect(1)) OR (b_vect(0) XOR b_vect(1));
	cnt_ena <= cnt_clr OR (NOT reg_ena);

	dir_int <= a_deb_int XOR b_vect(0);

	posi_ena <= reg_ena AND ((a_vect(0) XOR a_deb_int) OR (b_vect(0) XOR b_deb_int));

	dir <= dir_int;
	posi <= STD_LOGIC_VECTOR(posi_int);
	a_deb <= a_deb_int;
	b_deb <= b_deb_int;

	cnt_reg : PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			cnt <= 0;
		ELSIF clk'EVENT AND clk = '1' THEN
			IF cnt_clr = '1' THEN
				cnt <= 0;
			ELSE
				IF cnt_ena = '1' THEN
					cnt <= cnt + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	a_b_reg : PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			a_vect <= (OTHERS => '0');
			b_vect <= (OTHERS => '0');
			a_deb_int <= '0';
			b_deb_int <= '0';
		ELSIF clk'EVENT AND clk = '1' THEN
			a_vect <= a & a_vect(1);
			b_vect <= b & b_vect(1);
			IF reg_ena = '1' THEN
				a_deb_int <= a_vect(0);
				b_deb_int <= b_vect(0);
			END IF;
		END IF;
	END PROCESS;

	posi_reg : PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			posi_int <= (OTHERS => '0');
		ELSIF clk'EVENT AND clk = '1' THEN
			IF posi_ena = '1' THEN
				IF dir_int = '1' THEN
					posi_int <= posi_int + 1;
				ELSE
					posi_int <= posi_int - 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

END RotaryDecoder_arch;