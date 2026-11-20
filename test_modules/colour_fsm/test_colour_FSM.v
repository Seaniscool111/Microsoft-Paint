// =========== COLOUR FSM =============
// will output the COLOUR TO BE WRITTEN TO THE VGA 
module colour_FSM (code, Clock, Resetn, y_Q, y_D, Colour);
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