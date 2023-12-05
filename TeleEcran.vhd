LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY TeleEcran IS
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

END ENTITY;

ARCHITECTURE arch OF TeleEcran IS

    SIGNAL ar : STD_LOGIC;
    SIGNAL clock_4 : STD_LOGIC;
    SIGNAL pll_locked : STD_LOGIC;
    SIGNAL final_std_red_color, std_red_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL final_std_green_color, std_green_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL final_std_blue_color, std_blue_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
	 SIGNAL final_ram_add_t : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
	 SIGNAL final_ram_add_b : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
    ----------------------------------------------------
    ----- hlsm
    ----------------------------------------------------
    SIGNAL matrix_clock : STD_LOGIC;
    SIGNAL pwm_cnt : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL end_frame : STD_LOGIC;
    SIGNAL hlsm_add_a : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
    SIGNAL ram_add_b : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);

    
    ------------------------------------------------
    --- QuadratureDecoder
    ------------------------------------------------
    SIGNAL xposition : INTEGER RANGE 0 TO mx_ppline - 1;
    SIGNAL yposition : INTEGER RANGE 0 TO mx_lines - 1;
    SIGNAL red_color, green_color, blue_color : INTEGER RANGE 0 TO 2 ** enc_depth - 1;

    ------------------------------------------
    -------- MemController
    ------------------------------------------
    SIGNAL mem_ctrl_wren_a, mem_ctrl_wren_b : STD_LOGIC;
    SIGNAL mem_ctrl_add_a : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);

    -------------------------------------------------
    ------ ram
    -------------------------------------------------
    SIGNAL red1_color, red2_color, green1_color, green2_color, blue1_color, blue2_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    --------------------------------------------------
    ------ backup ram
    --------------------------------------------------
    SIGNAL backup_red_ram_data_a, backup_green_ram_data_a, backup_blue_ram_data_a : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL backup_red_ram_data_b, backup_green_ram_data_b, backup_blue_ram_data_b : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    --------------------------------------------------
    ------ MemoryReset
    --------------------------------------------------
    SIGNAL is_resetting : STD_LOGIC;
    SIGNAL reset_ram_add_a, reset_ram_add_b : STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(mx_lines * mx_ppline)))) - 1 DOWNTO 0);
    ---------------------------------------------------
    ----- gamma
    ---------------------------------------------------
    SIGNAL gamma_red1_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL gamma_red2_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL gamma_green1_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL gamma_green2_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL gamma_blue1_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);
    SIGNAL gamma_blue2_color : STD_LOGIC_VECTOR(enc_depth - 1 DOWNTO 0);

    -------------------------------------------------
    ------ components
    -------------------------------------------------

    COMPONENT QuadratureDecoder IS
        GENERIC (
            positions : INTEGER := 16;
            debounce_time : INTEGER := 50_000;
            reset_value : INTEGER := 4;
            set_origin_debounce_time : INTEGER := 500_000);
        PORT (
            clk : IN STD_LOGIC;
            a : IN STD_LOGIC;
            b : IN STD_LOGIC;
            set_origin_n : IN STD_LOGIC;
            direction : OUT STD_LOGIC;
            position : BUFFER INTEGER RANGE 0 TO positions - 1 := 0);
    END COMPONENT;

    COMPONENT MemController IS GENERIC (
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
    END COMPONENT;

    COMPONENT hlsm IS GENERIC (
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
    END COMPONENT;

    
    COMPONENT RedRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT GreenRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT BlueRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT BackupRedRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT BackupGreenRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;
    COMPONENT BackupBlueRAM IS PORT (
        address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        clock : IN STD_LOGIC := '1';
        data_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_a : IN STD_LOGIC := '0';
        wren_b : IN STD_LOGIC := '0';
        q_a : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        q_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );

    END COMPONENT;
    COMPONENT pll IS PORT (
        areset : IN STD_LOGIC := '0';
        inclk0 : IN STD_LOGIC := '0';
        c0 : OUT STD_LOGIC;
        locked : OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT pwm IS

        GENERIC (mx_enc_depth : INTEGER := 8);

        PORT (
            mx_clock : IN STD_LOGIC;
            cnt_pwm : IN STD_LOGIC_VECTOR(mx_enc_depth - 1 DOWNTO 0);
            color_cp : IN STD_LOGIC_VECTOR(mx_enc_depth - 1 DOWNTO 0);
            color_cpm : OUT STD_LOGIC
        );

    END COMPONENT;

    COMPONENT GammaCorrection IS PORT (
        color_cp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        output_color : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT MemoryReset IS
        GENERIC (
            address_bus_width : INTEGER
        );
        PORT (
            clk : IN STD_LOGIC;
            start : IN STD_LOGIC;
            in_progress : OUT STD_LOGIC;
            memory_add_a : OUT STD_LOGIC_VECTOR(address_bus_width - 1 DOWNTO 0);
            memory_add_b : OUT STD_LOGIC_VECTOR(address_bus_width - 1 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    ar <= global_ar OR NOT pll_locked;
    std_red_color <= STD_LOGIC_VECTOR(to_unsigned(red_color, enc_depth));
    std_green_color <= STD_LOGIC_VECTOR(to_unsigned(green_color, enc_depth));
    std_blue_color <= STD_LOGIC_VECTOR(to_unsigned(blue_color, enc_depth));

    ------------------------------------------
    -- pll
    ------------------------------------------
    pll_inst : pll PORT MAP
    (
        areset => global_ar,
        inclk0 => clock_50,
        c0 => clock_4,
        locked => pll_locked
    );
    ------------------------------------------
    -- hlsm
    ------------------------------------------
    hlsm_inst : hlsm
    GENERIC MAP(
        mx_lines => mx_lines,
        mx_ppline => mx_ppline,
        mx_enc_depth => enc_depth
    )
    PORT MAP
    (
        ar => ar OR is_resetting,
        clock => clock_4,
        mx_LE => mx_LE,
        mx_OE => mx_OE,
        mx_clock => matrix_clock,
        mx_CBA => mx_CBA,
        ram_add_t => hlsm_add_a,
        ram_add_b => ram_add_b,
        pwm_cnt => pwm_cnt,
        end_frame => end_frame
    );

    ------------------------------------------
    -- XPOSITION
    ------------------------------------------
    xposition_inst : QuadratureDecoder
    GENERIC MAP(
        positions => mx_ppline,
        reset_value => mx_ppline / 2 - 1,
        debounce_time => debounce_time,
        set_origin_debounce_time => debounce_time)
    PORT MAP(
        clk => clock_4,
        a => xre_clk,
        b => xre_dt,
        set_origin_n => NOT ar AND NOT is_resetting,
        direction => OPEN,
        position => xposition);

    ------------------------------------------
    -- YPOSITION
    ------------------------------------------
    yposition_inst : QuadratureDecoder
    GENERIC MAP(
        positions => mx_lines,
        reset_value => mx_lines / 2 - 1,
        debounce_time => debounce_time,
        set_origin_debounce_time => debounce_time)
    PORT MAP(
        clk => clock_4,
        a => yre_clk,
        b => yre_dt,
        set_origin_n => NOT ar AND NOT is_resetting,
        direction => OPEN,
        position => yposition);

    ------------------------------------------
    -- REDCOLOR
    ------------------------------------------
    rposition_inst : QuadratureDecoder
    GENERIC MAP(
        positions => 2 ** enc_depth,
        reset_value => 255,
        debounce_time => debounce_time,
        set_origin_debounce_time => debounce_time)
    PORT MAP(
        clk => clock_4,
        a => redre_clk,
        b => redre_dt,
        set_origin_n => NOT ar AND NOT is_resetting,
        direction => OPEN,
        position => red_color);
    ------------------------------------------
    -- GREENCOLOR
    ------------------------------------------
    gposition_inst : QuadratureDecoder
    GENERIC MAP(
        positions => 2 ** enc_depth,
        reset_value => 255,
        debounce_time => debounce_time,
        set_origin_debounce_time => debounce_time)
    PORT MAP(
        clk => clock_4,
        a => greenre_clk,
        b => greenre_dt,
        set_origin_n => NOT ar AND NOT is_resetting,
        direction => OPEN,
        position => green_color);
    ------------------------------------------
    -- BLUECOLOR
    ------------------------------------------
    bposition_inst : QuadratureDecoder
    GENERIC MAP(
        positions => 2 ** enc_depth,
        reset_value => 0,
        debounce_time => debounce_time,
        set_origin_debounce_time => debounce_time)
    PORT MAP(
        clk => clock_4,
        a => bluere_clk,
        b => bluere_dt,
        set_origin_n => NOT ar AND NOT is_resetting,
        direction => OPEN,
        position => blue_color);
    -------------------------------------------
    ----- MemController
    -------------------------------------------

    MemController_inst : MemController
    GENERIC MAP(
        mx_lines => mx_lines,
        mx_ppline => mx_ppline
    )
    PORT MAP(
        fl => end_frame,
        is_resetting => is_resetting,
        xposition => xposition,
        yposition => yposition,
        add_a => mem_ctrl_add_a,
        wren_a => mem_ctrl_wren_a,
        wren_b => mem_ctrl_wren_b
    );

    

    ------------------------------------------
    -- RAM
    ------------------------------------------
    RedRam_inst : RedRAM PORT MAP(
        address_a => final_ram_add_t,
        address_b => final_ram_add_b,
        clock => clock_4,
        data_a => final_std_red_color,
        data_b => backup_red_ram_data_b,
        wren_a => mem_ctrl_wren_a,
        wren_b => mem_ctrl_wren_b,
        q_a => red1_color,
        q_b => red2_color
    );

    GreenRam_inst : GreenRAM PORT MAP(
        address_a => final_ram_add_t,
        address_b => final_ram_add_b,
        clock => clock_4,
        data_a => final_std_green_color,
        data_b => backup_green_ram_data_b,
        wren_a => mem_ctrl_wren_a,
        wren_b => mem_ctrl_wren_b,
        q_a => green1_color,
        q_b => green2_color
    );

    BlueRam_inst : BlueRAM PORT MAP(
        address_a => final_ram_add_t,
        address_b => final_ram_add_b,
        clock => clock_4,
        data_a => final_std_blue_color,
        data_b => backup_blue_ram_data_b,
        wren_a => mem_ctrl_wren_a,
        wren_b => mem_ctrl_wren_b,
        q_a => blue1_color,
        q_b => blue2_color
    );

    ------------------------------------------
    -- GammaCorrection
    ------------------------------------------
    red1_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => red1_color,
        output_color => gamma_red1_color
    );

    green1_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => green1_color,
        output_color => gamma_green1_color
    );

    blue1_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => blue1_color,
        output_color => gamma_blue1_color
    );

    red2_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => red2_color,
        output_color => gamma_red2_color
    );

    green2_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => green2_color,
        output_color => gamma_green2_color
    );

    blue2_GammaCorrection_inst : GammaCorrection PORT MAP(
        color_cp => blue2_color,
        output_color => gamma_blue2_color
    );
    --------------------------------------------
    -- pwm
    --------------------------------------------
    red1_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_red1_color,
        color_cpm => mx_R1);

    green1_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_green1_color,
        color_cpm => mx_V1);

    blue1_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_blue1_color,
        color_cpm => mx_B1);

    red2_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_red2_color,
        color_cpm => mx_R2);

    green2_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_green2_color,
        color_cpm => mx_V2);

    blue2_pwm_inst : pwm GENERIC MAP(
        mx_enc_depth => enc_depth)
    PORT MAP(
        mx_clock => matrix_clock,
        cnt_pwm => pwm_cnt,
        color_cp => gamma_blue2_color,
        color_cpm => mx_B2);

    ----------------------------
    -- MemoryReset
    ----------------------------
    MemoryReset_inst : MemoryReset GENERIC MAP(
        address_bus_width => INTEGER(ceil(log2(real(mx_lines * mx_ppline))))
    )
    PORT MAP(
        clk => clock_4,
        start => ar,
        in_progress => is_resetting,
        memory_add_a => reset_ram_add_a,
        memory_add_b => reset_ram_add_b
    );

    -------------------------------
    --- BackupRAMs
    -------------------------------
    BackupRedRam_inst : BackupRedRAM PORT MAP(
        address_a => reset_ram_add_a,
        address_b => reset_ram_add_b,
        clock => clock_4,
        data_a => (others => '0'),
        data_b => (others => '0'),
        wren_a => '0',
        wren_b => '0',
        q_a => backup_red_ram_data_a,
        q_b => backup_red_ram_data_b
    );
    BackupGreenRam_inst : BackupGreenRAM PORT MAP(
        address_a => reset_ram_add_a,
        address_b => reset_ram_add_b,
        clock => clock_4,
        data_a => (others => '0'),
        data_b => (others => '0'),
        wren_a => '0',
        wren_b => '0',
        q_a => backup_green_ram_data_a,
        q_b => backup_green_ram_data_b
    );
    BackupBlueRam_inst : BackupBlueRAM PORT MAP(
        address_a => reset_ram_add_a,
        address_b => reset_ram_add_b,
        clock => clock_4,
        data_a => (others => '0'),
        data_b => (others => '0'),
        wren_a => '0',
        wren_b => '0',
        q_a => backup_blue_ram_data_a,
        q_b => backup_blue_ram_data_b
    );


    mx_clock <= matrix_clock;
    final_ram_add_t <= reset_ram_add_a WHEN is_resetting = '1' ELSE
        mem_ctrl_add_a WHEN end_frame = '1' ELSE
        hlsm_add_a;
    final_ram_add_b <= reset_ram_add_b WHEN is_resetting ='1' ELSE
        ram_add_b;

    final_std_red_color <= backup_red_ram_data_a WHEN is_resetting = '1' ELSE
        std_red_color;

    final_std_green_color <= backup_green_ram_data_a WHEN is_resetting = '1' ELSE
        std_green_color;

    final_std_blue_color <= backup_blue_ram_data_a WHEN is_resetting = '1' ELSE
        std_blue_color;
END ARCHITECTURE;