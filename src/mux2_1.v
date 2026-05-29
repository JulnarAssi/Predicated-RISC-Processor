`timescale 1ns/1ps

module mux2_1 (sel, a, b, y);
    input  sel;
    input  [31:0] a, b;
    output [31:0] y;

    assign y = sel ? b : a;
endmodule
