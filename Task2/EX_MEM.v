`timescale 1ns / 1ps

module EX_MEM(
    input clk,
    input reset,

    // Control signals from EX stage (from ID/EX)
    input IDEX_Branch, 
    input IDEX_MemRead, 
    input IDEX_MemWrite, 
    input IDEX_MemtoReg, 
    input IDEX_RegWrite, 

    // Datapath signals from EX stage
    input [63:0] IDEX_PCBranch,
    input        ZeroFlag_EX,
    
    input        bltflag_EX,   // Passing BLT flag from ALU, because currently branching takes plae 
    input [3:0]  funct_EX,     // Pass Funct code to know if it's BEQ or BLT

    input [63:0] ALUResult_EX,
    input [63:0] WriteData_EX,
    input [4:0]  IDEX_Rd,

    // Latched control signals to MEM stage
    output reg EXMEM_Branch,
    output reg EXMEM_MemRead,
    output reg EXMEM_MemWrite,
    output reg EXMEM_MemtoReg,
    output reg EXMEM_RegWrite,

    // Latched datapath signals to MEM stage
    output reg [63:0] EXMEM_PCBranch,
    output reg        EXMEM_ZeroFlag,
    
    // --- NEW OUTPUTS ---
    output reg        EXMEM_bltflag, // Output BLT flag to MEM stage
    output reg [3:0]  EXMEM_funct,   // Output Funct to MEM stage
    // -------------------

    output reg [63:0] EXMEM_ALUResult,
    output reg [63:0] EXMEM_WriteData,
    output reg [4:0]  EXMEM_Rd
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        EXMEM_Branch      <= 1'b0;
        EXMEM_MemRead     <= 1'b0;
        EXMEM_MemWrite    <= 1'b0;
        EXMEM_MemtoReg    <= 1'b0;
        EXMEM_RegWrite    <= 1'b0;

        EXMEM_PCBranch    <= 64'd0;
        EXMEM_ZeroFlag    <= 1'b0;
        
        // Clear new signals
        EXMEM_bltflag     <= 1'b0;
        EXMEM_funct       <= 4'b0000;
        
        EXMEM_ALUResult   <= 64'd0;
        EXMEM_WriteData   <= 64'd0;
        EXMEM_Rd          <= 5'd0;
    end
    else begin
        EXMEM_Branch      <= IDEX_Branch;
        EXMEM_MemRead     <= IDEX_MemRead;
        EXMEM_MemWrite    <= IDEX_MemWrite;
        EXMEM_MemtoReg    <= IDEX_MemtoReg;
        EXMEM_RegWrite    <= IDEX_RegWrite;

        EXMEM_PCBranch    <= IDEX_PCBranch;
        EXMEM_ZeroFlag    <= ZeroFlag_EX;
        
        // Pass new signals
        EXMEM_bltflag     <= bltflag_EX;
        EXMEM_funct       <= funct_EX;
        
        EXMEM_ALUResult   <= ALUResult_EX;
        EXMEM_WriteData   <= WriteData_EX;
        EXMEM_Rd          <= IDEX_Rd;
    end
end


endmodule
