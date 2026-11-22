module main (SW, LEDR, CLOCK_50, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input [9:0] SW;
    input [9:0] LEDR;
    input CLOCK_50;
    input HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    // VGA INSTANTIATION
    display D1 (
        .CLOCK_50(CLOCK_50),
        .SW(),
        .KEY(),
        .mouse_x(),
        .mouse_y(),
        .mouse_click(),
        .Color(),
        .VGA_R(),
        .VGA_G(),
        .VGA_B(),
       VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	input CLOCK_50;

    )

endmodule