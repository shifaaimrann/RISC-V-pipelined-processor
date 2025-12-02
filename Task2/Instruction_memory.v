`timescale 1ns/1ps
module Instruction_memory(
    input [63:0] Inst_address,
    output reg [31:0] Instruction
    );
    reg [31:0] inst_mem [127:0];
    //instruction address is 0
    initial begin
inst_mem[0]=32'h00500293;
inst_mem[1]=32'h00600313;
inst_mem[2]=32'h005303b3;


    end
    
    always @(*) begin
    //assigning instrucion 4 bytes based on Inst-address(0,4,8,12)
    Instruction = inst_mem[Inst_address[31:2]];
    end
    
    
endmodule
