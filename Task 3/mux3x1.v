`timescale 1ns/1ps

module mux3x1(
    input [1:0] sel,
    input [63:0] in0, // 00: Original (Register File)
    input [63:0] in1, // 01: Forward from WB
    input [63:0] in2, // 10: Forward from MEM
    output reg [63:0] out
);
    always @(*) begin
        case(sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            default: out = in0;
        endcase
    end
endmodule