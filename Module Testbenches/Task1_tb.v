`timescale 1ns / 1ps

module riscv_tb();

   
    reg clk;
    reg reset;
    reg [31:0] cycle_count = 0; 

    
    RISCV r1(
        .clk(clk),
        .reset(reset)
    );
    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        #10 reset = 1'b0; 
    end

    
    always @(posedge clk) begin
        if (reset == 1'b0) begin 
            cycle_count <= cycle_count + 1;
        end
    end

    initial begin
        
        wait (r1.pc_out[31:0] == 32'h00000080); 

        @(posedge clk); 
        @(posedge clk); 
        
        $finish; 
    end

endmodule
