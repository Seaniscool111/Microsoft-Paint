module ps2_and_fsms ( // use ps2 and show the colour on the LEDR
    input CLOCK_50,
    input [9:0] SW, // SW[0] IS RESET
    input [9:0] LEDR;
    output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
    inout PS2_CLK,
    inout PS2_DAT,    
)

// ps2 controller wires
    wire [7:0] key_pressed;
    wire right_click;
    wire middle_click;
    wire left_click;

    wire [9:0] x_pos;
    wire [9:0] y_pos;


// ================= PS2 CONTROLLER ==============
    ps2 P1 (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .LEDR(LEDR),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),

        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0),

        .key_pressed(key_pressed),
        .right_click(right_click),
        .middle_click(middle_click),
        .left_click(left_click),
        .x_position(x_pos),
        .y_position(y_pos)
    )

    wire [9:0] colour;

    colour_FSM C1 (
        .code(key_pressed),
        .Clock(CLOCK_50),
        .Resetn(SW[0]), // check if this is not or not
        .Colour(colour)
    )

    assign LEDR[8:0] = colour;
endmodule 