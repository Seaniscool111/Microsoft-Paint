# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work

# Compile all Verilog files in the parent folder and the vga_adapter subfolder
vlog ../../brush_renderer.v
vlog brush_tb.v

# Compile the testbench in the current ModelSim folder
vlog *brush_tb.v

# Start simulation 
vsim work.brush_tb -Lf 220model -Lf altera_mf_ver -Lf verilog

# Add all signals to the waveform automatically (if you don't have a wave.do yet)
add wave /brush_tb/clk
add wave /brush_tb/go
add wave -radix unsigned /brush_tb/size
add wave /brush_tb/UUT/y_Q
add wave /brush_tb/UUT/Y_D
add wave -radix unsigned /brush_tb/UUT/xc
add wave -radix unsigned /brush_tb/UUT/yc
add wave /brush_tb/write

# Run long enough to see multiple clock cycles (20ns per cycle)
run 500 ns
