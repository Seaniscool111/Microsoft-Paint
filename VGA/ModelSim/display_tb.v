`timescale 1ns / 1ps

module display_tb();

    parameter CLOCK_PERIOD = 20; // 50 MHz clock has a 20ns period

    reg [9:0] SW;
    reg [3:0] KEY; // ON, OFF, RESET
    reg CLOCK_50;
    
	 
	 // Outputs
	 wire [9:0] VGA_X;
	wire [8:0] VGA_Y;
	wire [23:0] VGA_COLOR;
	wire plot;
	
	
	// Clock generator (from prof's labs)
	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	// Reset
	initial begin
        KEY[0] <= 1'b0;
        #10 KEY[0] <= 1'b1;
	end // initial

	
	display U1 (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .VGA_COLOR(VGA_COLOR),
        .plot(plot)
    );

endmodule
