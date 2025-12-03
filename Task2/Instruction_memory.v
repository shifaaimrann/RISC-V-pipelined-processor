`timescale 1ns/1ps
module Instruction_memory(
    input [63:0] Inst_address,
    output reg [31:0] Instruction
    );
    reg [31:0] inst_mem [127:0];
    //instruction address is 0
    initial begin
inst_mem[0]=32'h00a00093;
inst_mem[1]=32'h00500113;
inst_mem[2]=32'h00000013;
inst_mem[3]=32'h00000013;
inst_mem[4]=32'h00000013;
inst_mem[5]=32'h002081b3;
inst_mem[6]=32'h40208233;
inst_mem[7]=32'h00000013;
inst_mem[8]=32'h00000013;
inst_mem[9]=32'h00000013;
inst_mem[10]=32'h0041e2b3;
inst_mem[11]=32'h00302023;
inst_mem[12]=32'h00402223;
inst_mem[13]=32'h00002303;
inst_mem[14]=32'h00402383;
inst_mem[15]=32'h00000013;
inst_mem[16]=32'h00000013;
inst_mem[17]=32'h00000013;
inst_mem[18]=32'h00730433;

    end
    
    always @(*) begin
    //assigning instrucion 4 bytes based on Inst-address(0,4,8,12)
    Instruction = inst_mem[Inst_address[31:2]];
    end
    
    
endmodule
