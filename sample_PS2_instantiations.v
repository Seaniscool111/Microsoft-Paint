module sample_PS2_instantiations(SW, LEDR, KEY0, KEY1, CLOCK_50);
    input [9:0] SW;
    input CLOCK_50;
    output [9:7] LEDR;
    input KEY0;
    input KEY1;

	 wire [2:0] z;

    pen_size P1 (
        .up(KEY0),
        .down(KEY1),
        .Clock(CLOCK_50),
        .Resetn(SW[1]),
        .z(z),
    );
	 
	 assign LEDR[9:7] = z[2:0];
   
endmodule


module pen_size (up, down, Clock, Resetn, z);
    input up, down, Resetn;
    input Clock;
    output reg [2:0] z;
    reg y_Q, Y_D;
    parameter size1 = 2'b00, size2 = 2'b01, size3 = 2'b10;
   
    always @ (*)
        case ({up, down})
            size1:  if      (up == 1)   Y_D = size2;
                    else if (down == 1) Y_D = size1;
                    else                Y_D = size1;


            size2:  if  (up == 1)       Y_D = size3;
                    else if (down == 1)    Y_D = size1;
                    else                Y_D = size2;


            size3:  if      (up == 1)   Y_D = size3;
                    else if (down == 1) Y_D = size2;
                    else                Y_D = size3;


            default: Y_D = size2;
        endcase
   
    // ======== STATE FFS ============
    always @ (posedge Clock)
        if (!Resetn)
            y_Q <= size2;
        else
            y_Q <= Y_D;
   
 // ======== show pen size on the LEDR ==========  
    always @ (*) begin
        z[2:0] = 3'b000;
        if (y_Q == size1) z[2] = 1'b1;
        if (y_Q == size2) z[1] = 1'b1;
        if (y_Q == size3) z[0] = 1'b1;
    end
       
endmodule

