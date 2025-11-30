`timescale 1ns/1ps
module Instruction_memory(
    input [63:0] Inst_address,
    output reg [31:0] Instruction
    );
    reg [31:0] inst_mem [63:0];
    //instruction address is 0
    initial begin
       inst_mem[0]=32'h00a00093;
inst_mem[1]=32'h00000013;
inst_mem[2]=32'h00000013;
inst_mem[3]=32'h00000013;
inst_mem[4]=32'h01400113;
inst_mem[5]=32'h00000013;
inst_mem[6]=32'h00000013;
inst_mem[7]=32'h00000013;
inst_mem[8]=32'h002081b3;
inst_mem[9]=32'h00000013;
inst_mem[10]=32'h00000013;
inst_mem[11]=32'h00000013;
inst_mem[12]=32'h10000213;
inst_mem[13]=32'h00000013;
inst_mem[14]=32'h00000013;
inst_mem[15]=32'h00000013;
inst_mem[16]=32'h00322023;
inst_mem[17]=32'h00000013;
inst_mem[18]=32'h00000013;
inst_mem[19]=32'h00000013;
inst_mem[20]=32'h00022283;
inst_mem[21]=32'h00000013;
inst_mem[22]=32'h00000013;
inst_mem[23]=32'h00000013;
inst_mem[24]=32'h00109463;
inst_mem[25]=32'hf9fff06f;
inst_mem[26]=32'h06300313;
inst_mem[27]=32'h00100313;

    end
    
    always @(*) begin
    //assigning instrucion 4 bytes based on Inst-address(0,4,8,12)
    Instruction = inst_mem[Inst_address[31:2]];
    end
    
    
endmodule
