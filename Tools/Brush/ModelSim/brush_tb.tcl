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
do wave.do

# Run long enough to see multiple clock cycles (20ns per cycle)
run 500 ns
