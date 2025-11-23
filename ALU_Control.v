`timescale 1ns/1ps

module ALU_Control(
    input [1:0] ALUOp,
    input [3:0] Funct,
    output reg [3:0] Operation
    
    );
always @(*) begin 
    if(ALUOp==2'b00)begin //I type
        Operation=4'b0010;
    end
    else if (ALUOp==2'b01) begin //SB Type
        Operation=4'b0110;
    end
    else if (ALUOp==2'b10) begin //R type
        case(Funct)
            4'b0000: begin Operation=4'b0010;end
            4'b1000: begin Operation=4'b0110; end
            4'b0111: begin Operation=4'b0000;end // <-- FIX: Was 4'b0010 (ADD), now 4'b0000 (AND)
            4'b0110: begin Operation=4'b0001; end 
            4'b0001: begin Operation = 4'b0011;end        
            default: Operation = 4'bxxxx;
        endcase
    end
    else begin
        Operation = 4'bxxxx;
    end
end
endmodule
