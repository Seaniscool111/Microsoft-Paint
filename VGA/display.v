module display(CLOCK_50, SW, KEY, mouse_x, mouse_y, mouse_click, Color, VGA_X, VGA_Y, VGA_COLOR, plot);
	input CLOCK_50;
	
	input [9:0] SW;    			// COLOUR for now
	input [3:0] KEY;				// KEY[0] reset, KEY[1] Draw Click
	input [9:0] mouse_x; 		// X-coord input from PS/2
	input [8:0] mouse_y;			// Y-coord input from PS/2
	input mouse_click;			// Enable for drawing
	input [3:0] Color;
	
	
	output [9:0] VGA_X;
	output [8:0] VGA_Y;
	output [23:0] VGA_COLOR;
	output plot;
	

	wire vga_sync;
	
	
	
	vga_adapter A (
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.color(SW[2:0]),
		.x(10'd320), 			// X-Coordinate Middle   --- CHANGE TO MOUSE INPUT X (mouse_x)
		.y(9'd240), 			// Y-Coordinate Middle   --- CHANGE TO MOUSE INPUT Y (mouse_y)
		.write(~KEY[1]),		// DUMMY for mouse click
		.VGA_X(VGA_X),       
		.VGA_Y(VGA_Y),			
		.VGA_COLOR(VGA_COLOR),		
		.VGA_SYNC(vga_sync),
		.plot(plot));
	
	// Forcing vga_adapter variables to be this (changed already though)
	defparam A.RESOLUTION = "640x480";
	defparam A.BACKGROUND_IMAGE = "./MIF/white_640x480.mif";
	defparam A.COLOR_DEPTH = 3;
		
endmodule



