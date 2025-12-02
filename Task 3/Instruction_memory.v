`timescale 1ns/1ps
module Instruction_memory(
    input [63:0] Inst_address,
    output reg [31:0] Instruction
    );
    reg [31:0] inst_mem [63:0];
    //instruction address is 0
    initial begin
inst_mem[0]=32'h10000513;
inst_mem[1]=32'h00500293;
inst_mem[2]=32'h00552023;
inst_mem[3]=32'h00200293;
inst_mem[4]=32'h00552223;
inst_mem[5]=32'h00900293;
inst_mem[6]=32'h00552423;
inst_mem[7]=32'h00100293;
inst_mem[8]=32'h00552623;
inst_mem[9]=32'h00700293;
inst_mem[10]=32'h00552823;
inst_mem[11]=32'h00400293;
inst_mem[12]=32'h00552a23;
inst_mem[13]=32'h00300293;
inst_mem[14]=32'h00552c23;
inst_mem[15]=32'h10000513;
inst_mem[16]=32'h00700593;
inst_mem[17]=32'h00000293;
inst_mem[18]=32'hfff58f93;
inst_mem[19]=32'h01f2ae33;
inst_mem[20]=32'h060e0663;
inst_mem[21]=32'h00028393;
inst_mem[22]=32'h00128313;
inst_mem[23]=32'h00b32e33;
inst_mem[24]=32'h020e0863;
inst_mem[25]=32'h00239e93;
inst_mem[26]=32'h01d50eb3;
inst_mem[27]=32'h000ea403;
inst_mem[28]=32'h00231f13;
inst_mem[29]=32'h01e50f33;
inst_mem[30]=32'h000f2483;
inst_mem[31]=32'h0084c463;
inst_mem[32]=32'h00000463;
inst_mem[33]=32'h00030393;
inst_mem[34]=32'h00130313;
inst_mem[35]=32'hfc0008e3;
inst_mem[36]=32'h02538263;
inst_mem[37]=32'h00229e13;
inst_mem[38]=32'h01c50e33;
inst_mem[39]=32'h00239e93;
inst_mem[40]=32'h01d50eb3;
inst_mem[41]=32'h000e2f03;
inst_mem[42]=32'h000eaf83;
inst_mem[43]=32'h01fe2023;
inst_mem[44]=32'h01eea023;
inst_mem[45]=32'h00128293;
inst_mem[46]=32'hf80008e3;

    end
    
    always @(*) begin
    //assigning instrucion 4 bytes based on Inst-address(0,4,8,12)
    Instruction = inst_mem[Inst_address[31:2]];
    end
    
    
endmodule
