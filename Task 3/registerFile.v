`timescale 1ns/1ps
module registerFile(
    input [63:0] writeData, input [4:0] RS1, input [4:0] RS2, input [4:0] RD,
    input RegWrite, input clk, input reset,
    output reg [63:0] ReadData1, output reg [63:0] ReadData2
);
    reg [63:0] registers [31:0];
    integer i;
    initial for(i=0; i<32; i=i+1) registers[i] = 0;

    always @(posedge clk) if(RegWrite && RD!=0) registers[RD] <= writeData;

    always @(*) begin
        if (reset) begin ReadData1=0; ReadData2=0; end
        else begin
            // FORWARDING FIX
            ReadData1 = (RS1==0) ? 0 : (RegWrite && RD==RS1) ? writeData : registers[RS1];
            ReadData2 = (RS2==0) ? 0 : (RegWrite && RD==RS2) ? writeData : registers[RS2];
        end
    end
endmodule