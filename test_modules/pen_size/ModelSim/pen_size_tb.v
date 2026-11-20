`timescale 1ns / 1ps

module pen_size_tb ( );

	parameter CLOCK_PERIOD = 20;

    reg up;
    reg down;
    reg Clock;
    reg Resetn;
    wire [2:0] z;

	initial begin
        Clock <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) Clock <= ~Clock;
	end
	
	initial begin
		  // Initialize & Reset (Resets to size2, z = 3'b010)
        Resetn <= 1'b0; up <= 1'b1; down <= 1'b1;
        #20 Resetn <= 1'b1;
		  
		  // Test up (size2 -> size3, z = 3'b001)
        #20 up <= 1'b0; #20 up <= 1'b1;
		  
		  // Test down twice (size3 -> size2)  
        #20 down <= 1'b0; #20 down <= 1'b1;
        #40 $stop;
	end // initial
	pen_size UUT (up, down, Clock, Resetn, z);

endmodule