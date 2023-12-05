LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY MemController IS
    GENERIC (
        mx_ppline : INTEGER := 32;
        mx_lines : INTEGER := 16
    );
    PORT (
        fl : IN STD_LOGIC;
        is_resetting : IN STD_LOGIC;
        xposition : IN INTEGER RANGE 0 TO mx_ppline - 1;
        yposition : IN INTEGER RANGE 0 TO mx_lines - 1;
        add_a : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
        wren_a : OUT STD_LOGIC;
        wren_b : OUT STD_LOGIC
    );

END ENTITY;

ARCHITECTURE arch OF MemController IS
BEGIN
    PROCESS (fl, is_resetting)
    BEGIN
        IF is_resetting = '1' THEN
            wren_a <= '1';
            wren_b <= '1';
        ELSIF fl = '1' THEN
            add_a <= STD_LOGIC_VECTOR(to_unsigned(yposition * mx_ppline + xposition, add_a'length));
            wren_a <= '1';
            wren_b <= '0';
        ELSE
            add_a <= (OTHERS => '0');
            wren_a <= '0';
            wren_b <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE;