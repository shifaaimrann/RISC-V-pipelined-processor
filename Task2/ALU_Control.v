`timescale 1ns/1ps

module ALU_Control(
    input [1:0] ALUOp,         
    input [3:0] Funct,         
    output reg [3:0] Operation 
    );

    always @(*)
    begin
        case(ALUOp)
            2'b00: // I-Type (ADDI, LD, SLLI)
            begin
                case(Funct[2:0])
                    3'b001: Operation = 4'b0011; // SLLI -> SLL
                    default: Operation = 4'b0010; // ADD (ADDI, LD, SD addr calc)
                endcase
            end

            2'b01: // Branch types - using funct3 to select ALU behavior
            begin
                case(Funct[2:0]) // funct3
                    3'b000: Operation = 4'b0110; // BEQ -> SUB (check Zero)
                    3'b100: Operation = 4'b0111; // BLT -> SLT (set-less-than)
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
                    4'b0010: Operation = 4'b0111; ///SLT
                    
                    default: Operation = 4'bxxxx;
                endcase
            end

            default: Operation = 4'bxxxx;
        endcase
    end

endmodule
