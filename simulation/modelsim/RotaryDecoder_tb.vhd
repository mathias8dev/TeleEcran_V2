LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;

ENTITY RotaryDecoder_tb IS
END ENTITY;

ARCHITECTURE arch OF RotaryDecoder_tb IS
    SIGNAL rst, clk, a, b : STD_LOGIC;
    SIGNAL posi : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL b_delayed : BOOLEAN := false;

    CONSTANT clock_period : TIME := 250 ns;

    COMPONENT RotaryDecoder IS
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
    END COMPONENT;
BEGIN

    rst_process : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR clock_period * 8;
        rst <= '0';
        WAIT;
    END PROCESS;

    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clock_period / 2;
        clk <= '0';
        WAIT FOR clock_period / 2;
    END PROCESS;

    a_process : PROCESS
    BEGIN
        a <= '1';
        WAIT FOR clock_period * 10;
        a <= '0';
        WAIT FOR clock_period * 10;
    END PROCESS;

    b_process : PROCESS
    BEGIN
        IF NOT b_delayed THEN
            b <= '0';
            WAIT FOR clock_period * 5;
            b_delayed <= true;
        END IF;
        b <= '1';
        WAIT FOR clock_period * 10;
        b <= '0';
        WAIT FOR clock_period * 10;
    END PROCESS;
    RotaryDecoder_inst : RotaryDecoder
    GENERIC MAP(
        debounceTime => 10, --number of clock cycles required to register a new position = debounce_time + 2
        encoderResolution => 4)
    PORT MAP(
        clk => clk,
        rst => rst,
        a => a,
        b => b,
        a_deb => OPEN,
        b_deb => OPEN,
        dir => OPEN,
        posi => posi
    );
END ARCHITECTURE;