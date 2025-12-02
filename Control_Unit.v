`timescale 1ns / 1ps


module Control_Unit(
    input [6:0] opcode,
    input stall,
    output reg Branch,
    output reg MemRead,
    output reg MemToReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
    );
    
    always @(*) begin
        // Default values
        Branch=1'b0;
        MemRead=1'b0;
        MemToReg=1'b0;
        ALUOp=2'b00;
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b0;
    
        // R-type: opcode = 0110011
        if (opcode==7'b0110011) 
            begin
                ALUSrc=1'b0;    // second ALU operand from register
                MemToReg=1'b0;    // result comes from ALU
                RegWrite=1'b1;    // write result to register
                ALUOp=2'b10; // ALU_Control will use funct field
            end
        // I-type load: opcode = 0000011
        else if (opcode == 7'b0000011) 
            begin
                ALUSrc   = 1'b1; // second ALU operand is immediate
                MemToReg = 1'b1; // result comes from memory
                RegWrite = 1'b1; // write to register
                MemRead  = 1'b1; // read from memory
                ALUOp    = 2'b00; // ALU will do ADD for address
            end
        // S-type store: opcode = 0100011
        else if (opcode == 7'b0100011) 
            begin
                ALUSrc   = 1'b1; // second ALU operand is immediate
                MemWrite = 1'b1; // enable memory write
                ALUOp    = 2'b00; // ALU will perform addition
            end
        // SB-type branch: opcode = 1100011
        else if (opcode == 7'b1100011) 
            begin
                ALUSrc   = 1'b0; // second ALU operand comes from register
                ALUOp    = 2'b01; // ALU will perform subtraction for comparison
                Branch   = 1'b1;  // enable branch
            end
        // I-type immediate ALU: opcode = 0010011
        else if (opcode == 7'b0010011) 
            begin
                ALUSrc   = 1'b1; // second ALU operand is immediate
                MemToReg = 1'b0; // write ALU result to register
                RegWrite = 1'b1; // enable register write
                ALUOp    = 2'b10; // ALU_Control will use funct field
            end
        // Default / unknown opcode
        else begin
            Branch   = 1'b0;
            MemRead  = 1'b0;
            MemToReg = 1'b0;
            ALUOp    = 2'b00;
            MemWrite = 1'b0;
            ALUSrc   = 1'b0;
            RegWrite = 1'b0;
        end
        
        if (stall == 1)
            begin
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemToReg = 1'b0;
                ALUOp    = 2'b00;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                RegWrite = 1'b0;
            end
    end
endmodule
