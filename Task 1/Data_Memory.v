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

        //array initialization [5, 2, 9, 1, 7, 4, 3] at 0x100 (256)
            data_memory[256] = 8'h05; data_memory[257] = 8'h00; data_memory[258] = 8'h00; data_memory[259] = 8'h00;
            data_memory[260] = 8'h02; data_memory[261] = 8'h00; data_memory[262] = 8'h00; data_memory[263] = 8'h00;
            data_memory[264] = 8'h09; data_memory[265] = 8'h00; data_memory[266] = 8'h00; data_memory[267] = 8'h00;
            data_memory[268] = 8'h01; data_memory[269] = 8'h00; data_memory[270] = 8'h00; data_memory[271] = 8'h00;
            data_memory[272] = 8'h07; data_memory[273] = 8'h00; data_memory[274] = 8'h00; data_memory[275] = 8'h00;
            data_memory[276] = 8'h04; data_memory[277] = 8'h00; data_memory[278] = 8'h00; data_memory[279] = 8'h00;
            data_memory[280] = 8'h03; data_memory[281] = 8'h00; data_memory[282] = 8'h00; data_memory[283] = 8'h00;
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

