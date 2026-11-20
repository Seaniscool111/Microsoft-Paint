module brush_renderer (
    input wire clk,
    input wire resetn,
    input wire go,              // 1 when mouse_click (or ~KEY[1]) is pressed
    input wire [9:0] center_x,
    input wire [8:0] center_y,
    input wire [2:0] size,      // e.g., 1 for 1x1, 2 for 2x2, 3 for 3x3
    output wire [9:0] vga_x,
    output wire [8:0] vga_y,
    output reg write
);

// State codes
    localparam A = 2'b00,  // IDLE
               B = 2'b01,  // DRAW
               C = 2'b10,  // NEXT_ROW
               D = 2'b11;  // DONE

    reg [1:0] y_Q, Y_D;    // Present state (y_Q) and next state (Y_D)
    reg [2:0] xc, yc;      // X and Y offset counters
	 
	 

	// State Assignments
	always @(*) begin
        // Default values to prevent latches
        write = 1'b0;
        Y_D = A;

        case (y_Q)
            A: begin
                // if go is 1, move to B; otherwise stay in A
					 if (go) Y_D = B; else Y_D = A;
            end
            B: begin
                write = 1'b1;
                // if (xc < size - 1), stay in B; otherwise move to C
					 if (xc < size - 1) Y_D = B; else Y_D = C;
            end
            C: begin
                // if (yc < size - 1), go back to B; otherwise move to D
					 if (yc < size - 1) Y_D = B; else Y_D = D;
            end
            D: begin
                // return to A
					 Y_D = A;
            end
        endcase
    end
	 
	 
	// COUNTERS
	always @(posedge clk) begin
        if (!resetn) begin
            y_Q <= A;
            xc  <= 3'd0;
            yc  <= 3'd0;
        end
        else begin
            y_Q <= Y_D;

            // Counter updates based on Present State (y_Q)
            case (y_Q)
                A: begin
                    // reset xc and yc to 0
						  xc <= 3'd0; yc <= 3'd0;
                end
                B: begin
                    // haven't hit end of row if (xc < size - 1), increment xc by 1
							if (xc < size - 1) xc <= xc + 3'd1;
                end
                C: begin
                    // Move onto next row, reset xc to 0, and if (yc < size - 1), increment yc by 1
						   xc <= 3'd0;
							if (yc < size - 1) yc <= yc + 3'd1;
                end
                D: begin
                    // Done, reset yc to 0
						  yc <= 3'd0;
                end
            endcase
        end
    end
	
	// State Assignments
	assign vga_x = center_x + xc;
	assign vga_y = center_y + yc;
	
endmodule