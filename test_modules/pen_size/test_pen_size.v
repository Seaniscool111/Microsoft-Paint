module test_pen_size(SW, LEDR, KEY, CLOCK_50);
    input [9:0] SW;
    input CLOCK_50;
    output [9:7] LEDR;
    input [1:0] KEY;

	 wire [2:0] z;

    pen_size P1 (
        .up(KEY[0]),
        .down(KEY[1]),
        .Clock(CLOCK_50),
        .Resetn(SW[0]),
        .z(z)
    );
	 
	assign LEDR[9:7] = z[2:0];
   
endmodule

module pen_size (up, down, Clock, Resetn, z);
    input up, down, Resetn;
    input Clock;
    output reg [2:0] z;
    reg [1:0] y_Q, Y_D;
    parameter size1 = 2'b00, size2 = 2'b01, size3 = 2'b10;
	 
	 reg up_prev, down_prev;
    wire up_press, down_press;


    // Detect active-low button press (1 -> 0)
    always @(posedge Clock) begin
        if (!Resetn) begin
            up_prev   <= 1'b1;
            down_prev <= 1'b1;
        end else begin
            up_prev   <= up;
            down_prev <= down;
        end
    end

    assign up_press   = (up_prev == 1'b1) && (up == 1'b0);
    assign down_press = (down_prev == 1'b1) && (down == 1'b0);
   
    always @ (*)
        case (y_Q)
            size1:  if      (up_press == 1)   Y_D = size2;
                    else if (down_press == 1) Y_D = size1;
                    else                Y_D = size1;


            size2:  if  (up_press == 1)       Y_D = size3;
                    else if (down_press == 1)    Y_D = size1;
                    else                Y_D = size2;


            size3:  if      (up_press == 1)   Y_D = size3;
                    else if (down_press == 1) Y_D = size2;
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

