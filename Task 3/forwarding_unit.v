`timescale 1ns/1ps

module forwarding_unit (
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] exmem_rd,
    input  exmem_regwrite,
    input  exmem_memtoreg, 
    input  [4:0] memwb_rd,
    input  memwb_regwrite,
    output reg [1:0] forward_a, 
    output reg [1:0] forward_b
);
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        
        //forward a-rs1
        if (exmem_regwrite && (exmem_rd != 5'd0) && (exmem_rd == idex_rs1) && !exmem_memtoreg) begin
            forward_a = 2'b10;  // Forward ALU result (EX/MEM output)
        end
        else if (memwb_regwrite && (memwb_rd != 5'd0) && (memwb_rd == idex_rs1)) begin
            forward_a = 2'b01;  // Forward result from WB stage (MEM/WB output)
        end
        
        //forward b
        if (exmem_regwrite && (exmem_rd != 5'd0) && (exmem_rd == idex_rs2) && !exmem_memtoreg) begin
            forward_b = 2'b10;
        end
        else if (memwb_regwrite && (memwb_rd != 5'd0) && (memwb_rd == idex_rs2)) begin
            forward_b = 2'b01;
        end
    end
endmodule