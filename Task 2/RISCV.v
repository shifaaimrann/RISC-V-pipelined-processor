
`timescale 1ns/1ps 

module RISCV(
    input clk,
    input reset
    );

wire [3:0] funct; wire [2:0]funct3; wire [6:0] funct7;
wire S; wire [63:0] imm_shift; wire [63:0] immediate;
wire [63:0] pc_out;
wire [63:0] add_out; wire [63:0] off_out; wire [63:0] pc_in; 
wire [31:0] instruction;
wire [6:0] opcode; wire [4:0] rs1; wire [4:0] rs2; wire [4:0] rd; 
wire branch, memread, memtoreg,memwrite,alusrc,regwrite;
wire [1:0] aluop;
wire actual_branch_condition;
wire [3:0] operation;
wire [63:0] writedata;
wire [63:0] data1;
wire [63:0] data2;
wire [63:0] alub;
wire zero; wire blt;
wire [63:0] alu_result;
wire [63:0] readdata;


Adder add_pc(pc_out, 64'd4, add_out); 

// FIX 1: Removed the extra shift. Immediate is already handled in the generator.
assign imm_shift = immediate;

Adder add_off(pc_out, imm_shift, off_out);
mux mux1(S,add_out,off_out, pc_in);
Program_Counter pc1(pc_in, clk,reset,pc_out);
Instruction_memory inst1(pc_out, instruction);
insparser inspar1(instruction, opcode, rd,funct3,rs1,rs2,funct7);
Control_Unit cu1(opcode, aluop, branch, memread, memtoreg, memwrite, alusrc, regwrite);
immediate imm1(instruction,immediate);

assign funct = {funct7[5], funct3[2:0]};

ALU_Control aluc1(aluop,funct,operation);

// FIX 2: Named Instantiation for Register File
registerFile regFile1(
    .writeData(writedata),
    .RS1(rs1),
    .RS2(rs2),
    .RD(rd),
    .RegWrite(regwrite),
    .clk(clk),
    .reset(reset),
    .ReadData1(data1),
    .ReadData2(data2)
);

mux mux2(alusrc,data2,immediate, alub);

muxALU alu(data1,alub, operation,zero,blt,alu_result);

// Branch Logic
assign actual_branch_condition = (funct3 == 3'b000) ? zero :    // BEQ
                                 (funct3 == 3'b100) ? blt :     // BLT
                                 (funct3 == 3'b001) ? ~zero :   // BNE (Optional support)
                                 (funct3 == 3'b101) ? ~blt :    // BGE (Optional support)
                                 1'b0;                          

assign S = branch && actual_branch_condition;

// FIX 3: CRITICAL - Named Instantiation for Data Memory
// Previously, wires were mapped to the wrong ports (e.g. memread was connected to clk!)
Data_Memory dm1(
    .Mem_Addr(alu_result),
    .Write_Data(data2),
    .clk(clk),
    .MemWrite(memwrite),
    .MemRead(memread),
    .Read_Data(readdata)
);

mux mux3(memtoreg,alu_result,readdata,writedata);
 
endmodule