`timescale 1ns/1ps

module data_mem (clk, addr, data_in, MemRd, MemWr, data_out);	 
    input clk;
    input  [31:0] addr;
    input  [31:0] data_in;
    input  MemRd;
    input  MemWr;
    output reg [31:0] data_out;

    reg [31:0] mem [0:255];

    // write or read memory on clock edge
    always @(posedge clk) begin
        if (MemWr) begin
            mem[addr[7:0]] <= data_in;
        end
        else if (MemRd) begin
            data_out <= mem[addr[7:0]];
        end
    end

    // initialize memory
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
    end
endmodule
