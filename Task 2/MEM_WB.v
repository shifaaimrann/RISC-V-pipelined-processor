`timescale 1ns / 1ps

module MEM_WB(
    input clk,
    input reset,

    // Control signals from MEM stage (latched from EX/MEM)
    input EXMEM_MemtoReg,// 1: write data to register from memory (ReadData)
                         // 0: write data to register from ALUResult
    input EXMEM_RegWrite,// 1: enable register file write in WB stage
                         // 0: do not write to register file

    // Datapath signals from MEM stage
    input [63:0] ReadData_MEM,     // data read from data memory
    input [63:0] ALUResult_MEM,    // forwarded ALU result from EX stage
    input [4:0]  EXMEM_Rd,         // destination register

    output reg MEMWB_MemtoReg, // mux
    output reg MEMWB_RegWrite, // mux

    output reg [63:0] MEMWB_ReadData, // data from mem
    output reg [63:0] MEMWB_ALUResult, // alu result
    output reg [4:0]  MEMWB_Rd // destination of reg no
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Clear control so WB stage does nothing
        MEMWB_MemtoReg   <= 1'b0;
        MEMWB_RegWrite   <= 1'b0;

        // Clear datapath so no random data gets written 
        MEMWB_ReadData   <= 64'd0;
        MEMWB_ALUResult  <= 64'd0;
        MEMWB_Rd         <= 5'd0;
    end
    else begin
        // control from mem stage
        MEMWB_MemtoReg   <= EXMEM_MemtoReg;
        MEMWB_RegWrite   <= EXMEM_RegWrite;

        // datapath signals from mem stage
        MEMWB_ReadData   <= ReadData_MEM;
        MEMWB_ALUResult  <= ALUResult_MEM;
        MEMWB_Rd         <= EXMEM_Rd;
        // check if MemWb_toMemReg if 1 write to register file , if 0 then write MemWb_AlUresult to reg file 
    end
end

endmodule