`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    	reg [6:0] code;
	reg resetn;
    	reg CLOCK_50;
    	//wire [8:0] LEDR;
	wire [8:0] colour;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
        resetn <= 1'b0;
        #10 resetn <= 1'b1;
	end // initial

	initial begin
	#20 code <= 7'b1101001; //black
        #20 code <= 7'b1110010; //red
	#20 code <= 7'b1111010; // blue
	#20 code <= 7'b1101011; // green
	#20 code <= 7'b1110011; // white
	end // initial
	test_colour_fsm U1 (code, CLOCK_50, resetn, colour);

endmodule