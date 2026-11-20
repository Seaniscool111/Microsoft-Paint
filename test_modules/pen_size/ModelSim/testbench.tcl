# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../test_pen_size.v
# compile the Verilog code of the testbench
vlog pen_size_tb.v
# start the Simulator, including some libraries that may be needed
vsim work.pen_size_tb -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 200 ns