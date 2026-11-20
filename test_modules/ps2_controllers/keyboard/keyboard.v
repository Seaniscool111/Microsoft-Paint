module test_keyboard ( // top level module, main
	CLOCK_50,
	SW,
	LEDR,
	PS2_CLK,
	PS2_DAT,
	HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

// INPUT OUTPUTS
input CLOCK_50; // will drive all the clocks
input [9:0] SW;
wire reset = SW[0]; // THIS IS AN ACTIVE HIGH RESET FOR PS2

output [9:0] LEDR;
output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

inout PS2_CLK;
inout PS2_DAT;

// PS2 CONTROLLER WIRES
wire [7:0] keyboard_data; // 8 bit word output of the keyboard
wire keyboard_data_en; // valid keyboard signal

// ===============================================
// 			MODULE INSTANTIATIONS
// ==========================================
PS2_Controller #(.INITIALIZE_MOUSE(0)) PS2_keyboard ( // KEYBOARD
    .CLOCK_50(CLOCK_50),
    .reset(reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(), // optional, leave bracket blank
    .send_command(), // optional, leave bracket blank

    .PS2_CLK(PS2_CLK), //PIN_AD7
    .PS2_DAT(PS2_DAT), // PIN_AE7

    //outputs

    .command_was_sent(), // optional, leave bracket blank
    .error_communication_timed_out(), // optional, leave bracket blank

    .received_data(keyboard_data), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(keyboard_data_en) // new data signal. driven high for one clock cycle when receieved_data changes
);

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

// WIRES FOR USE WITH REST OF THE MODULE 
wire [7:0] key_pressed = key;

// =========== TESTING MODULES ==============
assign LEDR[7:0] = key; // DRIVE LEDS FOR TESTING -- SHOULD SHOW THE MAKE CODE
assign LEDR[8] = right_click;
assign LEDR[9] = left_click;

wire [3:0] s = {2'b00, x_position[9:8]};
seg7Hex H5 (s, HEX5); 
seg7Hex H4 (x_position[7:4], HEX4);
seg7Hex H3 (x_position[3:0], HEX3);

wire [3:0] t = {2'b00, y_position[9:8]};
seg7Hex H2 (t, HEX2); 
seg7Hex H1 (y_position[7:4], HEX1);
seg7Hex H0 (y_position[3:0], HEX0);

endmodule

module seg7Hex (x, Display);
    input [3:0] x; // input is a 4 bit hex
    output reg [6:0] Display;
    
    // look at when each segment is on
    
    always @(*) begin
        case(x)
        // 4 bit hex, then display will show:
        4'h0: Display = 7'b1000000;
        4'h1: Display = 7'b1111001;
        4'h2: Display = 7'b0100100;
        4'h3: Display = 7'b0110000;
        4'h4: Display = 7'b0011001;
        4'h5: Display = 7'b0010010;
        4'h6: Display = 7'b0000010;
        4'h7: Display = 7'b1111000;
        4'h8: Display = 7'b0000000;
        4'h9: Display = 7'b0011000;
        4'hA: Display = 7'b0001000;
        4'hB: Display = 7'b0000011;
        4'hC: Display = 7'b1000110;
        4'hD: Display = 7'b0100001;
        4'hE: Display = 7'b0000110;
        4'hF: Display = 7'b0001110;
        endcase
    end
endmodule



