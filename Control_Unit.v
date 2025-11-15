`timescale 1ns/1ps

module Control_Unit (
    input [6:0] opcode,
    output reg Branch,
    output reg MemRead,
    output reg MemToReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);
    always @(*) begin
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemToReg = 1'bx;
        ALUOp    = 2'bxx;
        MemWrite = 1'b0;
        ALUSrc   = 1'bx;
        RegWrite = 1'b0;

        case (opcode)
            7'b0110011: begin    // R-type
                ALUSrc   = 1'b0;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0000011: begin // I-type (load)
                ALUSrc   = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
                MemRead  = 1'b1;
            end
            7'b0100011: begin // S-type (store)
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
                MemWrite = 1'b1;
            end
            7'b1100011: begin // SB-type (branch)
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01;
                Branch   = 1'b1;
            end
            7'b0010011: begin // I-type (immediate)
                ALUSrc   = 1'b1;
                MemToReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            default: begin
                Branch   = 1'bx;
                MemRead  = 1'bx;
                MemToReg = 1'bx;
                ALUOp    = 2'bxx;
                MemWrite = 1'bx;
                ALUSrc   = 1'bx;
                RegWrite = 1'bx;
            end
        endcase
    end
endmodule
