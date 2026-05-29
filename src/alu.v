`timescale 1ns/1ps

module alu (a, b, op, y);
    input  [31:0] a;
    input  [31:0] b;
    input  [2:0]  op;		  // 0:add 1:sub 2:or 3:nor 4:and
    output reg [31:0] y;

    always @(*) begin
        case (op)
            3'd0: y = a + b;		 // ADD (also used for address calc)
            3'd1: y = a - b;
            3'd2: y = a | b;
            3'd3: y = ~(a | b);
            3'd4: y = a & b;
            default: y = 32'd0;
        endcase
    end
endmodule
