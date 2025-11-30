`timescale 1ns / 1ps

module ID_EX(
    input clk,
    input reset,

    // Control signals from ID
    input Branch,  //taking all contorl signals as input from the decode stage //if branch instruction
    input MemRead, //if data needs to be read from data memory
    input MemWrite, //if data needs to be written to data memory
    input MemtoReg, //write data from memory or ALU
    input RegWrite, //if write back to register in WB stage, regfile write high
    input ALUSrc,  //if operand 2 is immediate or from register file 
    input [1:0] ALUOp, //opcode

    // Instruction fields 
    input [3:0] Funct, //this is 4 bit ALU operation code from funct3 and funct7
    input [4:0] Rs1,  
    input [4:0] Rs2,
    input [4:0] Rd,

    // Values from Instruction Decode stage 
    input [63:0] IFID_PCout,
    input [63:0] ReadData1,
    input [63:0] ReadData2,
    input [63:0] Imm,

    //Control signals to be passed to Execution phase
    output reg IDEX_Branch,
    output reg IDEX_MemRead,
    output reg IDEX_MemWrite,
    output reg IDEX_MemtoReg,
    output reg IDEX_RegWrite,
    output reg IDEX_ALUSrc,
    output reg [1:0] IDEX_ALUOp,

    // addresses and code to be passed to Execution phase
    output reg [3:0]   IDEX_Funct,
    output reg [4:0]   IDEX_Rs1,
    output reg [4:0]   IDEX_Rs2,
    output reg [4:0]   IDEX_Rd,

    // Data, PC+4 and immediate to be passed to Execution phase
    output reg [63:0]  IDEX_PCout,
    output reg [63:0]  IDEX_ReadData1,
    output reg [63:0]  IDEX_ReadData2,
    output reg [63:0]  IDEX_Imm
);

always @(posedge clk or posedge reset) begin
    if (reset) begin  //if reset is high
        // Clear control signals
        IDEX_Branch    <= 1'b0;
        IDEX_MemRead   <= 1'b0;
        IDEX_MemWrite  <= 1'b0;
        IDEX_MemtoReg  <= 1'b0;
        IDEX_RegWrite  <= 1'b0;
        IDEX_ALUSrc    <= 1'b0;
        IDEX_ALUOp     <= 2'b00;

        // Clear instruction fields
        IDEX_Funct     <= 4'b0000;
        IDEX_Rs1       <= 5'd0;
        IDEX_Rs2       <= 5'd0;
        IDEX_Rd        <= 5'd0;

        // Clear datapath values
        IDEX_PCout    <= 64'd0;
        IDEX_ReadData1 <= 64'd0;
        IDEX_ReadData2 <= 64'd0;
        IDEX_Imm       <= 64'd0;
    end
    else begin  //else if reset is low
        //control signals
        IDEX_Branch    <= Branch;
        IDEX_MemRead   <= MemRead;
        IDEX_MemWrite  <= MemWrite;
        IDEX_MemtoReg  <= MemtoReg;
        IDEX_RegWrite  <= RegWrite;
        IDEX_ALUSrc    <= ALUSrc;
        IDEX_ALUOp     <= ALUOp;
        
        //instruction fields
        IDEX_Funct     <= Funct;
        IDEX_Rs1       <= Rs1;
        IDEX_Rs2       <= Rs2;
        IDEX_Rd        <= Rd;
        
        // datapath values
        IDEX_PCout    <= IFID_PCout;
        IDEX_ReadData1 <= ReadData1;
        IDEX_ReadData2 <= ReadData2;
        IDEX_Imm       <= Imm;
    end
end

endmodule