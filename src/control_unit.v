`timescale 1ns/1ps

module control_unit (clk, reset, opcode, pred_ok, rd, pc_write, ir_write, mem_rd, mem_wr, reg_write, alu_src, alu_op, wb_sel, pc_src, waddr_sel, state);
    input clk,reset;
    input [4:0] opcode;
    input pred_ok;
	input  [4:0] rd;
	
    output reg pc_write;
    output reg ir_write;
    output reg mem_rd;
    output reg mem_wr;
    output reg reg_write;
    output reg alu_src;
    output reg [2:0] alu_op;   // 0:add 1:sub 2:or 3:nor 4:and
    output reg [1:0] wb_sel;   // 00:ALUOut 01:MDR 10:PC+1
    output reg [1:0] pc_src;   // 00:J/CALL 01:PC+1 10:JR
	output reg [1:0] waddr_sel;  // 00: rd , 01: R0 (block), 10: R31 (CALL)
    output reg [2:0] state;

    reg [2:0] next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) state <= 3'd0;      // IF
        else state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = 3'd0; // default IF

        case (state)
            3'd0: next_state = 3'd1;   // IF -> ID

            3'd1: begin                // ID
                if (!pred_ok) next_state = 3'd0;      // cancel
                else if (opcode == 5'd11) next_state = 3'd0; // J
                else if (opcode == 5'd13) next_state = 3'd0; // JR
                else if (opcode == 5'd12) next_state = 3'd4; // CALL -> WB
                else next_state = 3'd2;               // others -> EX
            end

            3'd2: begin                // EX
                if (opcode == 5'd9 || opcode == 5'd10) next_state = 3'd3; // LW/SW
                else next_state = 3'd4;                                   // ALU -> WB
            end

            3'd3: begin                // MEM
                if (opcode == 5'd9) next_state = 3'd4; // LW -> WB
                else next_state = 3'd0;                // SW -> IF
            end

            3'd4: next_state = 3'd0;   // WB -> IF
        endcase
    end

    // Control outputs
    always @(*) begin
        // defaults
        pc_write  = 1'b0;
        ir_write  = 1'b0;
        mem_rd    = 1'b0;
        mem_wr    = 1'b0;
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_op    = 3'd0;
        wb_sel    = 2'b00;
        pc_src    = 2'b01;
		waddr_sel = 2'b00;  

        case (state)
            3'd0: begin // IF
                ir_write = 1'b1;
                pc_write = 1'b1;
                pc_src   = 2'b01;      // PC+1
            end

            3'd1: begin // ID (resolve jumps if not cancelled)
                if (pred_ok) begin
                    if (opcode == 5'd11) begin        // J
                        pc_src   = 2'b00;
                        pc_write = 1'b1;
                    end else if (opcode == 5'd13) begin // JR
                        pc_src   = 2'b10;
                        pc_write = 1'b1;
                    end else if (opcode == 5'd12) begin // CALL
                        pc_src   = 2'b00;
                        pc_write = 1'b1;
                    end
                end
            end

            3'd2: begin // EX
                alu_src = (opcode == 5'd5 || opcode == 5'd6 || opcode == 5'd7 ||
                           opcode == 5'd8 || opcode == 5'd9 || opcode == 5'd10);

                if      (opcode == 5'd0)  alu_op = 3'd0;
                else if (opcode == 5'd1)  alu_op = 3'd1;
                else if (opcode == 5'd2)  alu_op = 3'd2;
                else if (opcode == 5'd3)  alu_op = 3'd3;
                else if (opcode == 5'd4)  alu_op = 3'd4;
                else if (opcode == 5'd5)  alu_op = 3'd0; // ADDI
                else if (opcode == 5'd6)  alu_op = 3'd2; // ORI
                else if (opcode == 5'd7)  alu_op = 3'd3; // NORI
                else if (opcode == 5'd8)  alu_op = 3'd4; // ANDI
                else if (opcode == 5'd9)  alu_op = 3'd0; // LW addr
                else if (opcode == 5'd10) alu_op = 3'd0; // SW addr
            end

            3'd3: begin // MEM
                if (opcode == 5'd9)  mem_rd = pred_ok;
                if (opcode == 5'd10) mem_wr = pred_ok;
            end

            3'd4: begin // WB  	   	
                if (opcode == 5'd0 || opcode == 5'd1 || opcode == 5'd2 ||
                    opcode == 5'd3 || opcode == 5'd4 || opcode == 5'd5 ||
                    opcode == 5'd6 || opcode == 5'd7 || opcode == 5'd8 ||
                    opcode == 5'd9 || opcode == 5'd12)
                    reg_write = pred_ok; 

                if (opcode == 5'd9)       wb_sel = 2'b01; // LW
                else if (opcode == 5'd12) wb_sel = 2'b10; // CALL uses PC+1 path
                else    wb_sel = 2'b00;	
					
				waddr_sel = 2'b00;
				if (reg_write && pred_ok) begin
                    if (opcode == 5'd12)          
                        waddr_sel = 2'b10;        // force R31
                else if (rd == 5'd31)
                    waddr_sel = 2'b01;        // block illegal write to R31 -> R0
                end
            end
        endcase
    end

endmodule
