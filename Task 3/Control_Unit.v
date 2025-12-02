`timescale 1ns/1ps

module Control_Unit(
    input [6:0] Opcode,
    output reg [1:0] ALUOP,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

    always @(*) begin
        case(Opcode)
            7'b0110011: begin // R-Format (add, sub, etc.)
                Branch = 0; MemRead = 0; MemtoReg = 0; ALUOP = 2'b10;
                MemWrite = 0; ALUSrc = 0; RegWrite = 1;
            end
            
            7'b0000011: begin // I-Format (ld - Load Double)
                Branch = 0; 
                MemRead = 1; // <--- CRITICAL FIX
                MemtoReg = 1; 
                ALUOP = 2'b00;
                MemWrite = 0; ALUSrc = 1; RegWrite = 1;
            end
            
            7'b0010011: begin // I-Type (addi, slli)
                Branch = 0; MemRead = 0; MemtoReg = 0; ALUOP = 2'b00;
                MemWrite = 0; ALUSrc = 1; RegWrite = 1;
            end
            
            7'b0100011: begin // S-Type (sd - Store Double)
                Branch = 0; MemRead = 0; MemtoReg = 1'bx; ALUOP = 2'b00;
                MemWrite = 1; ALUSrc = 1; RegWrite = 0;
            end
            
            7'b1100011: begin // SB-Type (beq, blt)
                Branch = 1; MemRead = 0; MemtoReg = 1'bx; ALUOP = 2'b01;
                MemWrite = 0; ALUSrc = 0; RegWrite = 0;
            end
            
            default: begin 
                Branch = 0; MemRead = 0; MemtoReg = 0; ALUOP = 2'b00;
                MemWrite = 0; ALUSrc = 0; RegWrite = 0;
            end
        endcase
    end
endmodule