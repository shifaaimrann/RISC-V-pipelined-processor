`timescale 1ns/1ps

module mux (
input  S, //selector bits
input [63:0] A, //input bits
input [63:0] B,
output [63:0] data_out);//output bits
//condition using ternary operator
assign data_out = (S == 1'b0) ? A : B ;
endmodule

