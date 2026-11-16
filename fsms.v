module milestone1(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
endmodule

module pen_size (w, Clock, Resetn, LEDR, y_Q, y_D);
	input w, Resetn;
	input Clock;
	output [9:7] LEDR;
	output reg y_Q, Y_D;
	parameter A = 2'b00, B = 2'b01, C = 2'b10;
	
	always @ (*)
		case (y_Q)
			A: if (w = 1) Y_D = B;
				else       Y_D = A;
			B: if (w = 1) Y_D = C;
				else       Y_D = A;
			C: if (w = 1) Y_D = C;
				else       Y_D = B;
			default: Y_D = B;
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
		if (y_Q == A) LEDR[9] = 1'b1;
		if (y_Q == B) LEDR[8] = 1'b1;
		if (y_Q == C) LEDR[7] = 1'b1;
	end
		
endmodule


module colourArbiterFSM (R, Clock, Resetn, y_Q, y_D, Output);
	input [4:0] R; // 5 request signals
	input Clock;
	input Resetn;
	output reg y_Q, Y_D;
	output [3:0] Output;
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
	