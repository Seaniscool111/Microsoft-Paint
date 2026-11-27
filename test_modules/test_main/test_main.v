module test_main(
    input CLOCK_50, 
    input [9:0]SW, 
    input [3:0] KEY, 
    input [9:0] mouse_x, 
    input [8:0] mouse_y, 
    input mouse_click, 

    output [7:0] VGA_R, VGA_G, VGA_B, 
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK,
    
    output [9:0] LEDR,
    output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,

    inout PS2_CLK,
    inout PS2_DAT
);
    
    
    // Wires for brush_renderer
    wire [9:0] brush_x;
    wire [8:0] brush_y;
    wire brush_write;
    
    // ps2 controller wires
    wire [7:0] key_pressed;
    wire right_click;
    wire middle_click;
    wire left_click;

    wire [9:0] x_pos;
    wire [9:0] y_pos;


// ================= PS2 CONTROLLER ==============
   keyboard K1 (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .key_pressed(key_pressed)
    );
    
    mouse M1 (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0),
        .LEDR(LEDR),
        
        .right_click(right_click),
        .middle_click(middle_click),
        .left_click(left_click),
        .x_position(x_pos),
        .y_position(y_pos)
    );
    

    wire [8:0] colour;

    colour_FSM C1 (
        .code(key_pressed),
        .Clock(CLOCK_50),
        .Resetn(!SW[0]), // check if this is not or not
        .Colour(colour)
    );

    wire up = (key_pressed == 8'h55);
    wire down = (key_pressed == 8'h4E);

    pen_size P1 (
        .up(up),
        .down(down),
        .Clock(CLOCK_50),
        .Resetn(!SW[0]),
        .z(LEDR),

    );
    
    // INSTANTIATE BRUSH_RENDERER 
    brush_renderer B (
        .clk(CLOCK_50),
        .resetn(KEY[0]),
        .go(left_click),              // (dummy mouse click)
        .center_x(x_pos),         // DUMMY X-Coordinate Middle   --- CHANGE TO MOUSE INPUT X (mouse_x)
        .center_y(y_pos),         // DUMMY Y-Coordinate Middle   --- CHANGE TO MOUSE INPUT Y (mouse_y)
        .size(3'd3),                 //(start with a fixed 3x3 brush to test, or SW[5:3])
        .vga_x(brush_x),
        .vga_y(brush_y),
        .write(brush_write));
    
    vga_adapter A (
        .clock(CLOCK_50),
        .resetn(KEY[0]),
        .color(colour),
        .x(brush_x),             
        .y(brush_y),             
        .write(brush_write),        
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));
    
    // Forcing vga_adapter variables to be this (changed already though)
    defparam A.RESOLUTION = "640x480";
    defparam A.BACKGROUND_IMAGE = "./MIF/white_640x480.mif";
    defparam A.COLOR_DEPTH = 9;
        
endmodule