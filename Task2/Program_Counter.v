`timescale 1ns/1ps

module Program_Counter(
    input [63:0] PC_In,
    input clk,
    input reset,
    output reg [63:0] PC_Out
    );

    initial PC_Out = 64'd0;

    always @ (posedge clk or posedge reset) begin
        if (reset == 1'b1) 
            PC_Out <= 64'b0; 
        else 
            PC_Out <= PC_In; 
    end
endmodule