# Design and Verification of a Simplified Predicated RISC Processor

A Verilog-based implementation of a 32-bit Predicated RISC Processor featuring a custom instruction set architecture (ISA), modular datapath design, control unit implementation, and simulation-based verification.

---

## Features

>> 32-bit RISC processor architecture

>> 32 general-purpose registers (R0–R31)

>> Predicated instruction execution

>> Separate instruction and data memories

>> Modular datapath and control path design

>> Arithmetic and logical operations

>> Load and store memory instructions

>> Conditional and unconditional control flow instructions

>> Comprehensive testbench verification

---

## Supported Instructions

### Arithmetic & Logic

> ADD

> SUB

> AND

> OR

> NOR

> ADDI

> ANDI

> ORI

> NORI

### Memory Access

> LW (Load Word)

> SW (Store Word)

### Control Flow

> J (Jump)

> CALL

> JR (Jump Register)

---

## Processor Architecture

The processor consists of the following stages:


Fetch
  ↓
Decode
  ↓
Execute (ALU)
  ↓
Memory Access
  ↓
Write Back


The design includes:

> Program Counter (PC)

> Register File

> ALU

> Instruction Memory

> Data Memory

> Immediate Extender

> Multiplexers

> Control Unit

---

## Predicated Execution

A predicate register (Rp) determines whether an instruction executes.


If Reg[Rp] == 0
    Instruction is skipped

If Reg[Rp] != 0
    Instruction executes normally


This allows conditional execution without requiring additional branch instructions.

---

## Technologies Used

> Verilog HDL

> Digital Logic Design

> Computer Architecture

> RTL Design

> Simulation & Verification

---

## Verification

The processor functionality was verified using custom Verilog testbenches.

Verification covered:

> Arithmetic instructions

> Logical instructions

> Memory operations

> Jump instructions

> Predicated execution behavior

> Register write-back functionality

---

## Learning Outcomes

This project strengthened my understanding of:

> Processor microarchitecture

> Datapath and control unit design

> Instruction set architecture (ISA)

> RTL development using Verilog

> Hardware simulation and debugging

> Digital system verification

---

## Author

> Julnar Nall Assi

> Doaa Odeh

> Fatime Al-Zahraa

---

## Future Improvements

> Pipeline implementation

> Hazard detection and forwarding

> Additional instruction support

> Branch prediction mechanisms

> FPGA deployment and testing