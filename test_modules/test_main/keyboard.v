module keyboard ( // top level module, main
	input CLOCK_50, // will drive all the clocks
	input [9:0] SW, // SW9 = MODE AMD SW 0 AND RESET
    	
   inout PS2_CLK,
	inout PS2_DAT,

    output [7:0] key_pressed // 8 bit word output of the keyboard
);

// PS2 CONTROLLER WIRES
wire reset = SW[0]; // THIS IS AN ACTIVE HIGH RESET FOR PS2
//wire mouse_mode = SW[9];
//wire keyboard_reset = reset | mouse_mode;
wire [7:0] keyboard_data; // 8 bit word output of the keyboard
wire keyboard_data_en; // valid keyboard signal

// ===============================================
// 			MODULE INSTANTIATIONS
// ==========================================
PS2_Controller #(.INITIALIZE_MOUSE(0)) PS2_keyboard ( // KEYBOARD
    .CLOCK_50(CLOCK_50),
    .reset(reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(8'h00), // optional, leave bracket blank
    .send_command(1'b0), // optional, leave bracket blank

    .PS2_CLK(PS2_CLK), //PIN_AD7
    .PS2_DAT(PS2_DAT), // PIN_AE7

    .command_was_sent(), // optional, leave bracket blank
    .error_communication_timed_out(), // optional, leave bracket blank

    .received_data(keyboard_data), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(keyboard_data_en) // new data signal. driven high for one clock cycle when receieved_data changes
);

// ============== REGISTERS FOR KEYBOARD ================
reg [7:0] key; // stores the 8 bit hex code of the key being pressed -- REFER TO keyboard_codes
reg key_released; // "Break"

// ======= register to hold the last valid scan code =========
always @ (posedge CLOCK_50) begin 
	if (reset) begin
		key <= 8'b0; 
		key_released <= 1'b0; 
	end
	
	else if (keyboard_data_en) begin // data received from PS2 controller module
		if (key_released) begin
			key_released <= 1'b0;
			if (key == 8'h55) begin
				key <= 8'b0;
			end
			if (key == 8'h4E) begin
				key <= 8'b0;
			end
		end
		
		else if (keyboard_data == 8'hF0) begin // key detected and received
//			if (key == 8'h55) begin
//				key <= 8'b0;
//			end
//			if (key == 8'h4E) begin
//				key <= 8'b0;
//			end
			
			key_released <= 1'b1; // key had been released
		end 
		
		else begin // MAKE CODE -- KEY IS BEING PRESSED -- we are RECEIVING
			key <= keyboard_data;
		end		
	end
end

// ASSIGN MODULE OUTPUT
assign key_pressed = key;


endmodule


