`timescale 1ns/1ps

module tb_control_unit;

    reg clk, reset;
    reg [4:0] opcode;
    reg pred_ok;
	reg [4:0] rd;

    wire pc_write, ir_write;
    wire mem_rd, mem_wr;
    wire reg_write, alu_src;
    wire [2:0] alu_op;
    wire [1:0] wb_sel;
    wire [1:0] pc_src;
	wire [1:0] waddr_sel;
    wire [2:0] state;

    // Instantiate the control unit
    control_unit dut (
        clk, reset, opcode, pred_ok, rd,
        pc_write, ir_write,
        mem_rd, mem_wr,
        reg_write, alu_src,
        alu_op, wb_sel, pc_src, waddr_sel,
        state
    );

    // 10ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Convert opcode to readable name
    function [8*8-1:0] op_name;
        input [4:0] op;
        begin
            case (op)
                5'd0:  op_name = "ADD";
                5'd1:  op_name = "SUB";
                5'd2:  op_name = "OR";
                5'd3:  op_name = "NOR";
                5'd4:  op_name = "AND";
                5'd5:  op_name = "ADDI";
                5'd6:  op_name = "ORI";
                5'd7:  op_name = "NORI";
                5'd8:  op_name = "ANDI";
                5'd9:  op_name = "LW";
                5'd10: op_name = "SW";
                5'd11: op_name = "J";
                5'd12: op_name = "CALL";
                5'd13: op_name = "JR";
                default: op_name = "UNKN";
            endcase
        end
    endfunction

    // Convert FSM state to stage name
    function [8*3-1:0] stage_name;
        input [2:0] st;
        begin
            case (st)
                3'd0: stage_name = "IF ";
                3'd1: stage_name = "ID ";
                3'd2: stage_name = "EX ";
                3'd3: stage_name = "MEM";
                3'd4: stage_name = "WB ";
                default: stage_name = "???";
            endcase
        end
    endfunction

    // Print one control line
    task print_line;
        input integer cyc;
        begin
            $display("%0d | %-3s(St=%0d) | pcW=%0b irW=%0b | memR=%0b memW=%0b | regW=%0b | aluS=%0b | aluOp=%0d | wb=%02b | pcSrc=%02b | waddrS=%02b",
                     cyc, stage_name(state), state,
                     pc_write, ir_write,
                     mem_rd, mem_wr,
                     reg_write,
                     alu_src,
                     alu_op,
                     wb_sel,
                     pc_src,
					 waddr_sel
            );
        end
    endtask

    // Run a single instruction (variable number of cycles)
    task run_instr;
        input [4:0] op;
        input p;
        integer cyc;
        begin
            // Wait until IF state
            while (state !== 3'd0) begin
                @(posedge clk); #1;
            end

            // Apply opcode and predication at start of IF
            opcode  = op;
            pred_ok = p;
            #1;

            $display("---- %0s pred_ok=%0d (opcode=%0d) ----", op_name(op), p, op);
            $display("===============================================================");
            $display("Cyc | Stage(State) | pcW irW | memR memW | regW | aluS | aluOp | wb | pcSrc");
            $display("---------------------------------------------------------------");

            // Cycle 1 = IF
            cyc = 1;
            print_line(cyc);

            // Continue until FSM goes back to IF
            while (1) begin
                @(posedge clk); #1;

                if (state == 3'd0) begin
                    $display("---------------------------------------------------------------");
                    $display("(Instruction cycles = %0d)", cyc);
                    break;
                end

                cyc = cyc + 1;
                print_line(cyc);
            end
        end
    endtask

    initial begin
        // Reset
        reset   = 1'b1;
        opcode  = 5'd0;
        pred_ok = 1'b0;
        repeat(2) @(posedge clk);
        reset = 1'b0;

        // Test all instructions
        run_instr(5'd0, 1);   // ADD
        run_instr(5'd1, 1);   // SUB
        run_instr(5'd2, 1);   // OR
        run_instr(5'd3, 1);   // NOR
        run_instr(5'd4, 1);   // AND

        run_instr(5'd5, 1);   // ADDI
        run_instr(5'd6, 1);   // ORI
        run_instr(5'd7, 1);   // NORI
        run_instr(5'd8, 1);   // ANDI

        run_instr(5'd9, 1);   // LW
        run_instr(5'd10, 1);  // SW

        run_instr(5'd11, 0);  // J cancelled
        run_instr(5'd11, 1);  // J taken

        run_instr(5'd12, 0);  // CALL cancelled
        run_instr(5'd12, 1);  // CALL taken

        run_instr(5'd13, 0);  // JR cancelled
        run_instr(5'd13, 1);  // JR taken

        $display("=== CONTROL UNIT TEST COMPLETE ===");
        $finish;
    end

endmodule
