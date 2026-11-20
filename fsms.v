module milestone1(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
endmodule

module pen_size (up, down Clock, Resetn, LEDR, y_Q, y_D);
	input up, down, Resetn;
	input Clock;
	output [9:7] LEDR;
	reg [1:0] y_Q, Y_D;
	parameter size1 = 2'b00, size2 = 2'b01, size2 = 2'b10;
	
	always @ (*)
		case (y_Q)
			size1: 	if 		(up == 1) 	Y_D = size2;
					else if (down == 1) Y_D = size1;
					else 				Y_D = size1;

			size2: 	if 	(up == 1) 		Y_D = size3;
				   	else (down == 1)    Y_D = size1;
				   	else				Y_D = size2;

			size3: 	if 		(up == 1) 	Y_D = size3;
					else if (down == 1) Y_D = size2;
					else 				Y_D = size3;

			default: Y_D = size2;
		endcase
	
	// ======== STATE FFS ============
	always @ (posedge Clock)
		if (!Resetn)
			y_Q <= A;
		else 
			y_Q <= Y_D;
	
 // ======== show pen size on the LEDR ==========	
	always @ (*) begin
		LEDR[9:7] = 3'b000;
		if (y_Q == size1) LEDR[9] = 1'b1;
		if (y_Q == size2) LEDR[8] = 1'b1;
		if (y_Q == size3) LEDR[7] = 1'b1;
	end
		
endmodule

// =========== COLOUR FSM =============
// will output the COLOUR TO BE WRITTEN TO THE VGA 
module colourFSM (code, Clock, Resetn, y_Q, y_D, Colour);
	input [6:0] code; // colour is an input thatis 7 bit binary correspnding to the key pressed
	input Clock;
	input Resetn;
	reg [2:0] y_Q; // current state
	reg [2:0] y_D; // next state
	output reg [8:0] Colour; // outputs a 9 bit colour value that the vga will use
						// 3 bits for r, g, and b
	parameter: Black = 3'b000, Red = 3'b001, Blue = 3'b010, Green = 3'b011, White = 3'b100;

	always @ (*) begin
		case (code)
			Black: 	if 		(code == 7'b1110010) 	y_D = Red;
					else if (code == 7'b1111010) 	y_D = Blue;
					else if (code == 7'b1101011) 	y_D = Green;
					else if (code == 7'b1110011) 	y_D = White;
					else 							y_D = Black;

			Red: 	if 		(code == 7'b1111010) 	y_D = Blue;
					else if (code == 7'b1101011) 	y_D = Green;
					else if (code == 7'b1110011) 	y_D = White;
					else if (code == 7'b1101001) 	y_D = Black;
					else 							y_D = Red;

			Blue: 	if 		(code == 7'b1101011) 	y_D = Green;
					else if (code == 7'b1110011) 	y_D = White;
					else if (code == 7'b1101001) 	y_D = Black;
					else if (code == 7'b1110010) 	y_D = Red;
					else 							y_D = Blue;

			Green: 	if 		(code == 7'b1110011) 	y_D = White;
					else if (code == 7'b1101001) 	y_D = Black;
					else if (code == 7'b1110010) 	y_D = Red;
					else if (code == 7'b1111010) 	y_D = Blue;
					else 							y_D = Green;

			White: 	if 		(code == 7'b1101001) 	y_D = Black;
					else if (code == 7'b1110010) 	y_D = Red;
					else if (code == 7'b1111010) 	y_D = Blue;
					else if (code == 7'b1101011) 	y_D = Green;
					else 							y_D = White;
			default: Y_D = White;
		endcase
	end

	// state ffs
	always @ (posedge Clock) begin
		if (!Resetn) begin
			y_Q <= White; // by default
		end
		else begin
			y_Q <= y_D;
		end
	end

	// fsm outputs
	always @ (*) begin
		Colour = 9'b111_111_111; // white by default
		if (y_Q == Black) Colour = 9'b000_000_000;
		if (y_Q == Red) Colour = 9'b111_000_000;
		if (y_Q == Blue) Colour = 9'b000_000_111;
		if (y_Q == Green) Colour = 9'b000_111_000;
		if (y_Q == White) Colour = 9'111_111_111;
	end

endmodule

// =========== TOOL FSMS ==============
module toolFSM (code, Clock, Resetn, y_Q, Y_D, Tool);
	input [5:0] code; // up to 6 bits needed for tool codes
	input Clock;
	input Resetn;
	reg y_Q;
	reg Y_D;
	output reg [3:0] Tool; // BIT 0 = BRUSH, BIT 1 = ERASE, BIT 2 = LINE, BIT 3 = PAINT
	parameter: Brush = 2'b00, Erase = 2'b01, Line = 2'b10, Paint_Bucket = 2'b11;

	always @ (*) begin
		case (code)
			Brush: 	if 		(code == 6'b011110) Y_D = Erase;
					else if (code == 6'b100110) Y_D = Line;
					else if (code == 6'b100101) Y_D = Paint_Bucket;
					else 						Y_D = Brush;
					
			Erase: 	if 		(code == 6'b100110) Y_D = Line;
					else if (code == 6'b100101) Y_D = Paint_Bucket;
					else if (code == 6'b010110) Y_D = Brush;
					else 						Y_D = Erase;	

			Line: 	if 		(code == 6'b100101) Y_D = Paint_Bucket;
					else if (code == 6'b010110) Y_D = Brush;
					else if (code == 6'b011110) Y_D = Erase;
					else 						Y_D = Line;	

			Paint_Bucket: if 	(code == 6'b010110) Y_D = Brush;
						else if (code == 6'b011110) Y_D = Erase;
						else if (code == 6'b100110) Y_D = Line;
						else 						Y_D = Paint_Bucket;	
			default: Y_D = Brush;		
		endcase
	end

	// state ffs
	always @ (posedge Clock) begin
		if (Resetn) begin
			y_Q <= Brush;
		end
		else begin
			y_Q <= Y_D;
		end
	end

	// assign fsm outputs
	always @ (*) begin
		Tool = 4'b0001;
		if (y_Q == Brush) 			Tool = 4'b0001;
		if (y_Q == Erase) 			Tool = 4'b0010;
		if (y_Q == Line) 			Tool = 4'b0100;
		if (y_Q == Paint_Bucket) 	Tool = 4'b1000;
	end
endmodule

// COLOURARBRITER SHOULD FOLLOW THE SAME LOGIC AS TOOLS FSM
module colourArbiterFSM (R, Clock, Resetn, y_Q, y_D, Output);
	input [4:0] R; // 5 request signals
	input Clock;
	input Resetn;
	output reg y_Q, Y_D;
	output reg [3:0] Output;
	parameter: Black = 3'b000, Red = 3'b001, Blue = 3'b010, Green = 3'b011, White = 3'b100;
	
	always @ (*)
		case (y_Q)
			Black: if (R[0]) Y_D = Black;
					 else if (R[1]) Y_D = Red;
					 else if (R[2]) Y_D = Blue;
					 else if (R[3]) Y_D = Green;
					 else if (R[4]) Y_D = White;
					 else 			 Y_D = Black;
			Red: if (R[0]) Y_D = Black;
					 else if (R[1]) Y_D = Red;
					 else if (R[2]) Y_D = Blue;
					 else if (R[3]) Y_D = Green;
					 else if (R[4]) Y_D = White;
					 else 			 Y_D = Black;
			Blue: if (R[0]) Y_D = Black;
					 else if (R[1]) Y_D = Red;
					 else if (R[2]) Y_D = Blue;
					 else if (R[3]) Y_D = Green;
					 else if (R[4]) Y_D = White;
					 else 			 Y_D = Black;
			Green: if (R[0]) Y_D = Black;
					 else if (R[1]) Y_D = Red;
					 else if (R[2]) Y_D = Blue;
					 else if (R[3]) Y_D = Green;
					 else if (R[4]) Y_D = White;
					 else 			 Y_D = Black;
			White: if (R[0]) Y_D = Black;
					 else if (R[1]) Y_D = Red;
					 else if (R[2]) Y_D = Blue;
					 else if (R[3]) Y_D = Green;
					 else if (R[4]) Y_D = White;
					 else 			 Y_D = Black;
			default: Y_D = Black;
		endcase
		
		always @ (posedge Clock)
			if (!Resetn)
				y_Q <= Black;
			else
				y_Q <= Y_D;

/// TESTING		sss
		
		// FSM OUTPUTS
		always @ (*) begin
			Output = 4'b0000; // 4 bits to work with seg7Hex
			if (y_Q == Black) Output = 4'b0000; // 1 ON THE HEX DISPLAY
			if (y_Q == Red) Output = 4'b0001; // 2 ON THE HEX DISPLAY
			if (y_Q == Blue) Output = 4'b0010; // 3 ON THE HEX DISPLAY
			if (y_Q == Green) Output = 4'b0011; // 4 ON THE HEX DISPLAY
			if (y_Q == White) Output = 4'b0100; // 5 ON THE HEX DISPLAY
		end
	
endmodule

module seg7Hex (x, Display);
	input [3:0] x; // input is a 4 bit hex
	output reg [6:0] Display;
	
	// look at when each segment is on
	
	always @(*) begin
		case(x)
		// 4 bit hex, then display will show:
		4'h0: Display = 7'b1000000;
		4'h1: Display = 7'b1111001;
		4'h2: Display = 7'b0100100;
		4'h3: Display = 7'b0110000;
		4'h4: Display = 7'b0011001;
		4'h5: Display = 7'b0010010;
		4'h6: Display = 7'b0000010;
		4'h7: Display = 7'b1111000;
		4'h8: Display = 7'b0000000;
		4'h9: Display = 7'b0011000;
		4'hA: Display = 7'b0001000;
		4'hB: Display = 7'b0000011;
		4'hC: Display = 7'b1000110;
		4'hD: Display = 7'b0100001;
		4'hE: Display = 7'b0000110;
		4'hF: Display = 7'b0001110;
		endcase
	end
endmodule
	