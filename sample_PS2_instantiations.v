module sample_PS2_instantiations ( // top level module, main
	CLOCK_50;
	SW,
	LEDR,
	HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
);

// INPUT OUTPUTS
input CLOCK_50; // will drive all the clocks
input [9:0] SW;
wire reset = SW[0]; // THIS IS AN ACTIVE HIGH RESET FOR PS2

output [9:0] LEDR;
output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

// PS2 CONTROLLER WIRES
wire [7:0] keyboard_data; // 8 bit word output of the keyboard
wire [7:0] mouse_data; // 8 bit word output of the mouse
wire keyboard_data_en; // valid keyboard signal
wire mouse_data_en; // valid mouse signal

// ===============================================
// 			MODULE INSTANTIATIONS
// ==========================================
PS2_Controller PS2 #(parameter INITIALIZE_MOUSE = 0) ( // KEYBOARD
    .CLOCK50(CLOCK_50),
    .reset(reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(), // optional, leave bracket blank
    .send_command(), // optional, leave bracket blank

    .PS2_CLK(), //PIN_AD7
    .PS2_DAT(), // PIN_AE7

    //outputs

    .command_was_sent(), // optional, leave bracket blank
    .error_communication_timed_out.(), // optional, leave bracket blank

    .received_data(keyboard_data), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(keyboard_data_en) // new data signal. driven high for one clock cycle when receieved_data changes
)

PS2_Controller PS2 #(parameter INITIALIZE_MOUSE = 1) ( // MOUSE
    .CLOCK50(CLOCK_50),
    .reset(reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(), // optional, leave bracket blank
    .send_command(), // optional, leave bracket blank

    .PS2_CLK(), //PIN_AD7
    .PS2_DAT(), // PIN_AE7

    //outputs

    .command_was_sent(), // optional, leave bracket blank
    .error_communication_timed_out.(), // optional, leave bracket blank

    .received_data(mouse_data), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(mouse_data_en) // new data signal. driven high for one clock cycle when receieved_data changes
)

// ============== REGISTERS FOR KEYBOARD ================
reg [7:0] key; // stores the 8 bit hex code of the key being pressed -- REFER TO keyboard_codes
reg key_released; // "Break"
reg special_key_received; // for arrow up and down

// ======= register to hold the last valid scan code =========
always @ (posedge CLOCK_50) begin 
	if (reset) begin
		key <= 8'b0; 
		key_released <= 1'b0; 
		special_key_received <= 1'b0;
	end
	
	else if (keyboard_data_en) begin // data received from PS2 controller module
		if (keyboard_data == 8'hE0) begin // special key detected and received
			special_key_received <= 1'b1; // special key has been received 
		end 
		else if (keyboard_data == 8'hF0) begin // key detected and received
			key_released <= 1'b1; // key had been released
		end 
		
		else begin // MAKE CODE -- KEY IS BEING PRESSED -- we are RECEIVING
			if (special_key_received) begin // key is either arrow up or down
				if (keyboard_data == 8'h75) begin // ARROW UP
					key <= 8'hAA; // arrow up by our conventions			
				end 
				
				else if (keyboard_data == 8'h72) begin
					key <= 8'hDD; // arrow down by our conventions
				end
				special_key_received <= 1'b0;
			end 
			
			else begin
				key <= keyboard_data;
			end 

			key_released <= 1'b0; // key has not been released yet
		end		
	end
end

assign LEDR[7:0] = key; // DRIVE LEDS FOR TESTING -- SHOULD SHOW THE MAKE CODE


endmodule