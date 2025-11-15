`timescale 1ns / 1ps

module riscv_tb();
reg clk;
reg reset;
RISCV r1(clk,reset);

initial begin 
clk=1'b0; reset=1'b0;
#10 reset=1'b1;
#10 reset=1'b0;
end
always
#10 clk=~clk;
endmodule
