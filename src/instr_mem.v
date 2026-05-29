`timescale 1ns/1ps

module instr_mem (pc, instr);
    input  [31:0] pc;
    output [31:0] instr;

    reg [31:0] mem [0:255];
    assign instr = mem[pc[7:0]];   

    integer i;

    initial begin
        // clear IMEM
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;

        // Formats:
        // R-type : {op, rp, rd, rs, rt, 7'b0}
        // I-type : {op, rp, rd, rs, imm12}
        // J/CALL : {op, rp, off22}

        // ---------- Minimal setup ----------
        mem[0]  = 32'b00101_00000_00001_00000_000000001010; // ADDI Rp=R0 Rd=R1  Rs=R0 imm=10,result:R1=10
        mem[1]  = 32'b00101_00000_00010_00000_000000001111; // ADDI Rp=R0 Rd=R2  Rs=R0 imm=15,result:R2=15
        mem[2]  = 32'b00101_00000_00101_00000_000000000001; // ADDI Rp=R0 Rd=R5  Rs=R0 imm=1(predicate true),result:R5=1
        mem[3]  = 32'b00101_00000_00110_00000_000000000000; // ADDI Rp=R0 Rd=R6  Rs=R0 imm=0(predicate false),result:R6=0

        // ---------- R-type (executed with Rp=R5) ----------
        mem[4]  = 32'b00000_00101_00111_00001_00010_0000000; // ADD  Rp=R5 Rd=R7  Rs=R1 Rt=R2,result:R7=25
        mem[5]  = 32'b00001_00101_01000_00010_00001_0000000; // SUB  Rp=R5 Rd=R8  Rs=R2 Rt=R1,result:R8=5
        mem[6]  = 32'b00010_00101_01001_00001_00010_0000000; // OR   Rp=R5 Rd=R9  Rs=R1 Rt=R2,result:R9=15
        mem[7]  = 32'b00011_00101_01010_00001_00010_0000000; // NOR  Rp=R5 Rd=R10 Rs=R1 Rt=R2,result:R10=0xFFFFFFF0
        mem[8]  = 32'b00100_00101_01011_00001_00010_0000000; // AND  Rp=R5 Rd=R11 Rs=R1 Rt=R2,result:R11=10

        // ---------- I-type (executed with Rp=R5) ----------
        mem[9]  = 32'b00101_00101_01100_00001_000000000101;  // ADDI Rp=R5 Rd=R12 Rs=R1 imm=5,result:R12=15
        mem[10] = 32'b00110_00101_01101_00000_111111111111;  // ORI  Rp=R5 Rd=R13 Rs=R0 imm=0xFFF,result:R13=4095
        mem[11] = 32'b00111_00101_01110_00000_000000000000;  // NORI Rp=R5 Rd=R14 Rs=R0 imm=0,result:R14=0xFFFFFFFF
        mem[12] = 32'b01000_00101_01111_01101_000000001111;  // ANDI Rp=R5 Rd=R15 Rs=R13 imm=0x00F,result:R15=15

        // ---------- Memory (word addressed) ----------
        mem[13] = 32'b00101_00000_10000_00000_000000010100;  // ADDI Rp=R0 Rd=R16 Rs=R0 imm=20(base),result:R16=20

        mem[14] = 32'b01010_00110_01100_10000_000000000001;  // SW Rp=R6 data=R12 base=R16 off=1(cancelled),result:Mem[21]=unchanged
        mem[15] = 32'b01010_00000_01100_10000_000000000001;  // SW Rp=R0 data=R12 base=R16 off=1,result:Mem[21]=15
        mem[16] = 32'b01001_00000_10001_10000_000000000001;  // LW Rp=R0 Rd=R17 base=R16 off=1,result:R17=15

        // ---------- J (cancelled then taken) ----------
        mem[17] = 32'b01011_00110_0000000000000000000010;    // J Rp=R6 off=2(cancelled),result:PC+1
        mem[18] = 32'b00101_00000_10010_00000_000001001101;  // ADDI Rp=R0 Rd=R18 Rs=R0 imm=77,result:R18=77
        mem[19] = 32'b00101_00000_00110_00000_000000000001;  // ADDI Rp=R0 Rd=R6 Rs=R0 imm=1,result:R6=1
        mem[20] = 32'b01011_00110_0000000000000000000010;    // J Rp=R6 off=2(taken),result:PC=22
        mem[21] = 32'b00101_00000_10011_00000_001111100111;  // ADDI Rp=R0 Rd=R19 Rs=R0 imm=999(skipped),result:R19=0

        // ---------- CALL (cancelled then taken) ----------
        mem[22] = 32'b00101_00000_10100_00000_000000000000;  // ADDI Rp=R0 Rd=R20 Rs=R0 imm=0,result:R20=0
        mem[23] = 32'b01100_10100_0000000000000000000010;    // CALL Rp=R20 off=2(cancelled),result:no jump
        mem[24] = 32'b00101_00000_10101_00000_000000001010;  // ADDI Rp=R0 Rd=R21 Rs=R0 imm=10,result:R21=10

        mem[25] = 32'b01100_00110_0000000000000000001111;    // CALL Rp=R6 off=15,to mem[40],result:RA=26
        mem[26] = 32'b00101_00000_10110_00000_001000101011;  // ADDI Rp=R0 Rd=R22 Rs=R0 imm=555,result:R22=555

        mem[27] = 32'd0;                                     // NOP,result:no change
        mem[28] = 32'd0;                                     // NOP,result:no change

        // ---------- JR (cancelled then taken) ----------
        mem[29] = 32'b00101_00000_11000_00000_000000100011;  // ADDI Rp=R0 Rd=R24 Rs=R0 imm=35,result:R24=35
        mem[30] = 32'b00101_00000_11001_00000_000000000000;  // ADDI Rp=R0 Rd=R25 Rs=R0 imm=0,result:R25=0
        mem[31] = 32'b01101_11001_00000_11000_00000_0000000; // JR Rp=R25 Rs=R24(cancelled),result:PC+1
        mem[32] = 32'b00101_00000_11010_00000_000000000111;  // ADDI Rp=R0 Rd=R26 Rs=R0 imm=7,result:R26=7
        mem[33] = 32'b00101_00000_11001_00000_000000000001;  // ADDI Rp=R0 Rd=R25 Rs=R0 imm=1,result:R25=1
        mem[34] = 32'b01101_11001_00000_11000_00000_0000000; // JR Rp=R25 Rs=R24(taken),result:PC=35
        mem[35] = 32'b00101_00000_11011_00000_000001111011;  // ADDI Rp=R0 Rd=R27 Rs=R0 imm=123,result:R27=123

        // ---------- Stop ----------
        mem[36] = 32'b01011_00000_0000000000000000000000;    // J Rp=R0 off=0,infinite loop,result:halt

        // ---------- Function (CALL target @40) ----------
        mem[40] = 32'b00101_00000_10111_00000_000000101010;  // ADDI Rp=R0 Rd=R23 Rs=R0 imm=42,result:R23=42
        mem[41] = 32'b01101_00110_00000_11111_00000_0000000; // JR Rp=R6 Rs=R31,result:return to RA=26
    end

endmodule
