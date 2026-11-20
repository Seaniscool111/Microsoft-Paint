`timescale 1ns / 1ps

module brush_tb ( );

	parameter CLOCK_PERIOD = 20;

    reg clk;
    reg resetn;
    reg go;
    reg [9:0] center_x;
    reg [8:0] center_y;
    reg [2:0] size;
    wire [9:0] vga_x;
    wire [8:0] vga_y;
    wire write;

	initial begin
        clk <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) clk <= ~clk;
	end
	
	initial begin
        // Initialize inputs and assert reset
        resetn <= 1'b0; go <= 1'b0; center_x <= 10'd320; center_y <= 9'd240; size <= 3'd1;
        #20 resetn <= 1'b1; // Release reset

        // TEST CASE 1: 1x1 dot in the middle
        #20 go <= 1'b1; #20 go <= 1'b0;

        // TEST CASE 2: 2x2 brush stamp
        #100 size <= 3'd2;
        #20 go <= 1'b1; #20 go <= 1'b0;
        #200 $stop;
	end // initial
	brush_renderer UUT (clk, resetn, go, center_x, center_y, size, vga_x, vga_y, write);

endmodule