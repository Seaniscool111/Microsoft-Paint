module brush_renderer (
    input wire clk,
    input wire resetn,
    input wire go,              // 1 when mouse_click (or ~KEY[1]) is pressed
    input wire [9:0] center_x,
    input wire [8:0] center_y,
    input wire [2:0] size,      // 1 for 1x1, 2 for 2x2, 3 for 3x3
    output wire [9:0] vga_x,
    output wire [8:0] vga_y,
    output reg write
);

// State codes --> Changed to 2 states to prevent glitches for 2x2 and 3x3 brisj
    localparam IDLE = 2'b00,
               DRAW = 2'b01;

    reg [1:0] y_Q, Y_D;    // Present state (y_Q) and next state (Y_D)
    reg [2:0] xc, yc;      // X and Y offset counters
	 wire done_stamp;       // Signals that all pixels in n x n ar edrawn
	 
	 // High when we are at the last pixel of the box
	 assign done_stamp = (xc +1'b1 == size) && (yc+ 1'b1 == size);

	 
	// NEXT State LOGIC
	always @(*) begin
        // Default values to prevent latches
		 
        case (y_Q)
				
				// Idle State
				IDLE: begin
					if (go && (size >0))
						Y_D = DRAW;
					else
						Y_D = IDLE;
						
				end
				
				// Draw State
				DRAW: begin
					
					if(done_stamp)
						Y_D = IDLE;
					
					else
						Y_D = DRAW;
				
				end
				
				default: Y_D = IDLE;
			endcase
		end
	 
	 
	// State Register AND COUNTERS
	always @(posedge clk) begin
        if (!resetn) begin
            y_Q <= IDLE;
            xc  <= 3'd0;
            yc  <= 3'd0;
			write <= 1'b0;
				
        end
        else begin
            y_Q <= Y_D; // Advance

            // Counter updates based on Present State (y_Q)
            case (y_Q)
				
					IDLE: begin
						xc <= 3'd0;
						yc <= 3'd0;
						write <= 1'b0;
					end
					
					DRAW: begin
						write <= 1'b1;
						
						// 2D going through each pixel coloumn by coloumn, row by row
						
                        // Check if we reached right edge of row
                        if (xc + 1'b1 < size) begin  // IF the x_counter/coord is smaller than current size it will continue drawing
							xc <= xc + 1'b1;
							
						end 
						else begin  // Edge was hit: Reset to left side
							xc <= 3'd0;     

							if (yc + 1'b1 < size) begin  // Move 1 pixel DOWN to next row
								yc <= yc + 1'b1;
							end 

							else begin
								yc <= 3'd0;         // Finished entire box: Reset Y to top
								
							end
						end
					end
				endcase
			end
		end
	
	// State Assignments
	assign vga_x = center_x + xc;
	assign vga_y = center_y + yc;
	
endmodule