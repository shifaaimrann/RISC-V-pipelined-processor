`timescale 1ns/1ps

module IFID(
    input clk,
    input reset,
    input flush,   // This signal is the addermuxselect signal which indicates if a branch is taken
    input [31:0] Instruction,   //The IFID register will store the instruction and PC from the fetch stage
    input [63:0] PC_Out,       //These stored values will be used by the decode stage
    output reg [31:0] IFID_Instruction,   //The output instruction and PC will be determined by reset signal
    output reg [63:0] IFID_PCout //keeping as reg because value assigned in always block
    );
    
always @(posedge clk) begin  
    if (reset == 1'b1 || flush == 1'b1) begin    //if reset signal is high
        IFID_Instruction = 0; IFID_PCout = 0;  //resetting the values of instruction and PC for decode
    end
    else begin   //if signal is low
        IFID_Instruction = Instruction;  //storing the instruction and PC from fetch stage 
        IFID_PCout = PC_Out;  //PC_Out will be the PC + 4 address incase the instruction is branch or jump
    end
end
endmodule