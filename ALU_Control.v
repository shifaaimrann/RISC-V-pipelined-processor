`timescale 1ns/1ps

module ALU_Control(
    input [1:0] ALUOP,
    input [3:0] Funct,
    output reg [3:0] Op
    );

    always @(*) begin
        Op = 4'bxxxx; //Default
    
        if (ALUOP==2'b00) //I-type 
            begin       
                Op=4'b0010; //ADD
            end
        else if (ALUOP == 2'b01) //SB-type 
            begin  
                Op = 4'b0110; //SUB
            end
        else if (ALUOP == 2'b10) //R-type
            begin  
                if (Funct == 4'b0000)
                    begin 
                        Op = 4'b0010; //ADD
                    end
            else if (Funct == 4'b1000)
                begin
                    Op = 4'b0110; //SUB
                end
            else if (Funct == 4'b0111)
                begin
                    Op = 4'b0000; //AND
                end
            else if (Funct == 4'b0110)
                begin
                    Op = 4'b0001; //OR
                end
            else if (Funct == 4'b0001)
                begin
                    Op = 4'b0011; //SLL
                end
            else begin
                Op = 4'bxxxx;
            end
        end
        else begin
            Op = 4'bxxxx;     
        end
    end
endmodule
