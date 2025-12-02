`timescale 1ns / 1ps

module ALU(
    input [63:0]A,
    input [63:0]B,
    input [3:0]ALUOP,
    output reg zero,
    output reg blt,
    output reg [63:0]result
    );

    always@* begin
        if (ALUOP==4'b0000)//selector bit is 0000nso AND
            begin 
                result=A&B;
            end 
        else if (ALUOP==4'b0110)//selector bit is 0110 so we will subtract
            begin 
            result = A-B;//since its behavioral we wont do a-b-carryin
            end
        else if (ALUOP==4'b0001)//seelctor bit is 0001, so OR
            begin
                result=A|B;
            end 
        else if (ALUOP==4'b0010)//0010 selector bit: add
            begin
                result=A+B;//addition
            end 
        else if (ALUOP==4'b1100)//1100 is NOR
            begin
                result = ~(A|B); 
            end 
        else if (ALUOP==4'b0011)
            begin
                result = A << B;
            end
        else begin
            result = 64'dx; 
        end
        //assigning zero flag
        if (result == 64'b0)
            begin
                zero = 1;        // result is zero 
            end
        else begin
            zero = 0;        // result is not zero
        end
        //assigning blt flag
        if ($signed(A) < $signed(B)) //signed becz without this -5<3 gives blt=0
            begin
            blt = 1;         // A is less than B
            end
        else begin
            blt = 0;         // A is not less than B
        end
    end
endmodule
