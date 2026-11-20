`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    	reg [5:0] code;
	reg resetn;
    	reg CLOCK_50;
	wire [3:0] tool;

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
	#20 code <= 6'b010110; //brush
    	#20 code <= 6'b011110; //erase
	#20 code <= 6'b100110; //line
	#20 code <= 6'b100101; //paint bucket
	end // initial
	test_tool_fsm U1 (code, CLOCK_50, resetn, tool);

endmodule