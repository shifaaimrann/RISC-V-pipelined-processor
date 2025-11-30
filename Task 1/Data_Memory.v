`timescale 1ns/1ps

module Data_Memory(
    input [63:0] Mem_Addr,      // memory address (byte-addressable)
    input [63:0] Write_Data,    // data to write
    input clk,                  // clock
    input MemWrite,             // memory write enable
    input MemRead,              // memory read enable
    output reg [63:0] Read_Data // data read from memory
);

    // 512 bytes of memory, 1 byte each
    reg [7:0] data_memory [511:0]; 

    // initializing memory with values for simulation
    genvar i;
    generate
        for(i=0; i<512; i=i+1) begin: gen_block
            initial data_memory[i] = i+1;
        end
    endgenerate

    // safe memory address (0-504) for 64-bit aligned access
    wire [8:0] addr = (Mem_Addr > 504) ? 9'd504 : Mem_Addr[8:0]; 

    // combinational read
    always @(*) begin
        if(MemRead) begin
            // reading 8 consecutive bytes to make 64-bit data
            Read_Data = {data_memory[addr+7], data_memory[addr+6], data_memory[addr+5], data_memory[addr+4],
                         data_memory[addr+3], data_memory[addr+2], data_memory[addr+1], data_memory[addr]};
        end else begin
            Read_Data = 64'dx; // undefined when not reading
        end
    end

    // sequential write
    always @(posedge clk) begin
    if(MemWrite) begin
        // Use <= for sequential writes
        data_memory[addr]   <= Write_Data[7:0];
        data_memory[addr+1] <= Write_Data[15:8];
        data_memory[addr+2] <= Write_Data[23:16];
        data_memory[addr+3] <= Write_Data[31:24];
        data_memory[addr+4] <= Write_Data[39:32];
        data_memory[addr+5] <= Write_Data[47:40];
        data_memory[addr+6] <= Write_Data[55:48];
        data_memory[addr+7] <= Write_Data[63:56];
    end
end

endmodule
