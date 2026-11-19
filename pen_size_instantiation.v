module pen_size_instantiation(SW, LEDR, KEY0, KEY1, CLOCK_50)
	input [9:0] SW;
	input CLOCK_50;
	output [9:7] LEDR;
	input KEY0;
	input KEY1;

	pen_size P1 (
		.up(KEY0),
		.down(KEY1),
		.Clock(CLOCK_50),
		.Resetn(SW[1]),
		.LEDR(LEDR[9:7]),
	)
	
endmodule

module pen_size (up, down Clock, Resetn, LEDR);
	input up, down, Resetn;
	input Clock;
	output [9:7] LEDR;
	reg y_Q, Y_D;
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