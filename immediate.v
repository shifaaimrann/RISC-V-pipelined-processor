`timescale 1ns/1ps

module immediate(
input [31:0]instruction,//input instruction
output reg signed [63:0]immediate//output 64 bit SIGNED
);
reg signed [11:0] data;

always@* begin

if (instruction[6]== 1'b0) begin//checking the 6th bit op code
    if(instruction[5]== 1'b0)begin//load, I type function, if 5th bit of opcode is 0 (or I-type-imm)
        data={instruction[31:20]};end //for immediate, instruction[31:20] is the immediate
    else begin // This is S-type (010xx11) or R-type (011xx11)
        if (instruction[4] == 1'b0) begin // This checks for S-type (0100011)
            data={instruction[31:25],instruction[11:7]};end//stype instruction[12:5|4:0]
        else begin // This must be R-type (0110011)
            data = 12'dx; // R-type has no immediate
        end
    end 
end
else if(instruction[6]== 1'b1)begin//conditional instruction if opcode 6th bit is 1
    data={instruction[31],instruction[7], instruction[30:25], instruction[11:8]};end//SB type instruction


    immediate = {{52{data[11]}}, data[11:0]};///
end


endmodule
