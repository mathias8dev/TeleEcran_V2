LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;

ENTITY QuadratureDecoder_tb IS
END ENTITY;

ARCHITECTURE arch OF QuadratureDecoder_tb IS
    SIGNAL ar, clk, re_clk, dt, sw, sw_pressed : STD_LOGIC;
    SIGNAL dir : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL update : STD_LOGIC;
    SIGNAL dt_delayed : BOOLEAN := false;
    SIGNAL position : INTEGER RANGE 0 TO 15;
    CONSTANT clock_period : TIME := 250 ns;

    COMPONENT QuadratureDecoder IS
        GENERIC (
            positions : INTEGER := 16; --size of the position counter (i.e. number of positions counted)
            overflow : BOOLEAN := true;
            debounce_time : INTEGER := 50_000; --number of clock cycles required to register a new position = debounce_time + 2
            set_origin_debounce_time : INTEGER := 500_000); --number of clock cycles required to register a new set_origin_n value = set_origin_debounce_time + 2
        PORT (
            clk : IN STD_LOGIC; --system clock
            a : IN STD_LOGIC; --quadrature encoded signal a
            b : IN STD_LOGIC; --quadrature encoded signal b
            set_origin_n : IN STD_LOGIC; --active-low synchronous clear of position counter
            direction : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --direction of last change, 1 = positive, 0 = negative
            position : BUFFER INTEGER RANGE 0 TO positions - 1 := 0; --current position relative to index or initial value
            update : OUT STD_LOGIC);
    END COMPONENT;
BEGIN

    ar_process : PROCESS
    BEGIN
        ar <= '1';
        WAIT FOR clock_period * 8;
        ar <= '0';
        WAIT;
    END PROCESS;

    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clock_period / 2;
        clk <= '0';
        WAIT FOR clock_period / 2;
    END PROCESS;

    re_clk_process : PROCESS
    BEGIN
        re_clk <= '1';
        WAIT FOR clock_period * 10;
        re_clk <= '0';
        WAIT FOR clock_period * 10;
    END PROCESS;

    dt_process : PROCESS
    BEGIN
        IF NOT dt_delayed THEN
            dt <= '0';
            WAIT FOR clock_period * 5;
            dt_delayed <= true;
        END IF;
        dt <= '1';
        WAIT FOR clock_period * 10;
        dt <= '0';
        WAIT FOR clock_period * 10;
    END PROCESS;

    sw_process : PROCESS
    BEGIN
        sw <= '1';
        WAIT FOR clock_period * 2 - clock_period;
        sw <= '0';
        WAIT FOR clock_period * 2 - clock_period;
    END PROCESS;
    QuadratureDecoder_inst : QuadratureDecoder
    GENERIC MAP(
        positions => 16,
        overflow => true,
        debounce_time => 100, --number of clock cycles required to register a new position = debounce_time + 2
        set_origin_debounce_time => 50)
    PORT MAP(
        SET_ORIGIN_N => '1',
        CLK => clk,
        A => re_clk,
        B => dt,
        DIRECTION => dir,
        POSITION => position,
        update => update
    );
END ARCHITECTURE;