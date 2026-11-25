module line (
    input Clock,
    input Resetn,
    input Go,

    input [3:0] size

    output [9:0] vga_x,
    output [8:0] vga_y,
    output write,
)
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