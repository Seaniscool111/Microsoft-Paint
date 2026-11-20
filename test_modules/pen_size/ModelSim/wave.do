onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk -radix binary /brush_tb/clk
add wave -noupdate -label go -radix binary /brush_tb/go
add wave -noupdate -label size -radix unsigned /brush_tb/size
add wave -noupdate -label y_Q /brush_tb/UUT/y_Q
add wave -noupdate -label Y_D /brush_tb/UUT/Y_D
add wave -noupdate -label xc -radix unsigned /brush_tb/UUT/xc
add wave -noupdate -label yc -radix unsigned /brush_tb/UUT/yc
add wave -noupdate -label write -radix binary /brush_tb/write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {120 ns}