`timescale 1ns/1ps
module IF_ID(
    input clk, input reset, input stall, input flush, 
    input [31:0] Instruction, input [63:0] PC_Out,
    output reg [31:0] IFID_Instruction, output reg [63:0] IFID_PCout
    );
    always @(posedge clk) begin  
        if (reset || flush) begin 
            IFID_Instruction <= 0; 
            IFID_PCout <= 0;
        end else if (!stall) begin 
            IFID_Instruction <= Instruction; IFID_PCout <= PC_Out;
        end
    end
endmodule