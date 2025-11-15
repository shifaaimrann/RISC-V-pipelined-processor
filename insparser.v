`timescale 1ns/1ps

module insparser(
input [31:0] instruction,
output [6:0] opcode,
output [4:0] rd,
output [2:0] funct3,
output [4:0] rs1,
output [4:0] rs2,
output [6:0] funct7

);
assign opcode=instruction [6:0];//least significant 6 bits
assign rd=instruction[11:7];//7 bits fro destination register
assign funct3= instruction [14:12];//3 bits for funct3
assign rs1=instruction [19:15];//5 bits corresponding to rs1
assign rs2=instruction [24:20];//5 bits corresponding to rs2
assign funct7=instruction [31:25];//7 bits for funct7
endmodule
