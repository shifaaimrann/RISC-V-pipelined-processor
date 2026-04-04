//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.11.2025 20:16:12
// Design Name: 
// Module Name: IDEX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module ID_EX(
    input clk, input reset, input flush, 
    input Branch, input MemRead, input MemWrite, input MemtoReg, input RegWrite, input ALUSrc, input [1:0] ALUOp,
    input [3:0] Funct, input [4:0] Rs1, input [4:0] Rs2, input [4:0] Rd,
    input [63:0] IFID_PCout, input [63:0] ReadData1, input [63:0] ReadData2, input [63:0] Imm,
    output reg IDEX_Branch, output reg IDEX_MemRead, output reg IDEX_MemWrite, output reg IDEX_MemtoReg, output reg IDEX_RegWrite, output reg IDEX_ALUSrc, output reg [1:0] IDEX_ALUOp,
    output reg [3:0] IDEX_Funct, output reg [4:0] IDEX_Rs1, output reg [4:0] IDEX_Rs2, output reg [4:0] IDEX_Rd,
    output reg [63:0] IDEX_PCout, output reg [63:0] IDEX_ReadData1, output reg [63:0] IDEX_ReadData2, output reg [63:0] IDEX_Imm
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin // Flush logic
            IDEX_Branch <= 0; IDEX_MemRead <= 0; IDEX_MemWrite <= 0; IDEX_MemtoReg <= 0;
            IDEX_RegWrite <= 0; IDEX_ALUSrc <= 0; IDEX_ALUOp <= 0;
            IDEX_Funct <= 0; IDEX_Rs1 <= 0; IDEX_Rs2 <= 0; IDEX_Rd <= 0;
            IDEX_PCout <= 0; IDEX_ReadData1 <= 0; IDEX_ReadData2 <= 0; IDEX_Imm <= 0;
        end else begin
            IDEX_Branch <= Branch; IDEX_MemRead <= MemRead; IDEX_MemWrite <= MemWrite; IDEX_MemtoReg <= MemtoReg;
            IDEX_RegWrite <= RegWrite; IDEX_ALUSrc <= ALUSrc; IDEX_ALUOp <= ALUOp;
            IDEX_Funct <= Funct; IDEX_Rs1 <= Rs1; IDEX_Rs2 <= Rs2; IDEX_Rd <= Rd;
            IDEX_PCout <= IFID_PCout; IDEX_ReadData1 <= ReadData1; IDEX_ReadData2 <= ReadData2; IDEX_Imm <= Imm;
        end
    end
endmodule
