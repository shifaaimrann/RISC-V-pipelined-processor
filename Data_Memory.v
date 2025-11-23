`timescale 1ns/1ps
module Data_Memory(
    input [63:0] Mem_Addr,
    input[63:0] Write_Data,
    input clk,
    input MemWrite,
    input MemRead,
    output reg [63:0] Read_Data
);
reg [7:0] data_memory [511:0]; //changing thsi to accomadate for 512 bytes
//data memory is 128 memory locations, each of 1 byte, whihc is 8 bits
//assigning random values
genvar i;
generate
    for(i=0;i<512;i=i+1) begin:gen_block
        initial data_memory[i]=i+1;
    end
endgenerate
//if MemRead=1, we will read data
always @(*) begin
if(MemRead==1'b1)begin 
    //reading data from each byte, amking up 64 bits
    Read_Data={data_memory[Mem_Addr+7],data_memory[Mem_Addr+6],data_memory[Mem_Addr+5],data_memory[Mem_Addr+4]
    ,data_memory[Mem_Addr+3],data_memory[Mem_Addr+2],data_memory[Mem_Addr+1],data_memory[Mem_Addr]};
end
else begin
    Read_Data = 64'dx;
end
end

always @(posedge clk) begin
    if(MemWrite)begin
        //writing data 8 bits at a time for 8 bytes
        data_memory[Mem_Addr] = Write_Data[7:0];
        data_memory[Mem_Addr+1] = Write_Data[15:8];
        data_memory[Mem_Addr+2] = Write_Data[23:16];
        data_memory[Mem_Addr+3] = Write_Data[31:24];
        data_memory[Mem_Addr+4] = Write_Data[39:32];
        data_memory[Mem_Addr+5] = Write_Data[47:40];
        data_memory[Mem_Addr+6] = Write_Data[55:48];
        data_memory[Mem_Addr+7] = Write_Data[63:56];
     end
end
endmodule
