module mouse  ( 
	input CLOCK_50, // will drive all the clocks
	input [9:0] SW, // SW9 = MODE AMD SW 0 AND RESET
	
	inout PS2_CLK,
	inout PS2_DAT,

	output right_click, // is mouse right clicking
	output middle_click, // is mouse middle clicking
	output left_click, // is mouse left clicking
	output [9:0] x_position, // 10 bit x position --> holds up to decimal value 640
	output [9:0] y_position // 10 bit y position --> hols up to decimal value 420 
);

// PS2 CONTROLLER WIRES
wire reset = SW[0]; // THIS IS AN ACTIVE HIGH RESET FOR PS2
wire keyboard_mode = ~SW[9];
wire mouse_reset = reset | keyboard_mode;
wire [7:0] mouse_data; // 8 bit word output of the mouse
wire mouse_data_en; // valid mouse signal

// optional qires

// ===============================================
// 			MODULE INSTANTIATIONS
// ==========================================
PS2_Controller #(.INITIALIZE_MOUSE(1)) PS2_mouse ( // MOUSE
    .CLOCK_50(CLOCK_50),
    .reset(mouse_reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(8'h00), // command to be sent, 8 bit input
    .send_command(1'b0), // command ready signal

    .PS2_CLK(PS2_CLK), //PIN_AD7
    .PS2_DAT(PS2_DAT), // PIN_AE7

    //outputs

    .command_was_sent(), //this signal is driven high once the command is successfully sent.
    .error_communication_timed_out(), //indicates the transmission error when sending the command.

    .received_data(mouse_data), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(mouse_data_en) // new data signal. driven high for one clock cycle when receieved_data changes
);

// =============== REGISTERS FOR MOUSE ==========
reg [7:0] y_movement, x_movement, status_buttons; 
reg [1:0] byte_index;
reg mouse_packet_received;

always @ (posedge CLOCK_50) begin
	if (reset) begin
		byte_index <= 2'b0;
		y_movement <= 8'b0;
		x_movement <= 8'b0;
		status_buttons <= 8'b0;
		mouse_packet_received <= 1'b0;
	end

	else begin
		mouse_packet_received <= 1'b0;

		if (mouse_data_en) begin // data received from PS2 controller
			case (byte_index)
				2'b00: begin // status and buttons
					if (mouse_data[3] == 1) begin
					status_buttons <= mouse_data;
					byte_index <= 2'b01; // mouse will now send x_movement 
					end
				end

				2'b01: begin // x_movement
					x_movement <= mouse_data;
					byte_index <= 2'b10; // mouse will now send y_movement
				end

				2'b10: begin // y_movement
					y_movement <= mouse_data;
					if (status_buttons[3] == 1'b1) mouse_packet_received <= 1'b1; // done
					byte_index <= 2'b00;
				end
			endcase
		end
	end
end

// TRANSLATING TO POSITION
reg [9:0] cursor_x; // 10 digits to hold 640
reg [9:0] cursor_y;

wire x_sign = status_buttons[4]; // 0 = +, 1 = -
wire y_sign = status_buttons[5]; // 0 = +, 1 = -

wire [7:0] x_mag = x_sign ? ((~x_movement) + 8'd1) : x_movement;
wire [7:0] y_mag = y_sign ? ((~y_movement) + 8'd1) : y_movement;

wire [10:0] x_mag_ext = {3'b000, x_mag};
wire [10:0] y_mag_ext = {3'b000, y_mag};
wire [10:0] cur_x_ext = {1'b0, cursor_x}; 
wire [10:0] cur_y_ext = {1'b0, cursor_y};

always @(posedge CLOCK_50) begin
	if (reset) begin
		cursor_x <= 10'd320; // center of 640x480
		cursor_y <= 10'd240;
	end
	else if (mouse_packet_received) begin
		// X POSITION: clamp to [0, 639]
		if (!x_sign) begin // x_sign = 0 = positive = moving right
			if (cur_x_ext + x_mag_ext >= 10'd639) // pos plus delta
				cursor_x <= 10'd639; // clamp
			else
				cursor_x <= cursor_x + x_mag_ext[9:0]; // else, update pos
		end

		else begin // x_sign = 1 = negative = moving left
			if (cur_x_ext <= x_mag_ext) 
				cursor_x <= 10'd0;
			else
				cursor_x <= cursor_x - x_mag_ext[9:0]; 
		end

		// Y POSITION: clamp to [0, 479]
		if (y_sign) begin
			if (cur_y_ext + y_mag_ext >= 10'd479)
				cursor_y <= 10'd479;
			else
				cursor_y <= cursor_y + y_mag_ext[9:0];
		end
		else begin
			if (cur_y_ext <= y_mag_ext)
				cursor_y <= 10'd0;
			else
				cursor_y <= cursor_y - y_mag_ext[9:0];
		end
	end
end

// ASSIGN OUTPUTS
assign left_click = status_buttons[0];
assign right_click = status_buttons[1];
assign middle_click = status_buttons[2];
assign x_position = cursor_x;
assign y_position = cursor_y;

endmodule