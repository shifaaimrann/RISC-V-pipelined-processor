`timescale 1ns / 1ps

module Forwarding_Unit(
    input EM_RegWrite, // EX/MEM stage writes
    input [4:0] EM_RD, // EX/MEM destination register
    input MW_RegWrite, // MEM/WB stage writes
    input [4:0] MW_RD, // MEM/WB destination register
    input [4:0] IDEX_RS1, // ID/EX source register 1
    input [4:0] IDEX_RS2, // ID/EX source register 2
    output reg [1:0]ForwardA, // Control for ALU operand 1
    output reg [1:0]ForwardB // Control for ALU operand 2
    );
    
    always @(*) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        // EX hazard: forward from EX stage if needed
        if (EM_RegWrite==1) 
            begin
                if (EM_RD == IDEX_RS1 && EM_RD != 0)
                    begin
                        ForwardA = 2'b10; 
                    end
                if (EM_RD == IDEX_RS2 && EM_RD != 0)
                    begin
                        ForwardB = 2'b10; 
                    end
            end
        
        // MEM Hazard  
        if (MW_RegWrite==1)
            begin
                if ((MW_RD != 0) && (EM_RegWrite == 0 && EM_RD == 0) && (EM_RD != IDEX_RS1) && (MW_RD == IDEX_RS1))
                begin
                    ForwardA = 2'b01;
                end
            if ((MW_RD != 0) && (EM_RegWrite == 0 && EM_RD == 0) && (EM_RD != IDEX_RS2) && (MW_RD == IDEX_RS2))
                begin
                    ForwardB = 2'b01;
                end
            end
        
        if (EM_RegWrite == 0 && MW_RegWrite == 0)
            begin 
                ForwardA = 2'b00;
                ForwardB = 2'b00;
            end   
    end
endmodule