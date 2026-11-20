`timescale 1ns / 1ps

module brush_tb();
    parameter CLOCK_PERIOD = 20; // 50 MHz clock

    // Inputs to drive (reg)
    reg clk;
    reg resetn;
    reg go;
    reg [9:0] center_x;
    reg [8:0] center_y;
    reg [2:0] size;

    // Outputs to watch (wire)
    wire [9:0] vga_x;
    wire [8:0] vga_y;
    wire write;

    // Clock Generator (just like your prof's lab)
    initial begin
        clk <= 1'b0;
    end
    always @(*) begin
        #(CLOCK_PERIOD / 2) clk <= ~clk;
    end

    
    initial begin
        // TODO: Initialize all inputs at t = 0
        //       Set resetn = 0, go = 0, center_x = 10'd320, center_y = 9'd240, size = 3'd1
    resetn <= 1'b0; go <= 1'b0;
    center_x <= 10'd320; center_y <= 9'd240;
    size <= 3'd1;

        
    // Wait #20, then release reset (resetn <= 1'b1)
    #20 resetn <= 1'b1;

    // TEST CASE 1: 1x1 dot in the middle
    // #20, then set go <= 1'b1 for 1 clock cycle (#20), then go <= 1'b0
    #20 go <= 1'b1; 
    #20 go <= 1'b0;
    // TEST CASE 2: 2x2 brush stamp
    // Wait #100, change size <= 3'd2, then pulse go <= 1'b1 for #20, then go <= 1'b0
    #100 size <= 3'd2;
    #20 go <= 1'b1;
    #20 go <= 1'b0;
    #200 $stop;
end

// Instantiate ONLY brush_renderer
brush_renderer UUT (
    .clk(clk),
    .resetn(resetn),
    .go(go),
    .center_x(center_x),
    .center_y(center_y),
    .size(size),
    .vga_x(vga_x),
    .vga_y(vga_y),
    .write(write)
);

endmodule