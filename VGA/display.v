module display(CLOCK_50, SW, KEY, LEDR, mouse_x, mouse_y, mouse_click, Color, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	input CLOCK_50;
	input [9:0] SW;    			// COLOUR for now
	input [3:0] KEY;				// KEY[0] reset, KEY[1] Draw Click
	
	// Mouse Inputs
	input [9:0] mouse_x; 		// X-coord input from PS/2
	input [8:0] mouse_y;			// Y-coord input from PS/2
	input mouse_click;			// Enable for drawing
	input [3:0] Color;
	
	// Board Feedback & VGA Outputs
	output wire [9:7] LEDR;
	output [7:0] VGA_R, VGA_G, VGA_B;
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
	
	
	// Wires for brush_renderer
	wire [9:0] brush_x;
	wire [8:0] brush_y;
	wire brush_write;
    
	// RESET ALL
	wire sys_resetn = SW[9];


	// ==========================================
   // 				PEN SIZE MODULE
   // ==========================================
	wire [2:0] current_size;
	wire [2:0] size_led_wires;

	
	pen_size PEN(
		.up(KEY[0]),          // CHANGE LATER TO KEYBOARD ARROW
		.down(KEY[1]),		    // CHANGE LATER TO KEYBOARD ARROW
		.Clock(CLOCK_50),
		.Resetn(sys_resetn), 		// CHANGE THIS LATER TO PROPER KEY
		.z(size_led_wires),
		.size_val(current_size)		
	);

	// Connect to FPGA
	assign LEDR[9:7] = size_led_wires;
	
    // ==========================================
    // 					BRUSH RENDERER
    // ==========================================
	brush_renderer B (
		.clk(CLOCK_50),
		.resetn(sys_resetn),       	// Not resetting white 
		.go(~KEY[2]),      			// (dummy mouse click)
		.center_x(10'd320), 		// DUMMY X-Coordinate Middle   --- CHANGE TO MOUSE INPUT X (mouse_x)
		.center_y(9'd240), 			// DUMMY Y-Coordinate Middle   --- CHANGE TO MOUSE INPUT Y (mouse_y)
		.size(current_size), 				//(start with a fixed 3x3 brush to test, or SW[5:3])
		.vga_x(brush_x),
		.vga_y(brush_y),
		.write(brush_write));
	
	//
	vga_adapter A (
		.clock(CLOCK_50),
		.resetn(sys_resetn),
		.color(SW[2:0]),
		.x(brush_x), 			
		.y(brush_y), 			
		.write(brush_write),		
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	
	// Forcing vga_adapter variables to be this (changed already though)
	defparam A.RESOLUTION = "640x480";
	defparam A.BACKGROUND_IMAGE = "./MIF/white_640x480.mif";
	defparam A.COLOR_DEPTH = 3;
		
endmodule



