`timescale 1ns/1ps
module RISCV(
    input clk,
    input reset
    );

wire [3:0] funct; wire [2:0]funct3; wire [6:0] funct7;//functs 
wire S; wire [63:0] imm_shift; wire [63:0] immediate;
wire [63:0] pc_out;
wire [63:0] add_out; wire [63:0] off_out; wire [63:0] pc_in; 
wire [31:0] instruction;//instruction wires
wire [6:0] opcode; wire [4:0] rs1; wire [4:0] rs2; wire [4:0] rd; //instruction parser wires 
//control signal wires
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


Adder add_pc(pc_out, 64'd4, add_out); //output of PC+4 (next address of instruction)  

assign imm_shift=immediate<<1'b1;//shifting left for offset mux

Adder add_off(pc_out, imm_shift, off_out);//output of PC+offset (if branching)
mux mux1(S,add_out,off_out, pc_in);//mux to choose between add_out/off_out based on branching
Program_Counter pc1(pc_in, clk,reset,pc_out);//final program counter to give instruction address
Instruction_memory inst1(pc_out, instruction);//retrieving instruction from inst mem
insparser inspar1(instruction, opcode, rd,funct3,rs1,rs2,funct7);//parsing instrcuutcions
Control_Unit cu1(opcode, branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);//control unit for control signals
immediate imm1(instruction,immediate);//genertaing immediate

assign funct = {funct7[5], funct3[2:0]};//making up FUNCT

ALU_Control aluc1(aluop,funct,operation);//instantiating ALU_control
registerFile regFile1(writedata,rs1,rs2,rd,regwrite,clk,reset,data1,data2);//register file 
mux mux2(alusrc,data2,immediate, alub);//instantiating mux2 which choposes between immeiate and rs2 for ALU's second input
muxALU alu(data1,alub, operation,zero,blt,alu_result);// main ALU unit for doing caculations
assign actual_branch_condition = (funct3 == 3'b000) ? zero :   // If BEQ, check Zero
                                 (funct3 == 3'b100) ? blt :    // If BLT, check Less Than
                                 1'b0;                         // Default false
assign S= branch && actual_branch_condition;//selector bit for mux to choose bw pc+4 or pc+offset

Data_Memory dm1(alu_result,data2,clk,memwrite,memread,readdata);//reading and writign onto data

mux mux3(memtoreg,alu_result,readdata,writedata);//final mux to chose whether to writeback from alu result, or readdata
 




endmodule
