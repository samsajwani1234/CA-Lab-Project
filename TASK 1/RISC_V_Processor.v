`timescale 1ns / 1ps

module RISC_V_processor(
    input clk,             // Clock signal for synchronizing pipeline stages
    input reset,           // Reset signal to initialize program counter
    output wire [63:0] pc_out,          // Current PC value
    output wire [63:0] adder1_out,      // PC + 4 output
    output wire [63:0] adder2_out,      // Branch target address
    output wire [63:0] pc_in,           // Next PC value (selected between adder1 and adder2)
    output wire zero,                   // Zero flag from ALU indicating result == 0
    output wire [31:0] instruction,     // Fetched instruction
    output wire [6:0] opcode,           // Opcode field of instruction
    output wire [4:0] rd,               // Destination register index
    output wire [2:0] funct3,           // 3-bit function field
    output wire [4:0] rs1,              // Source register 1 index
    output wire [4:0] rs2,              // Source register 2 index
    output wire [6:0] funct7,           // 7-bit function field
    output wire [63:0] writedata,       // Data to write back to register file
    output wire [63:0] readdata1,       // Value read from rs1
    output wire [63:0] readdata2,       // Value read from rs2
    output wire branch, memread, memtoreg, memwrite, alusrc, regwrite, // Control signals
    output wire [1:0] aluop,            // ALU operation select from control unit
    output wire [63:0] immdata,         // Sign-extended immediate
    output wire [63:0] mux2out,         // ALU second operand
    output wire [3:0] operation,        // ALU control signals
    output wire [63:0] aluout,          // ALU result
    output wire [63:0] datamemoryreaddata, // Data loaded from memory
    output wire [63:0] element1, element2, element3, element4, element5, element6, element7// For wave display of 7 memory elements
);

wire branch_finale;              // Internal signal from branch unit
wire [3:0] funct;                // Combined funct7[5] and funct3 for ALU control
    
// PC increment: compute PC + 4
Adder A1(pc_out, 64'd4, adder1_out);

// PC select: choose between sequential or branch target
Mux M1(adder1_out, adder2_out, (branch && branch_finale), pc_in);

// Program counter register with reset
Program_Counter PC(clk, reset, pc_in, pc_out);

// Instruction fetch from instruction memory
Instruction_Memory IM(pc_out, instruction);

// Parse instruction fields into opcode, regs, functs
InsParser IP(instruction, opcode, rd, funct3, rs1, rs2, funct7);

// Control unit generates control signals from opcode
Control_Unit CU(opcode, branch, memread, memtoreg, memwrite, alusrc, regwrite, aluop);

// Register file: read/write registers
registerFile RF(writedata, rs1, rs2, rd, regwrite, clk, reset, readdata1, readdata2);

// Immediate generator: sign-extend immediate field
ImmGen IG(instruction, immdata);

// ALU operand mux: choose register or immediate
Mux M2(readdata2, immdata, alusrc, mux2out);

// Pack funct7[5] and funct3 into 4-bit for ALU control
assign funct = {instruction[30], instruction[14:12]};

// ALU control unit: decode ALU operation
ALU_Control AC(aluop, funct, operation);

// Branch target calculation: PC + immediate*2
Adder A2(pc_out, immdata*2, adder2_out);

// Main ALU operation
ALU_64_bit AB(readdata1, mux2out, operation, aluout, zero);

// Data memory access, expose 8 elements for debugging
Data_Memory DM(aluout, readdata2, clk, memwrite, memread, datamemoryreaddata,
               element1, element2, element3, element4, element5, element6, element7);

// Write-back mux: choose ALU result or memory data
Mux M3(aluout, datamemoryreaddata, memtoreg, writedata);

// Branch decision unit: zero/greater tests
branching_unit BU(funct3, readdata1, mux2out, branch_finale);

endmodule
