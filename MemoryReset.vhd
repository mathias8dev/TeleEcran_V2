LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;


-- This version can be optimized

ENTITY MemoryReset IS
    GENERIC (
        address_bus_width : INTEGER := 9
    );
    PORT (
        clk : IN STD_LOGIC;
        start : IN STD_LOGIC;
        in_progress : OUT STD_LOGIC;
        memory_add_a : OUT STD_LOGIC_VECTOR(address_bus_width - 1 DOWNTO 0);
        memory_add_b : OUT STD_LOGIC_VECTOR(address_bus_width - 1 DOWNTO 0)
    );
END MemoryReset;

ARCHITECTURE arch OF MemoryReset IS
    TYPE statetype IS (ATT, RESET_START, RESET_IN_PROGRESS, RESET_END);
    SIGNAL is_resetting, is_resetting_next : STD_LOGIC;
    SIGNAL state, next_state : statetype;
    SIGNAL memory_add, memory_add_next : unsigned(address_bus_width - 2 DOWNTO 0);
    SIGNAL clk_cnt, clk_cnt_next : INTEGER RANGE 0 TO 4;
BEGIN

    process_registers_process : PROCESS (start, clk)
    BEGIN
        IF start = '1' THEN
            is_resetting <= '1';
            memory_add <= (OTHERS => '0');
            clk_cnt <= 0;
            state <= ATT;
        ELSIF clk'event  and clk = '1' THEN
            is_resetting <= is_resetting_next;
            memory_add <= memory_add_next;
            clk_cnt <= clk_cnt_next;
            state <= next_state;
        END IF;
    END PROCESS;
    process_is_resetting_next_process : PROCESS (clk)
    BEGIN
        CASE state IS
            WHEN RESET_END | ATT =>
                is_resetting_next <= '0';
            WHEN OTHERS =>
                is_resetting_next <= '1';
        END CASE;

    END PROCESS;

    process_next_state_process : PROCESS (clk)
    BEGIN
        CASE state IS
            WHEN ATT =>
                next_state <= RESET_START;
            WHEN reset_start =>
                next_state <= RESET_IN_PROGRESS;
            WHEN RESET_IN_PROGRESS =>
                IF memory_add = 2 ** (address_bus_width - 2) THEN
                    next_state <= RESET_END;
                ELSE
                    next_state <= state;
                END IF;
            WHEN RESET_END =>
                next_state <= ATT;
        END CASE;
    END PROCESS;
    process_clk_cnt_next_process : PROCESS (clk)
    BEGIN
        CASE state IS
            WHEN RESET_IN_PROGRESS =>
                IF clk_cnt < 4 THEN
                    clk_cnt_next <= clk_cnt + 1;
                ELSE
                    clk_cnt_next <= 0;
                END IF;
            WHEN OTHERS =>
                clk_cnt_next <= 0;
        END CASE;
    END PROCESS;

    process_memory_add_next_process : PROCESS (clk)
    BEGIN
        CASE state IS
            WHEN RESET_IN_PROGRESS =>
                IF clk_cnt = 4 AND memory_add < 2 ** (address_bus_width - 2) THEN
                    memory_add_next <= memory_add + 1;
                ELSE
                    memory_add_next <= memory_add;
                END IF;
            WHEN OTHERS =>
                memory_add_next <= (OTHERS => '0');
        END CASE;
    END PROCESS;

    in_progress <= is_resetting;
    memory_add_a <= STD_LOGIC_VECTOR('0' & memory_add);
    memory_add_b <= STD_LOGIC_VECTOR('1' & memory_add);

END ARCHITECTURE;