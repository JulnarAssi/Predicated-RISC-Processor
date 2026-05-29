`timescale 1ns/1ps

module extender #(parameter IN_WIDTH = 12)(in, op, out);
    input [IN_WIDTH-1:0] in;
    input op;      // 0: zero extend, 1: sign extend
    output reg [31:0] out;

    always @(*) begin
        case (op)
            1'b0: out = {{(32-IN_WIDTH){1'b0}}, in};             // zero extend
            1'b1: out = {{(32-IN_WIDTH){in[IN_WIDTH-1]}}, in};  // sign extend
            default: out = 32'd0;
        endcase
    end

endmodule
