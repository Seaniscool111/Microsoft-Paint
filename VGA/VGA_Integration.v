// Top Level Module... Trying to output a square at centre.... 
// to test pseudo code

/*
=============================================================================
================================= VGA Output ================================
=============================================================================

NOTE: Use colors to repurpose the code... Lowk the same thing I need for this
*/

module vga_demo(CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_X, VGA_Y, VGA_COLOR, plot);
	// default resolution. Specify a resolution in top.v


	parameter RESOLUTION = "640x480"; // "640x480" "320x240" "160x120"
	
	
	// default color depth. Specify a color in top.v
   parameter COLOR_DEPTH = 9; // 9 6 3

	 
	// specify the number of bits needed for an X (column) pixel coordinate on the VGA display
   parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
   // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
   parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);

	
	
   // state codes for FSM that choses which object to draw at a given time
   parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
	
	
	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
	input wire [9:0] LEDR;
   output wire [6:0] HEX2, HEX1, HEX0;
	output wire [nX-1:0] VGA_X;          // for DESim VGA
	output wire [nY-1:0] VGA_Y;          // for DESim VGA
	output wire [23:0] VGA_COLOR;        // for DESim VGA
	output wire plot;                    // for DESim VGA

   wire VGA_SYNC;  // used to indicate when background drawing is done
//	wire [COLOR_DEPTH-1:0] new_color, color;
//   wire [nX-1:0] X;     // used to record the center of the box
//   wire [nY-1:0] Y;     // used to record the center of the box
//
//   wire [nX-1:0] X0, XC;    // box offsets and counters
//   wire [nY-1:0] Y0, YC;
//	wire [nY-1:0] new_size, size;       // used to set the box max (x,y) coordinates
//   wire go;                            // used by FSM
//   reg write, Lxc, Lyc, Exc, Eyc;      // box control signals
//   reg [1:0] y_Q, Y_D;                 // FSM
//	
    // use offsets to center the box on the VGA display
//    parameter X_OFFSET = (RESOLUTION == "640x480") ? 320 : ((RESOLUTION == "320x240") ? 160 : 80);
//    parameter Y_OFFSET = (RESOLUTION == "640x480") ? 240 : ((RESOLUTION == "320x240") ? 120 : 60);
//    assign X0 = X_OFFSET;
//    assign Y0 = Y_OFFSET;
//    regn UX (X0, KEY[0], 1'b1, CLOCK_50, X);
//        defparam UX.n = nX;
//    regn UY (Y0, KEY[0], 1'b1, CLOCK_50, Y);
//        defparam UY.n = nY;

    // set default color to white (1...11)
    assign new_color = color == {COLOR_DEPTH{1'b0}} ? {COLOR_DEPTH{1'b1}} : SW[COLOR_DEPTH-1:0];
    regn UC (new_color, KEY[0], ~KEY[1] | (color == {COLOR_DEPTH{1'b0}}), CLOCK_50, color); 
        defparam UC.n = COLOR_DEPTH;

    // set default box size to 1 x 1
    assign new_size = size == {nY{1'b0}} ? 1 : SW[nY-1:0];
    regn UB (new_size, KEY[0], ~KEY[2] | (size == {nY{1'b0}}), CLOCK_50, size); 
        defparam UB.n = nY;

    // these counter are used to generate pixel coordinates for the box
    up_count U1 ({nX{1'd0}}, CLOCK_50, KEY[0], Lxc, Exc, XC);
        defparam U1.n = nX;
    up_count U2 ({nY{1'd0}}, CLOCK_50, KEY[0], Lyc, Eyc, YC);
        defparam U2.n = nY;

    assign LEDR[8:0] = (COLOR_DEPTH == 9) ? color : ((COLOR_DEPTH == 6) ? {3'b0,color} :
                       {6'b0,color});

    hex7seg H2 ((RESOLUTION == "640x480") ? {3'b0,size[8]} : 4'b0, HEX2);
    hex7seg H1 ((RESOLUTION == "640x480") ? size[7:4] : 
               ((RESOLUTION == "320x240") ? size[7:4] : {1'b0,size[6:4]}) , HEX1);
    hex7seg H0 (size[3:0], HEX0);

    assign go = ~KEY[3];

    // =============== FSM state table: CHANGE THIS ===============
    always @ (*)
        case (y_Q)
            A:  if (!go) Y_D = A;
                else Y_D = B;
            B:  if (XC != size-1) Y_D = B;  // box x coordinate (column)
                else Y_D = C;
            C:  if (YC != size-1) Y_D = B;  // box y coordinate (row)
                else Y_D = D;
            D:  Y_D = A;
        endcase
		  
    //  =============== FSM Outputs: CHANGE THIS ===============
    always @ (*)
    begin
        // default assignments
        write = 1'b0; Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0;
        case (y_Q)
            A:  begin Lxc = 1'b1; Lyc = 1'b1; end   // load (XC,YC) counter
            B:  begin Exc = 1'b1; write = 1'b1; end // enable XC, write pixel
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end   // enable YC, load XC
            D:  Lyc = 1'b1;                         // load YC
        endcase
    end

    always @(posedge CLOCK_50)
        if (!KEY[0])
            y_Q <= 2'b0;
        else
            y_Q <= Y_D;

//    // instantiate the DESim VGA adapter
//    `define VGA_MEMORY              // include a memory module in the VGA adapter
//    vga_adapter VGA (
//        .resetn(KEY[0]),
//        .clock(CLOCK_50),
//        .color(color),              // used to draw pixels on top of background
//        .x(X - (size >> 1) + XC),   // used to draw pixels on top of background
//        .y(Y - (size >> 1) + YC),   // used to draw pixels on top of background
//        .write(write),              // used to draw pixels on top of background
//        .VGA_X(VGA_X),              // the output VGA x coordinate (column)
//        .VGA_Y(VGA_Y),              // the output VGA y coordinate (row)
//        .VGA_COLOR(VGA_COLOR),      // the output VGA color
//        .VGA_SYNC(VGA_SYNC),        // indicates when background MIF has been drawn
//        .plot(plot));               // the output VGA plot signal
//		defparam VGA.RESOLUTION = RESOLUTION;
//        // choose background image according to resolution and color depth
//		defparam VGA.BACKGROUND_IMAGE = 
//            (RESOLUTION == "640x480") ?
//                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_640_9.mif" :
//                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_640_6.mif" :
//                "./MIF/rainbow_640_3.mif")) : 
//            ((RESOLUTION == "320x240") ?
//                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_320_9.mif" :
//                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_320_6.mif" :
//                "./MIF/rainbow_320_3.mif")) : 
//                    // 160x120
//                    ((COLOR_DEPTH == 9) ? "./MIF/rainbow_160_9.mif" :
//                    ((COLOR_DEPTH == 6) ? "./MIF/rainbow_160_6.mif" :
//                    "./MIF/rainbow_160_3.mif")));
//		defparam VGA.COLOR_DEPTH = COLOR_DEPTH;
//        
        assign LEDR[9] = VGA_SYNC;      // turn on LED when background drawing is done
endmodule
	

// n-bit register with reset and enable
module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= {n{1'b0}};
        else if (E)
            Q <= R;
endmodule

// n-bit up-counter with reset, load, and enable
module up_count (R, Clock, Resetn, L, E, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1)
            Q <= R;
        else if (E)
            Q <= Q + 1'b1;
endmodule


	
	
// FSM 1: Draw White Background



// Counter 1: Go through width, then increment y++ to go down 1 
// (0,0) is at top left and moves left to right, top 



// Don't KNOW

// USE colors example on docs


/*
=============================================================================
================================= NEXT STEP =================================
=============================================================================
*/

// ==================== GAME LOOP (2) Take in inputs ==============

// FSM 2: Draw Initialized black DOT at centre width/length