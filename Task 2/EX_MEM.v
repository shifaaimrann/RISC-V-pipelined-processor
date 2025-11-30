`timescale 1ns / 1ps


module EX_MEM(

    input clk,
    input reset,

    // Control signals from EX stage (from ID/EX)
    input IDEX_Branch, // branch instruction
    input IDEX_MemRead, // read data mem
    input IDEX_MemWrite, // write data mem
    input IDEX_MemtoReg, // WB data from mem not ALU
    input IDEX_RegWrite, // write to register file in WB 

    // Datapath signals from EX stage
    input [63:0] IDEX_PCBranch,    // PC + immediate (branch target)
    input        ZeroFlag_EX,      // zero flag from ALU ( for beq and bne)
    input [63:0] ALUResult_EX,     // ALU result (address or result)
    input [63:0] WriteData_EX,     // register value to be written in mem (from ReadData2)
    input [4:0]  IDEX_Rd,          // destination register address for WB stage

    // Latched control signals to MEM stage
    output reg EXMEM_Branch,
    output reg EXMEM_MemRead,
    output reg EXMEM_MemWrite,
    output reg EXMEM_MemtoReg,
    output reg EXMEM_RegWrite,

    // Latched datapath signals to MEM stage
    output reg [63:0] EXMEM_PCBranch,
    output reg        EXMEM_ZeroFlag,
    output reg [63:0] EXMEM_ALUResult,
    output reg [63:0] EXMEM_WriteData,
    output reg [4:0]  EXMEM_Rd
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Clear control signals
        // disabling all control signals so MEM stage does nothing
        EXMEM_Branch      <= 1'b0;
        EXMEM_MemRead     <= 1'b0;
        EXMEM_MemWrite    <= 1'b0;
        EXMEM_MemtoReg    <= 1'b0;
        EXMEM_RegWrite    <= 1'b0;

        // Clear datapath to avoid unintended mem actions
        EXMEM_PCBranch    <= 64'd0;
        EXMEM_ZeroFlag    <= 1'b0;
        EXMEM_ALUResult   <= 64'd0;
        EXMEM_WriteData   <= 64'd0;
        EXMEM_Rd          <= 5'd0;
    end
    else begin
        // signals to pass to MEM stage
        // only operate on +ve edge of clk
        EXMEM_Branch      <= IDEX_Branch;
        EXMEM_MemRead     <= IDEX_MemRead;
        EXMEM_MemWrite    <= IDEX_MemWrite;
        EXMEM_MemtoReg    <= IDEX_MemtoReg;
        EXMEM_RegWrite    <= IDEX_RegWrite;

        // Latch datapath signals
        EXMEM_PCBranch    <= IDEX_PCBranch; // potential next PC
        EXMEM_ZeroFlag    <= ZeroFlag_EX; // for branch decision
        EXMEM_ALUResult   <= ALUResult_EX; // ALU output
        EXMEM_WriteData   <= WriteData_EX; // data for storing
        EXMEM_Rd          <= IDEX_Rd; // destiantion reg
    end
end

endmodule