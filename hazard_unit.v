`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2025 06:21:10 PM
// Design Name: 
// Module Name: hazard_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard_unit(
// From ID/EX pipeline (instruction in EX stage)
    input       IDEX_MemRead,   // 1 if EX-stage instruction is a load
    input [4:0] IDEX_Rd,        // rd of load

    // From IF/ID pipeline (instruction in ID stage)
    input [4:0] IFID_Rs1,       // source register 1 of next instruction
    input [4:0] IFID_Rs2,       // source register 2 of next instruction

    // Outputs to control stalling and bubble insertion
    output reg  Stall,          // 1 when a load-use hazard is detected
    output reg  PCWrite,        // 0 to freeze PC
    output reg  IFIDWrite,      // 0 to freeze IF/ID
    output reg  ControlMuxSel   // 1 to send zeros into ID/EX control (bubble)
);

always @(*) begin
    // Default:normal operation
    Stall         = 1'b0;
    PCWrite       = 1'b1;   // allow PC to update
    IFIDWrite     = 1'b1;   // allow IF/ID to update
    ControlMuxSel = 1'b0;   // pass real control signals to ID/EX

    // If current EX-stage instruction is a load (MemRead = 1) and its destination register (IDEX_Rd) is the same as one of the source registers of the instruction in ID stage,
    // then the next instruction would use data before it is ready.
    if (IDEX_MemRead &&(IDEX_Rd != 5'd0) && ((IDEX_Rd == IFID_Rs1) || (IDEX_Rd == IFID_Rs2)))// ignore x0
     begin

        // Hazard detected → trigger stall
        Stall         = 1'b1;

        // Freeze PC and IF/ID (front of pipeline)
        PCWrite       = 1'b0;
        IFIDWrite     = 1'b0;

        // Insert bubble into ID/EX by zeroing its control signals
        ControlMuxSel = 1'b1;
    end
end

endmodule
