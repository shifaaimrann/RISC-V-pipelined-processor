`timescale 1ns/1ps

module tb_PipelinedRISCV;

    reg clk;
    reg reset;

    PipelinedRISCV uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #1;
        

        #10;
        reset = 0;

        

        #600;
        
    end

endmodule
