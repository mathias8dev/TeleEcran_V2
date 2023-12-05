LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY AddSelector
    IS GENERIC (
        mx_ppline : INTEGER := 32;
        mx_lines : INTEGER := 16
    );
    PORT (
        fl : IN STD_LOGIC;
        hlsm_add_a : IN STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
        mem_ctrl_add_a : IN STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
        add_a : OUT STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0)
    );

END ENTITY;

ARCHITECTURE arch OF AddSelector IS
BEGIN
    PROCESS (fl)
    BEGIN
        IF fl = '1' THEN
            add_a <= mem_ctrl_add_a;
        ELSE
            add_a <= hlsm_add_a;
        END IF;
    END PROCESS;
END ARCHITECTURE;