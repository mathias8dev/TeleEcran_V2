vcom -reportprogress 300 -work work C:/Users/pret/Documents/Code/Electronics/TeleEcran_V2/simulation/modelsim/TeleEcran_tb.vhd
vsim work.TeleEcran_tb
add wave TeleEcran_tb/clock_50
add wave TeleEcran_tb/global_ar
add wave TeleEcran_tb/TeleEcran_inst/clock_4
add wave TeleEcran_tb/TeleEcran_inst/pll_locked
add wave TeleEcran_tb/mx_clock
add wave TeleEcran_tb/mx_LE
add wave TeleEcran_tb/mx_OE
add wave TeleEcran_tb/mx_CBA
add wave TeleEcran_tb/TeleEcran_inst/mx_R1
add wave TeleEcran_tb/TeleEcran_inst/mx_R2
add wave TeleEcran_tb/TeleEcran_inst/mx_V1
add wave TeleEcran_tb/TeleEcran_inst/mx_V2
add wave TeleEcran_tb/TeleEcran_inst/mx_B1
add wave TeleEcran_tb/TeleEcran_inst/mx_B2
add wave TeleEcran_tb/TeleEcran_inst/xre_clk
add wave TeleEcran_tb/TeleEcran_inst/xre_dt
add wave TeleEcran_tb/TeleEcran_inst/yre_clk
add wave TeleEcran_tb/TeleEcran_inst/yre_dt
add wave TeleEcran_tb/TeleEcran_inst/redre_clk
add wave TeleEcran_tb/TeleEcran_inst/redre_dt
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/cnt
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/cnt_pwm
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/cnt_pwm_next
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/cnt_next
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/pixel
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/ram_add
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/ram_add_next
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/lines
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/lines_next
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/state
add wave TeleEcran_tb/TeleEcran_inst/hlsm_inst/end_frame

add wave TeleEcran_tb/TeleEcran_inst/red1_color
add wave TeleEcran_tb/TeleEcran_inst/red1_pwm_inst/color_cp
add wave TeleEcran_tb/TeleEcran_inst/red1_pwm_inst/color_cpm

add wave TeleEcran_tb/TeleEcran_inst/green1_color
add wave TeleEcran_tb/TeleEcran_inst/green1_pwm_inst/color_cp
add wave TeleEcran_tb/TeleEcran_inst/green1_pwm_inst/color_cpm


add wave TeleEcran_tb/TeleEcran_inst/blue1_color
add wave TeleEcran_tb/TeleEcran_inst/blue1_pwm_inst/color_cp
add wave TeleEcran_tb/TeleEcran_inst/blue1_pwm_inst/color_cpm


add wave TeleEcran_tb/TeleEcran_inst/MemController_inst/fl
add wave TeleEcran_tb/TeleEcran_inst/MemController_inst/xposition
add wave TeleEcran_tb/TeleEcran_inst/MemController_inst/yposition
add wave TeleEcran_tb/TeleEcran_inst/MemController_inst/add_a
add wave TeleEcran_tb/TeleEcran_inst/MemController_inst/wren_a


add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/clk
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/a
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/b
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/set_origin_n
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/position
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/a_prev
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/b_prev
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/a_new
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/b_new
add wave TeleEcran_tb/TeleEcran_inst/xposition_inst/direction

add wave TeleEcran_tb/TeleEcran_inst/yposition_inst/clk
add wave TeleEcran_tb/TeleEcran_inst/yposition_inst/a
add wave TeleEcran_tb/TeleEcran_inst/yposition_inst/b
add wave TeleEcran_tb/TeleEcran_inst/yposition_inst/set_origin_n
add wave TeleEcran_tb/TeleEcran_inst/yposition_inst/position


run 8 ms

radix -unsigned