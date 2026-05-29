`timescale 1ns/1ps

module tb_cpu_top;

    reg clk, reset;

    cpu_top dut (.clk(clk), .reset(reset));

    integer errors;
    integer i;

    // 10ns clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task check;
        input [127:0] name;
        input [31:0]  got;
        input [31:0]  exp;
        begin
            if (got !== exp) begin
                $display("FAIL %-5s | exp=%-11d | got=%-11d (0x%08h)", name, exp, got, got);
                errors = errors + 1;
            end else begin
                $display("PASS %-5s | exp=%-11d | got=%-11d (0x%08h)", name, exp, got, got);
            end
        end
    endtask

    initial begin
        errors = 0;

        // reset pulse (2 cycles)
        reset = 1'b1;
        repeat (2) begin
            @(posedge clk);
            #1;
        end
        reset = 1'b0;

        repeat (600) begin
            @(posedge clk);
            #1;
        end

        $display("==============================================");
        $display("CHECKING RESULTS");
        $display("==============================================");

        // ---------- Setup ----------
        check("R1",  dut.RF0.regs[1],   32'd10);
        check("R2",  dut.RF0.regs[2],   32'd15);
        check("R5",  dut.RF0.regs[5],   32'd1);
        check("R6",  dut.RF0.regs[6],   32'd1);

        // ---------- R-type ----------
        check("R7",  dut.RF0.regs[7],   32'd25);
        check("R8",  dut.RF0.regs[8],   32'd5);
        check("R9",  dut.RF0.regs[9],   32'd15);
        check("R10", dut.RF0.regs[10],  32'hFFFFFFF0);
        check("R11", dut.RF0.regs[11],  32'd10);

        // ---------- I-type ----------
        check("R12", dut.RF0.regs[12],  32'd15);
        check("R13", dut.RF0.regs[13],  32'd4095);
        check("R14", dut.RF0.regs[14],  32'hFFFFFFFF);
        check("R15", dut.RF0.regs[15],  32'd15);

        // ---------- Memory ----------
        check("R16", dut.RF0.regs[16],  32'd20);
        check("M21", dut.DM0.mem[21],   32'd15);
        check("R17", dut.RF0.regs[17],  32'd15);

        // ---------- J ----------
        check("R18", dut.RF0.regs[18],  32'd77);
        check("R19", dut.RF0.regs[19],  32'd0);

        // ---------- CALL cancelled + taken ----------
        check("R20", dut.RF0.regs[20],  32'd0);
        check("R21", dut.RF0.regs[21],  32'd10);

        // CALL taken at mem[25] => RA = 26
        check("RA",  dut.RF0.regs[31],  32'd26);
        check("R23", dut.RF0.regs[23],  32'd42);
        check("R22", dut.RF0.regs[22],  32'd555);

        // ---------- JR cancelled + taken ----------
        check("R24", dut.RF0.regs[24],  32'd35);
        check("R25", dut.RF0.regs[25],  32'd1);
        check("R26", dut.RF0.regs[26],  32'd7);
        check("R27", dut.RF0.regs[27],  32'd123);

        $display("==============================================");
        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TOTAL FAILS = %0d", errors);
        end
        $display("==============================================");

        $finish;
    end

endmodule
