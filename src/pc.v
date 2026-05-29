`timescale 1ns/1ps

module pc (clk, reset, pc_write, pc_next, pc_out);
    input clk;
    input reset;
    input pc_write;
    input [31:0] pc_next;
    output reg [31:0] pc_out;

    // update PC on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'd0;       
        else if (pc_write)
            pc_out <= pc_next;      // load next PC value
    end
endmodule
