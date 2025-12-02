`timescale 1ns/1ps
module ALU_Control(
    input [1:0] ALUOp, input [3:0] Funct, output reg [3:0] Operation
    );
    always @ (*) begin
        case(ALUOp)
            2'b00: Operation = (Funct[2:0]==3'b001) ? 4'b0011 : 4'b0010;
            2'b01: Operation = (Funct[2]==1'b1) ? 4'b0111 : 4'b0110;
            2'b10: begin 
                case(Funct)
                    4'b0000: Operation = 4'b0010; // ADD
                    4'b1000: Operation = 4'b0110; // SUB
                    4'b0111: Operation = 4'b0000; // AND
                    4'b0110: Operation = 4'b0001; // OR
                    4'b0010: Operation = 4'b0111; // SLT
                    default: Operation = 4'bxxxx;
                endcase
            end
            default: Operation = 4'bxxxx;
        endcase
    end
endmodule