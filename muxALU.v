`timescale 1ns/1ps

module muxALU(
    input [63:0] a,//64 bit input
    input [63:0] b,//64 bit input
    input[3:0] ALUop,//selector
    output reg Zero,//zero to check whether result is zero or not
    output reg blt,
    output reg [63:0] result//64 bit output
    );

always@* begin
if (ALUop==4'b0000)//selector bit is 0000nso AND
    begin 
        result=a&b;
    end 
else if (ALUop==4'b0110)//selector bit is 0110 so we will subtract
    begin 
    result = a-b;//since its behavioral we wont do a-b-carryin
    end
else if (ALUop==4'b0001)//seelctor bit is 0001, so OR
    begin
        result=a|b;
    end 
else if (ALUop==4'b0010)//0010 selector bit: add
    begin
        result=a+b;//addition
    end 
else if (ALUop==4'b1100)//1100 is NOR
    begin
        result = ~(a|b); 
    end 
else if (ALUop==4'b0011)
    begin
        result = a << b;
    end
else begin
    result = 64'dx; 
end
 Zero=(result==64'b0);//assigning Zero based on if result is equal to 64 bits of zeroes
 blt = ($signed(a) < $signed(b));
end
endmodule
