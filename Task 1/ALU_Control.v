`timescale 1ns/1ps

module ALU_Control(
    input [1:0] ALUOp,         // ALU operation type from Control Unit
    input [3:0] Funct,         // Compact 4-bit FUNCT: {funct7[5], funct3[2:0]}
    output reg [3:0] Operation // ALU control output
    );

    always @ (ALUOp or Funct)
    begin
        case(ALUOp)
            2'b00: // I-Type (ADDI, LD, SLLI)
            begin
                case(Funct[2:0])
                    3'b001: Operation = 4'b0011; // SLLI 
                    default: Operation = 4'b0010; // ADD (ADDI, LD, SD addr calc)
                endcase
            end

            2'b01: // branches
            begin
                case(Funct[2:0]) // funct3
                    3'b000: Operation = 4'b0110; // BEQ 
                    3'b001: Operation = 4'b0110; // BNE 
                    3'b100: Operation = 4'b0111; // BLT 
                    3'b101: Operation = 4'b0111; // BGE 
                    default: Operation = 4'b0110; // default to SUB
                endcase
            end

            2'b10: // R-Type (ADD, SUB, AND, OR, SLT)
            begin
                case(Funct)
                    4'b0000: Operation = 4'b0010; // ADD 
                    4'b1000: Operation = 4'b0110; // SUB 
                    4'b0111: Operation = 4'b0000; // AND 
                    4'b0110: Operation = 4'b0001; // OR
                    4'b0010: Operation = 4'b0111; // SLT (funct3=010, funct7=0)
                    
                    default: Operation = 4'bxxxx;
                endcase
            end

            default: Operation = 4'bxxxx;
        endcase
    end
endmodule
