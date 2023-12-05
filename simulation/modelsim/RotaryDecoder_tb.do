vcom -reportprogress 300 -work work C:/Users/pret/Documents/Code/Electronics/TeleEcran/simulation/modelsim/RotaryDecoder_tb.vhd
vsim -gui -l msim_transcript work.RotaryDecoder_tb
add wave RotaryDecoder_tb/rst
add wave RotaryDecoder_tb/clk
add wave RotaryDecoder_tb/a
add wave RotaryDecoder_tb/b
add wave RotaryDecoder_tb/posi
add wave RotaryDecoder_tb/RotaryDecoder_inst/reg_ena
add wave RotaryDecoder_tb/RotaryDecoder_inst/posi_ena
add wave RotaryDecoder_tb/RotaryDecoder_inst/posi_int
add wave RotaryDecoder_tb/RotaryDecoder_inst/dir_int

run 6000ms
