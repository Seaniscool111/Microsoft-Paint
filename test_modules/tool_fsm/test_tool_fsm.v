// =========== TOOL FSMS ==============
module test_tool_fsm (code, Clock, Resetn, Tool);
	input [5:0] code; // up to 6 bits needed for tool codes
	input Clock;
	input Resetn;
	reg [2:0] y_Q;
	reg [2:0] Y_D;
	output reg [3:0] Tool; // BIT 0 = BRUSH, BIT 1 = ERASE, BIT 2 = LINE, BIT 3 = PAINT
	parameter Brush = 2'b00, Erase = 2'b01, Line = 2'b10, Paint_Bucket = 2'b11;

	always @ (*) begin
		case (y_Q)
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
		if (!Resetn) begin
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
