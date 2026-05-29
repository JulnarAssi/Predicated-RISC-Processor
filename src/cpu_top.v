`timescale 1ns/1ps

module cpu_top (clk, reset);
    input clk, reset;

    wire pc_write, ir_write;
    wire mem_rd, mem_wr;
    wire reg_write, alu_src;
    wire [2:0] alu_op;
    wire [1:0] wb_sel;
    wire [1:0] pc_src;
	wire [1:0] waddr_sel;

    wire [2:0] state;

    wire [31:0] pc_out;
    wire [31:0] pc_next;

    pc PC0 (clk, reset, pc_write, pc_next, pc_out);

    wire [31:0] instr;
    instr_mem IM0 (pc_out, instr);

    // Instruction register + PC of this instruction
    reg [31:0] IR;
    reg [31:0] pc_ir_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IR        <= 32'd0;
            pc_ir_reg <= 32'd0;
        end else if (ir_write) begin
            IR        <= instr;
            pc_ir_reg <= pc_out;
        end
    end

    wire [4:0] opcode = IR[31:27];
    wire [4:0] rp     = IR[26:22];

    wire [4:0] rd_r   = IR[21:17];
    wire [4:0] rs_r   = IR[16:12];
    wire [4:0] rt_r   = IR[11:7];

    wire [4:0] rd_i   = IR[21:17];
    wire [4:0] rs_i   = IR[16:12];
    wire [11:0] imm12 = IR[11:0];

    wire [21:0] off22 = IR[21:0];

    wire is_imm = (opcode == 5'd5 || opcode == 5'd6 || opcode == 5'd7 ||
                   opcode == 5'd8 || opcode == 5'd9 || opcode == 5'd10);

    wire is_rtype = (opcode == 5'd0 || opcode == 5'd1 || opcode == 5'd2 ||
                     opcode == 5'd3 || opcode == 5'd4);

    // Choose register fields based on instruction type
    wire [4:0] rs = is_imm   ? rs_i : rs_r;
    wire [4:0] rt = is_rtype ? rt_r : 5'd0;
    wire [4:0] rd = is_imm   ? rd_i : rd_r;

    wire [4:0] waddr;
    wire [31:0] wdata;

    wire [31:0] rs_val, rt_val, rd_val, rp_val;

    reg_file RF0 (
        clk, reset, reg_write, waddr, wdata,
        rs, rt, rd, rp,
        pc_out,
        rs_val, rt_val, rd_val, rp_val
    );

    // pred_ok: Rp=R0 => always execute, else execute if Rp != 0
    wire pred_ok;
    assign pred_ok = (rp == 5'd0) ? 1'b1 : (rp_val != 32'd0);

    control_unit CU0 (
        clk, reset, opcode, pred_ok, rd,
        pc_write, ir_write,
        mem_rd, mem_wr,
        reg_write, alu_src,
        alu_op,
        wb_sel, pc_src, waddr_sel,
        state
    );

    // ID stage registers
    reg [31:0] A_reg, B_reg, D_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A_reg <= 32'd0;
            B_reg <= 32'd0;
            D_reg <= 32'd0;
        end else if (state == 3'd1) begin
            A_reg <= rs_val;
            B_reg <= rt_val;
            D_reg <= rd_val;
        end
    end

    // Immediate extension type (0=zero, 1=sign)
    wire ext_op = (opcode == 5'd6 || opcode == 5'd7 || opcode == 5'd8) ? 1'b0 : 1'b1;

    wire [31:0] imm_ext;
    extender #(.IN_WIDTH(12)) EXT0 (imm12, ext_op, imm_ext);

    // ALU second operand select
    wire [31:0] alu_in_b;
    mux2_1 MUX_ALU_B (alu_src, B_reg, imm_ext, alu_in_b);

    wire [31:0] alu_y;
    alu ALU0 (A_reg, alu_in_b, alu_op, alu_y);

    // ALUOut register
    reg [31:0] ALUOut;
    always @(posedge clk or posedge reset) begin
        if (reset)
            ALUOut <= 32'd0;
        else if (state == 3'd2)
            ALUOut <= alu_y;
    end

    // Data memory
    wire [31:0] mem_data_out;
    data_mem DM0 (clk, ALUOut, D_reg, mem_rd, mem_wr, mem_data_out);

    // Save PC+1 for CALL
    reg [31:0] pc_plus1_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_plus1_reg <= 32'd0;
        else if (ir_write)
            pc_plus1_reg <= pc_out + 32'd1;
    end

    wire [31:0] pc_plus1 = pc_out + 32'd1;

    // Jump offset sign-extend using extender22
    wire [31:0] off22_ext;
    extender #(.IN_WIDTH(22)) EXT_OFF22 (off22, 1'b1, off22_ext);

    // J/CALL target uses pc_ir_reg
    wire [31:0] pc_jump = pc_ir_reg + off22_ext;

    // JR: in ID use rs_val directly, otherwise use A_reg
    wire [31:0] pc_jr = (state == 3'd1) ? rs_val : A_reg;

    mux4_1 #(.WIDTH(32)) MUX_PC (
        pc_src,
        pc_jump,
        pc_plus1,
        pc_jr,
        pc_plus1,
        pc_next
    );

    mux4_1 #(.WIDTH(32)) MUX_WDATA (
        wb_sel,
        ALUOut,
        mem_data_out,
        pc_plus1_reg,
        32'd0,
        wdata
    ); 


    mux4_1 #(.WIDTH(5)) MUX_WADDR (
        waddr_sel,
        rd,        // 00
        5'd0,      // 01
        5'd31,     // 10
        rd,        // 11 (unused)
        waddr
    );


endmodule
