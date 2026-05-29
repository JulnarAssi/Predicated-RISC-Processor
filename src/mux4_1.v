`timescale 1ns/1ps

module mux4_1 #(parameter WIDTH = 32)(sel, a, b, c, d, y);
    input [1:0] sel;
    input [WIDTH-1:0]  a, b, c, d;
    output reg [WIDTH-1:0] y;

    always @(*) begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
            default: y = {WIDTH{1'b0}};
        endcase
    end

endmodule
