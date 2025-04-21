`timescale 1ns / 1ps

module RISC_V_processor(
input clk,
input reset,
output wire [63:0] pc_out,
output wire [63:0] adder1_out,
output wire [63:0] adder2_out,
output wire [63:0] pc_in,
output wire zero,
output wire [31:0] instruction,
output wire [6:0] opcode,
output wire [4:0] rd,
output wire [2:0] funct3,
output wire [4:0] rs1,
output wire [4:0] rs2,
output wire [6:0] funct7,
output wire [63:0]writedata,
output wire [63:0]readdata1,
output wire [63:0]readdata2,
output wire branch, memread, memtoreg, memwrite, alusrc, regwrite,
output wire [1:0] aluop,
output wire [63:0] immdata,
output wire [63:0] mux2out,
output wire [3:0] operation,
output wire [63:0] aluout,
output wire [63:0] datamemoryreaddata,
output wire [63:0] element1,
  output wire [63:0] element2,
  output wire [63:0] element3,
  output wire [63:0] element4,
  output wire [63:0] element5,
  output wire [63:0] element6,
  output wire [63:0] element7,
  output wire [63:0] element8
    );

wire branch_finale;
wire [3:0] funct;    
    
    
Adder A1(pc_out, 64'd4, adder1_out);

Mux M1(adder1_out, adder2_out,(branch && branch_finale) , pc_in);

Program_Counter PC(clk, reset, pc_in, pc_out);

Instruction_Memory IM(pc_out, instruction);

InsParser IP(instruction, opcode, rd, funct3, rs1, rs2, funct7);

Control_Unit CU(opcode, branch, memread, memtoreg, memwrite, alusrc, regwrite, aluop);

registerFile RF(writedata, rs1, rs2, rd, regwrite, clk, reset, readdata1, readdata2);

ImmGen IG(instruction, immdata);

Mux M2(readdata2, immdata, alusrc, mux2out);

assign funct = {instruction[30], instruction[14:12]};

ALU_Control AC(aluop, funct, operation);

Adder A2(pc_out, immdata*2, adder2_out);

ALU_64_bit AB(readdata1, mux2out, operation, aluout, zero);

Data_Memory DM(aluout, readdata2, clk, memwrite, memread, datamemoryreaddata, element1, element2, element3, element4, element5, element6, element7, element8);

Mux M3(aluout, datamemoryreaddata, memtoreg, writedata);

branching_unit BU(funct3, readdata1, mux2out, branch_finale);

endmodule
