vcom -reportprogress 300 -work work C:/Users/pret/Documents/Code/Electronics/TeleEcran/simulation/modelsim/QuadratureDecoder_tb.vhd
vsim -gui -l msim_transcript work.QuadratureDecoder_tb
add wave QuadratureDecoder_tb/ar
add wave QuadratureDecoder_tb/clk
add wave QuadratureDecoder_tb/re_clk
add wave QuadratureDecoder_tb/dt
add wave QuadratureDecoder_tb/dir
add wave QuadratureDecoder_tb/update
add wave QuadratureDecoder_tb/position
add wave QuadratureDecoder_tb/QuadratureDecoder_inst/a_prev
add wave QuadratureDecoder_tb/QuadratureDecoder_inst/b_prev
add wave QuadratureDecoder_tb/QuadratureDecoder_inst/a_new
add wave QuadratureDecoder_tb/QuadratureDecoder_inst/b_new
add wave QuadratureDecoder_tb/QuadratureDecoder_inst/direction_position_enable

run 600ms
