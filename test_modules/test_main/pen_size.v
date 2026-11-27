
module pen_size (up, down, Clock, Resetn, z, size_val);
    input up, down, Resetn;
    input Clock;
    output reg [2:0] z;
    output reg [2:0] size_val;  // ASSIGNING numbers for brush size
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
   
 // ======== show pen size on the LEDR + Output Numeric Size ==========  
    always @ (*) begin
        z[2:0] = 3'b000;
        if (y_Q == size1) begin
            z[2] = 1'b1; 
            size_val = 3'd1; // <-- 1x1 size
        end
        if (y_Q == size2) begin
            z[1] = 1'b1; 
            size_val = 3'd2; // <-- 2x2 size
        end

        if (y_Q == size3) begin
            z[0] = 1'b1; 
            size_val = 3'd3; // <-- 3x3 size
        end
    end
       
endmodule



