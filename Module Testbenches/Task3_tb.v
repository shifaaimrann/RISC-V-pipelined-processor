`timescale 1ns / 1ps

module riscv_demo_tb;

    reg clk;
    reg reset;

    wire stall_pipeline;
    wire flush_pipeline;
    wire flush_execute;
    wire [1:0] forwarda, forwardb;
    wire pcsrc;

    wire [63:0] if_pc_out;
    wire [31:0] if_instruction;

    wire [4:0] rs1, rs2;
    wire [4:0] ex_rd;
    wire ex_memread;

    wire [63:0] ex_alu_inputa, ex_alu_inputb;
    wire [63:0] ex_alu_result;

    wire mem_regwrite, wb_regwrite;
    wire [4:0] mem_rd, wb_rd;

    wire [63:0] wb_final_write_data;

    wire [31:0] array_element_0;
    wire [31:0] array_element_1;
    wire [31:0] array_element_2;
    wire [31:0] array_element_3;
    wire [31:0] array_element_4;
    wire [31:0] array_element_5;
    wire [31:0] array_element_6;


    PipelinedRISCV uut (
        .clk(clk),
        .reset(reset)
    );

    assign stall_pipeline      = uut.stall_pipeline;
    assign flush_pipeline      = uut.flush_pipeline;
    assign flush_execute       = uut.flush_execute;
    assign forwarda            = uut.forwarda;
    assign forwardb            = uut.forwardb;
    assign pcsrc               = uut.pcsrc;
    assign if_pc_out           = uut.if_pc_out;
    assign if_instruction      = uut.if_instruction;
    assign rs1                 = uut.rs1;
    assign rs2                 = uut.rs2;
    assign ex_rd               = uut.ex_rd;
    assign ex_memread          = uut.ex_memread;
    assign ex_alu_inputa       = uut.ex_alu_inputa;
    assign ex_alu_inputb       = uut.ex_alu_inputb;
    assign ex_alu_result       = uut.ex_alu_result;
    assign mem_regwrite        = uut.mem_regwrite;
    assign wb_regwrite         = uut.wb_regwrite;
    assign mem_rd              = uut.mem_rd;
    assign wb_rd               = uut.wb_rd;
    assign wb_final_write_data = uut.wb_final_write_data;

    // Data Memory Array Elements (Addresses 256, 260, 264, 268, 272, 276, 280)
    // Note: This assumes Little-Endian storage in the Data_Memory module
    assign array_element_0 = {uut.dmem.data_memory[256+3], uut.dmem.data_memory[256+2], uut.dmem.data_memory[256+1], uut.dmem.data_memory[256]};
    assign array_element_1 = {uut.dmem.data_memory[260+3], uut.dmem.data_memory[260+2], uut.dmem.data_memory[260+1], uut.dmem.data_memory[260]};
    assign array_element_2 = {uut.dmem.data_memory[264+3], uut.dmem.data_memory[264+2], uut.dmem.data_memory[264+1], uut.dmem.data_memory[264]};
    assign array_element_3 = {uut.dmem.data_memory[268+3], uut.dmem.data_memory[268+2], uut.dmem.data_memory[268+1], uut.dmem.data_memory[268]};
    assign array_element_4 = {uut.dmem.data_memory[272+3], uut.dmem.data_memory[272+2], uut.dmem.data_memory[272+1], uut.dmem.data_memory[272]};
    assign array_element_5 = {uut.dmem.data_memory[276+3], uut.dmem.data_memory[276+2], uut.dmem.data_memory[276+1], uut.dmem.data_memory[276]};
    assign array_element_6 = {uut.dmem.data_memory[280+3], uut.dmem.data_memory[280+2], uut.dmem.data_memory[280+1], uut.dmem.data_memory[280]};


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #20; 
        reset = 0; 
        
        #20000;
        
        $stop;
    end

endmodule
