`timescale 1ns/1ps

module Program_Counter(
input [63:0] PC_In,
input clk,
input reset,
output reg [63:0] PC_Out
);
always @(posedge clk)
begin
PC_Out=reset? 64'b0: PC_In;

end
endmodule
