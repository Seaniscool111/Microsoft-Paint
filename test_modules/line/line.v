module line ( // using bresenhams line algorithm
    input Clock,
    input Resetn,
    input Go,

    input [9:0] mouse_x, mouse_y;

    output [9:0] vga_x,
    output [8:0] vga_y,
    output write,
)

    // wires
    

    // extract first coordinate and second coordinate
    wire extracted = 1'b0;
    wire d;
    reg [9:0] x1, x2, y1, y2;
    

    always @ (posedge Clock) begin
        if (!Resetn) begin
            x1 <= 10'b0;
            x2 <= 10'b0;
            y1 <= 10'b0;
            y2 <= 10'b0;
            extracted <= 1'b0;
            d <= 1'b0;
        end

        else begin
            if (extracted &&
                (mouse_x != x1 && mouse_y != y1)
                ) begin

                x2 <= mouse_x;
                y2 <= mouse_y; 
                d <= 1'b1;
                
            end
            else begin
                x1 <= mouse_x;
                y1 <= mouse_y;
                extracted <= 1'b1;
            end
        end
    end

    

    localparam IDLE = 2'b00, DRAW = 2'b01;
    reg [1:0] y_Q, Y_D;
    wire done;

    // NEXT state logic
    always @ (*) begin
        case (y_Q)
            IDLE: begin
                if (Go && ) Y_D = DRAW;
                else Y_D = IDLE;
            end

            DRAW: begin
                if (done)   Y_D = IDLE;
                else        Y_D = DRAW;
            end

            default: Y_D = IDLE;

        endcase
    end

    // shift registers
    always @ (posedge Clock) begin
        if (Resetn!) begin
            y_Q <= IDLE;
            write <= 1'b0;
        end

        else begin
            y_Q = Y_D;
        end
    end

    assign done = ()

    assign vga_x =
    assign vga_y = 
endmodule