`timescale 1ns / 1ps

module muxALU(
    input [63:0] a,        // 64 bit input
    input [63:0] b,        // 64 bit input
    input [3:0] ALUop,     // selector
    output reg Zero,       // zero flag
    output reg blt,        // less than flag
    output reg [63:0] result // 64 bit output
    );

always @* begin
    case (ALUop)
        4'b0000: result = a & b;                           // AND
        4'b0001: result = a | b;                           // OR
        4'b0010: result = a + b;                           // ADD
        4'b0110: result = a - b;                           // SUB
        4'b0111: result = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0; // SLT -> 1/0
        4'b1100: result = ~(a | b);                        // NOR
        4'b0011: result = {{32'd0, a[31:0]} << b[4:0]};    // SLL (Shift Left)
        default: result = 64'd0;
    endcase

    Zero = (result == 64'b0);
    blt  = ($signed(a) < $signed(b));
end

endmodule

