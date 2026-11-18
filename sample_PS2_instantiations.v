module sample_PS2_instantiations (
	CLOCK_50;

);

input CLOCK_50; // will drive all the clocks
input reset; // THIS IS AN ACTIVE HIGH RESET FOR PS2
wire [7:0] data_bus; // 8 bit word output of the ps2 controller
wire data_bus_en; // 

// ===============================================
// 			MODULE INSTANTIATIONS
// ==========================================
PS2_Controller PS2 #(parameter INITIALIZE_MOUSE = 1) ( // CHECK SYNTAX 
    .CLOCK50(CLOCK_50),
    .reset(reset), // THIS IS AN ACTIVE HIGH RESET !!!11

    .the_command(), // optional, leave bracket blank
    .send_command(), // optional, leave bracket blank

    .PS2_CLK(), //PIN_AD7
    .PS2_DAT(), // PIN_AE7

    //outputs

    .command_was_sent(), // optional, leave bracket blank
    .error_communication_timed_out.(), // optional, leave bracket blank

    .received_data(data_bus), // last data received from the PS/2 bus. 8 bit word
    .received_data_en(data_bus_en) // new data signal. driven high for one clock cycle when receieved_data changes
)

Altera_UP_PS2_Data_In DI ( //accepts incoming data FROM ps2 core
	// Inputs
	.clk(CLOCK_50),
	.reset(reset),

	.wait_for_incoming_data(),
	.start_receiving_data(),

	.ps2_clk_posedge(),
	.ps2_clk_negedge(),
	.ps2_data(),

	// Bidirectionals

	// Outputs
	.received_data(),
	.received_data_en()			// If 1 - new data has been received
);

Altera_UP_PS2_Command_Out CO (
	// Inputs
	.clk(CLOCK_50),
	.reset(reset),

	.the_command(),
	.send_command(),

	.ps2_clk_posedge(),
	.ps2_clk_negedge(),

	// Bidirectionals
	.PS2_CLK(),
 	.PS2_DAT(),

	// Outputs
	.command_was_sent(),
	.error_communication_timed_out()
);

endmodule

/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_PS2                                               *
 * Description:                                                              *
 *      This module communicates with the PS2 core.                          *
 *                                                                           *
 *****************************************************************************/

module PS2_Controller #(parameter INITIALIZE_MOUSE = 0) (
	// Inputs
	CLOCK_50,
	reset,

	the_command,
	send_command,

	// Bidirectionals
	PS2_CLK,					// PS2 Clock
 	PS2_DAT,					// PS2 Data

	// Outputs
	command_was_sent,
	error_communication_timed_out,

	received_data,
	received_data_en			// If 1 - new data has been received
);


/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_PS2_Data_In                                       *
 * Description:                                                              *
 *      This module accepts incoming data from a PS2 core.                   *
 *                                                                           *
 *****************************************************************************/


module Altera_UP_PS2_Data_In (
	// Inputs
	clk,
	reset,

	wait_for_incoming_data,
	start_receiving_data,

	ps2_clk_posedge,
	ps2_clk_negedge,
	ps2_data,

	// Bidirectionals

	// Outputs
	received_data,
	received_data_en			// If 1 - new data has been received
);

/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_PS2_Command_Out                                   *
 * Description:                                                              *
 *      This module sends commands out to the PS2 core.                      *
 *                                                                           *
 *****************************************************************************/


module Altera_UP_PS2_Command_Out (
	// Inputs
	clk,
	reset,

	the_command,
	send_command,

	ps2_clk_posedge,
	ps2_clk_negedge,

	// Bidirectionals
	PS2_CLK,
 	PS2_DAT,

	// Outputs
	command_was_sent,
	error_communication_timed_out
);