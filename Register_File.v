`timescale 1ns/1ps

module registerFile(
    input [63:0] writeData,
    input [4:0] RS1,
    input [4:0] RS2,
    input [4:0] RD,
    input  RegWrite,
    input clk,
    input reset,
    output reg [63:0]ReadData1,
    output reg [63:0]ReadData2
);
reg [63:0] registers [31:0];//32 registers of 64 bits

genvar i;
//intializin with random values
generate 
    for(i=0;i<32;i=i+1)begin: gen_block
        initial registers[i] = i+1;//initailaizes, i guess?
    end
endgenerate

//loop for positive edge of clock
always @(posedge clk) begin 
    if(RegWrite && (RD != 5'd0))begin 
         registers[RD] <= writeData;  
    end
end
//have to do it either ways, be it inside or outside clock

always@(*) begin
if (reset) begin
    ReadData1 = 64'd0;   //0 if reset is high
    ReadData2 = 64'd0;
end else begin
    ReadData1 = (RS1 == 5'd0) ? 64'd0 : registers[RS1];   //storing the register values if reset is 0
    ReadData2 = (RS2 == 5'd0) ? 64'd0 : registers[RS2];
end
end
endmodule
