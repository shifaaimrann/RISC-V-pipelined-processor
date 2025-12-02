`timescale 1ns/1ps

module Data_Memory(
    input [63:0] Mem_Addr,      
    input [31:0] Write_Data,    
    input clk,
    input MemWrite,
    input MemRead,
    output reg [31:0] Read_Data 
);

    reg [7:0] data_memory [511:0];

    integer k;
    initial begin
        for(k=0; k<512; k=k+1)
            data_memory[k] = 8'h00;

       
    end

    
    wire [8:0] addr = (Mem_Addr[8:0] > 508) ? 9'd508 : Mem_Addr[8:0];

    always @(*) begin
        if(MemRead) begin
            Read_Data = {data_memory[addr+3], data_memory[addr+2], data_memory[addr+1], data_memory[addr]};
        end else begin
            Read_Data = 32'd0;
        end
    end

    always @(posedge clk) begin
        if(MemWrite) begin
            data_memory[addr]   <= Write_Data[7:0];
            data_memory[addr+1] <= Write_Data[15:8];
            data_memory[addr+2] <= Write_Data[23:16];
            data_memory[addr+3] <= Write_Data[31:24];
        end
    end

endmodule
