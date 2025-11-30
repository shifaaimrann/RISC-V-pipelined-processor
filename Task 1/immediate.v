
`timescale 1ns/1ps
module immediate(
input [31:0]instruction,//input instruction
output reg signed [63:0]immediate//output 64 bit SIGNED
);

always @(*) begin
    case(instruction[6:0])
        7'b0000011, 7'b0010011: // lw, addi, slli
            if (instruction[6:0] == 7'b0010011 && instruction[14:12] == 3'b001) begin
                // SLLI: zero-extend shamt (5 bits)
                immediate = {{59{1'b0}}, instruction[24:20]};
            end else begin
                // ADDI / LW: sign-extend inst[31:20]
                immediate = {{52{instruction[31]}}, instruction[31:20]};
            end

        7'b0100011: begin // sw
            immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end

        7'b1100011: begin // beq/blt
            immediate = {{51{instruction[31]}}, instruction[31], instruction[7],
                         instruction[30:25], instruction[11:8], 1'b0}; // already shifted by 1
        end

        default: immediate = 64'd0;
    endcase
end

endmodule

