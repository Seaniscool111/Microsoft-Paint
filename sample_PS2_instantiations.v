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

// module instantiation:

PS2_Controller PS2 (
    .CLOCK50(),
    .reset(),

    .the_command(),
    .send_command(),

    .PS2_CLK(),
    .PS2_DAT(),

    //outputs

    .command_was_sent(),
    .error_communication_timed_out.(),

    .received_data(),
    .received_data_en()
)