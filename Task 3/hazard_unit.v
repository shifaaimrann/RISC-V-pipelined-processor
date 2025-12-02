`timescale 1ns/1ps
module hazard_unit(
    input idex_memread,
    input [4:0] idex_rd,
    input [4:0] ifid_rs1,
    input [4:0] ifid_rs2,
    input pcsrc, 
    output reg stall, 
    output reg flush_pipeline,
    output reg flush_execute 
);
    
    wire load_use_hazard;
    assign load_use_hazard = idex_memread && (idex_rd != 0) && 
                             ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2));

    always @(*) begin
        // Defaults
        stall = 0;
        flush_pipeline = 0;
        flush_execute = 0;
       
        if (load_use_hazard) begin
            stall = 1;          // Freeze PC and IF/ID
            flush_execute = 1;  
            flush_pipeline = 0;
        end
        else if (pcsrc == 1'b1) begin
            stall = 0;
            flush_pipeline = 1; // Flush IF/ID
            flush_execute = 1;  // Flush ID/EX
        end
    end
endmodule