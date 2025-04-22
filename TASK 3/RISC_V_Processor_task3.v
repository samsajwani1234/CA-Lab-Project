module RISC_V_Processor_task3(
  input clk,
  input reset,
  input wire[63:0] element1,
  input wire[63:0] element2,
  input wire[63:0] element3,
  input wire[63:0] element4,
  input wire[63:0] element5,
  input wire[63:0] element6,
  input wire[63:0] element7,
  input stall, flush);
  
  wire branch;
  wire memread;
  wire memtoreg;
  wire memwrite;
  wire ALUsrc;
  wire regwrite;
  wire [1:0] ALUop;
  
  wire regwrite_memwb_out;
  wire [63:0] readdata1, readdata2;
  wire [63:0] r8, r19, r20, r21, r22;
  wire [63:0] write_data;
  
  wire [63:0] pc_in;
  wire [63:0] pc_out;
  
  wire [63:0] adderout1;
  wire [63:0] adderout2;
  
  wire [31:0] instruction;
  wire[31:0] inst_ifid_out;
  
  wire [6:0] opcode;
  wire [4:0] rd, rs1, rs2;
  wire [2:0] funct3;
  wire [6:0] funct7;
  
  
  wire [63:0] imm_data;
   
  wire [63:0] random;
 
  wire [63:0] a1;
  wire [4:0] RS1;
  wire [4:0] RS2;
  wire [4:0] RD;
  wire [63:0] d, M1, M2;
  wire Branch;
  wire Memread;
  wire Memtoreg;
  wire Memwrite;
  wire Regwrite;
  wire Alusrc;
  wire [1:0] aluop;
  wire [3:0] funct4_out;
  
  wire [63:0] threeby1_out1;
  wire[63:0] threeby1_out2;
  wire[63:0]  alu_64_b;
  
  wire [63:0] write_Data;
  wire [63:0] exmem_out_adder;
  wire exmem_out_zero;
  wire [63:0] exmem_out_result;
  wire [4:0] exmemrd;
  wire BRANCH,MEMREAD,MEMTOREG,MEMEWRITE,REGWRITE;   
  
  wire [63:0] AluResult;
  wire zero;
  
  wire [3:0] operation;
  
  wire [63:0] readdata;
 
  wire[63:0] muxin1,muxin2;
  wire [4:0] memwbrd;
  wire memwb_memtoreg;
  wire memwb_regwrite;
  
  wire [1:0] forwardA;
  wire [1:0] forwardB;
  
  wire addermuxselect;
  wire branch_final;
  
  
  pipeline_flush pf1
  (
    .branch(branch_final & BRANCH),
    .flush(flush)
  );
  
  
  hazard_detection_unit hdu
  (
    .Memread(Memread),
    .inst(inst_ifid_out),
    .Rd(RD),
    .stall(stall) // generate stall if hazard detected
  );

  
  Program_Counter_task3 pc3
  (
    .PC_in(pc_in),
    .stall(stall), // freeze PC when stall==1
    .clk(clk),
    .reset(reset),
    .PC_out(pc_out)
  );
  
  Instruction_Memory im
  (
    .Inst_Address(pc_out),
    .Instruction(instruction)
  );
  
  
  Adder adder1
  (
    .a(pc_out),
    .b(64'd4),
    .out(adderout1)
  );
  
   ifidreg_task3 if_id1
  (
    .clk(clk),
    .reset(reset),
    .IFIDWrite(stall),
    .instruction(instruction),
    .A(pc_out),
    .inst(inst_ifid_out),
    .a_out(random),
    .flush(flush)
  );
  
  InsParser ip
  (
    .instruction(inst_ifid_out),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
  );
  
  Control_Unit_task3 cu
  (
    .opcode(opcode),
    .branch(branch),
    .memread(memread),
    .memtoreg(memtoreg),
    .memwrite(memwrite),
    .aluSrc(ALUsrc),
    .regwrite(regwrite),
    .Aluop(ALUop),
    .stall(stall)
  );
  
  data_extractor immextr
  (
    .instruction(inst_ifid_out),
    .imm_data(imm_data)
  );
  
  
  registerFile_task3 regfile 
  (
    .clk(clk),
    .reset(reset),
    .rs1(rs1),
    .rs2(rs2),
    .rd(memwbrd),
    .writedata(write_data),
    .reg_write(memwb_regwrite),
    .readdata1(readdata1),
    .readdata2(readdata2),
    .r8(r8),
    .r19(r19),
    .r20(r20),
    .r21(r21),
    .r22(r22)
  );
  
  idexreg_task3 id_ex
  (
    .clk(clk),
    .flush(flush),
    .reset(reset),
    .funct4_in({inst_ifid_out[30],inst_ifid_out[14:12]}),
    .A_in(random),
    .readdata1_in(readdata1),
    .readdata2_in(readdata2),
    .imm_data_in(imm_data),
    .rs1_in(rs1),.rs2_in(rs2),.rd_in(rd),
    .branch_in(branch),.memread_in(memread),.memtoreg_in(memtoreg),
    .memwrite_in(memwrite),.aluSrc_in(ALUsrc),.regwrite_in(regwrite),.Aluop_in(ALUop),
    .a(a1),.rs1(RS1),.rs2(RS2),.rd(RD),.imm_data(d),.readdata1(M1),.readdata2(M2),
    .funct4_out(funct4_out),.Branch(Branch),.Memread(Memread),.Memtoreg(Memtoreg),
    .Memwrite(Memwrite),.Regwrite(Regwrite),.Alusrc(Alusrc),.aluop(aluop)
  );
  Adder adder2
  (
    .a(a1),
    .b(d << 1),
    .out(adderout2)
  );
  
  
  mux_3to1 m1
  (
    .a(M1),.b(write_data),.c(exmem_out_result),.sel(forwardA),.out(threeby1_out1)
  );
  
  mux_3to1 m2
  (
    .a(M2),.b(write_data),.c(exmem_out_result),.sel(forwardB),.out(threeby1_out2)
  );
  
  Mux mux1
  (
    .a(threeby1_out2),.b(d),.s(Alusrc),.data_out(alu_64_b)
  );
  
  ALU_64_bit alu
  (
    .a(threeby1_out1),
    .b(alu_64_b),
    .ALUOp(operation),
    .Result(AluResult),
    .ZERO(zero)
  );
  
   ALU_Control ac
  (
    .ALUOp(aluop),
    .Funct(funct4_out),
    .Operation(operation)
  );
  
 
  
  exmemreg_task3 ex_mem
  (
    .clk(clk),.reset(reset),.Adder_out(adderout2),.Result_in_alu(AluResult),.Zero_in(zero),.flush(flush),
    .writedata_in(threeby1_out2),.Rd_in(RD), .addermuxselect_in(addermuxselect),
    .branch_in(Branch),.memread_in(Memread),.memtoreg_in(Memtoreg),.memwrite_in(Memwrite),.regwrite_in(Regwrite),
    .Adderout( exmem_out_adder),.zero(exmem_out_zero),.result_out_alu(exmem_out_result),.writedata_out(write_Data),
    .rd(exmemrd),.Branch(BRANCH),.Memread(MEMREAD),.Memtoreg(MEMTOREG),.Memwrite(MEMEWRITE),.Regwrite(REGWRITE), .addermuxselect(branch_final)
  );
    
  Data_Memory datamem
  (
    .Write_Data(write_Data),
    .Mem_Addr(exmem_out_result),
    .MemWrite(MEMEWRITE),
    .clk(clk),
    .MemRead(MEMREAD),
    .Read_Data(readdata),
    .element1(element1),
    .element2(element2),
    .element3(element3),
    .element4(element4),
    .element5(element5),
    .element6(element6),
    .element7(element7)
      );
  
  
  Mux mux2
  (
    .a(adderout1),.b(exmem_out_adder),.s(BRANCH & branch_final),.data_out(pc_in) // ??
  );

 
  memwbreg_task3 mem_wb
  
  (
    .clk(clk),.reset(reset),.read_data_in(readdata),
    .result_alu_in(exmem_out_result),.Rd_in(exmemrd),.memtoreg_in(MEMTOREG),.regwrite_in(REGWRITE),
    .readdata(muxin1),.result_alu_out(muxin2),.rd(memwbrd),.Memtoreg(memwb_memtoreg),.Regwrite(memwb_regwrite)
  );
  
   Mux mux3
  (
    .a(muxin2),.b(muxin1),.s(memwb_memtoreg),.data_out(write_data)
  );
  
  
   forwardingunit fu1
  (
    .RS_1(RS1),.RS_2(RS2),.rdMem(exmemrd),
    .rdWb(memwbrd),.regWrite_Wb(memwb_regwrite),
    .regWrite_Mem(REGWRITE),
    .Forward_A(forwardA),.Forward_B(forwardB)
  );
  
  
  branching_unit bu1
  (
    .funct3(funct4_out[2:0]),.readData1(M1),.b(alu_64_b),.addermuxselect(addermuxselect)
  );

        
endmodule 