`timescale 1ns/1ps

module reg_file (clk, reset, we, waddr, wdata, rs, rt, rd, rp, pc_value, rs_val, rt_val, rd_val, rp_val);

    input clk, reset;

    input we;                 // write enable
    input [4:0] waddr;        // to write
    input [31:0] wdata;       // data to write

    input [4:0] rs, rt, rd, rp;
    input [31:0] pc_value;

    output reg [31:0] rs_val, rt_val, rd_val, rp_val;

    reg [31:0] regs [0:31];
    integer i;

    // read registers (R0=0, R30=PC, R31=normal register)
    always @(*) begin
        if (rs == 5'd0)       rs_val = 32'd0;
        else if (rs == 5'd30) rs_val = pc_value;
        else                  rs_val = regs[rs];

        if (rt == 5'd0)       rt_val = 32'd0;
        else if (rt == 5'd30) rt_val = pc_value;
        else                  rt_val = regs[rt];

        if (rd == 5'd0)       rd_val = 32'd0;
        else if (rd == 5'd30) rd_val = pc_value;
        else                  rd_val = regs[rd];

        if (rp == 5'd0)       rp_val = 32'd0;
        else if (rp == 5'd30) rp_val = pc_value;
        else                  rp_val = regs[rp];
    end

    // write + reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end
        else begin
            // write to any register except R0 and R30 (PC)
            if (we && waddr != 5'd0 && waddr != 5'd30)
                regs[waddr] <= wdata;

            regs[0] <= 32'd0;
        end
    end

endmodule
