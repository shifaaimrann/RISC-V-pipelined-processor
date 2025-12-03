`timescale 1ns/1ps

module PipelinedRISCV(
    input clk,
    input reset
);
    //hazard and forwatrding control signals--------------------------------------------------------------------
    // control signals for hazard unit
    wire stall_pipeline, flush_pipeline, flush_execute;
    
    // forwarding control signals from forwarding unit
    wire [1:0] forwarda, forwardb;
    
    // control signals and register fields from mem and wb stages for forwarding/hazard checking
    wire [4:0] mem_rd, wb_rd;
    wire mem_regwrite, wb_regwrite;
    wire mem_memtoreg; 
    wire wb_memtoreg;
    
    // signals from ex stage for hazard checking
    wire ex_memread; 
    wire [4:0] ex_rd; 

//wires separated stage wise----------------------------------------------
    // IF/ID Wires
    wire [63:0] if_pc_out, if_pc_in, if_pc_plus_4;
    wire [31:0] if_instruction;

    // ID Wires
    wire [31:0] id_instruction;
    wire [63:0] id_pc, id_read_data1, id_read_data2, id_imm;
    wire [4:0] rs1, rs2; // instruction rs1 and rs2 fields for hazard unit
    wire [1:0] id_aluop;
    wire id_branch, id_memread, id_memwrite, id_alusrc, id_regwrite, id_memtoreg;

    // EX Wires
    wire [63:0] ex_pc, ex_read_data1, ex_read_data2, ex_imm;
    wire [4:0] ex_rs1, ex_rs2;
    wire [63:0] ex_alu_inputa, ex_alu_inputb;
    wire [63:0] ex_alu_result, ex_branch_target;
    wire ex_zero, ex_blt;
    wire [3:0] ex_funct, ex_operation;
    wire pcsrc; // controlled by ex stage for branch prediction outcome
    wire [1:0] ex_aluop; 
    wire ex_branch, ex_memwrite, ex_memtoreg, ex_regwrite, ex_alusrc;

    // MEM Wires
    wire [63:0] mem_alu_result, mem_write_data, mem_read_data;
    wire mem_memread, mem_memwrite;
    wire [31:0] mem_read_data_32bit;
    wire [63:0] mem_branch_target; // kept for struct integrity, but not used for pc mux anymore

    // WB Wires
    wire [63:0] wb_read_data, wb_alu_result, wb_final_write_data;

    
    // determines if a data hazard (load-use) or control hazard (branch) requires
    // stalling or flushing
    hazard_unit hazard_inst (
        .idex_memread(ex_memread), // load instruction in ex stage
        .idex_rd(ex_rd),           // destination register of instruction in ex stage
        .ifid_rs1(rs1),            // source register 1 of instruction in id stage
        .ifid_rs2(rs2),            // source register 2 of instruction in id stage
        .pcsrc(pcsrc),             // branch taken signal from ex stage
        .stall(stall_pipeline),    // output: stall the if and id stages
        .flush_pipeline(flush_pipeline), // output: flush the if/id pipeline register (for taken branches)
        .flush_execute(flush_execute) // output: flush the id/ex pipeline register (for load-use stall or taken branches)
    );

    //IF satge-------------------------------------------
    wire [63:0] next_pc_logic;
    
    // pc mux: select next pc based on whether a branch is taken (pcsrc)
    // pcsrc is calculated in the ex stage to select the branch target
    mux mux_NextPC(pcsrc, if_pc_plus_4, ex_branch_target, next_pc_logic);
    assign if_pc_in = next_pc_logic;

    // program counter (pc) register
    Program_Counter pc_inst(
        .PC_In(if_pc_in), .clk(clk), .reset(reset), .stall(stall_pipeline), 
        .PC_Out(if_pc_out)
    );
    
    // pc + 4 calculation
    Adder pc_adder(if_pc_out, 64'd4, if_pc_plus_4);
    
    // instruction memory access
    Instruction_memory imem_inst(if_pc_out, if_instruction);

    // --- IF/ID REG ---
    // pipeline register between instruction fetch and instruction decode
    IF_ID if_id_reg(
        .clk(clk), .reset(reset), 
        .stall(stall_pipeline), // stall signal prevents writing new data on data hazard
        .flush(flush_pipeline), // flush signal resets register contents on taken branch
        .Instruction(if_instruction), .PC_Out(if_pc_out),
        .IFID_Instruction(id_instruction), .IFID_PCout(id_pc)
    );

    //ID Stage
    wire [6:0] opcode, funct7;
    wire [4:0] rd; wire [2:0] funct3;
    
    // instruction field decoding
    insparser parser(id_instruction, opcode, rd, funct3, rs1, rs2, funct7);
    
    // control unit generates all necessary control signals
    Control_Unit ctrl_unit(
        .Opcode(opcode), .ALUOP(id_aluop), .Branch(id_branch), .MemRead(id_memread), 
        .MemtoReg(id_memtoreg), .MemWrite(id_memwrite), .ALUSrc(id_alusrc), .RegWrite(id_regwrite)
    );
    
    // register file read ports
    registerFile reg_file(
        .writeData(wb_final_write_data), .RS1(rs1), .RS2(rs2), .RD(wb_rd), 
        .RegWrite(wb_regwrite), .clk(clk), .reset(reset),
        .ReadData1(id_read_data1), .ReadData2(id_read_data2)
    );
    
    // immediate value generation
    immediate imm_gen(id_instruction, id_imm);

    // --- ID/EX REG ---
    // pipeline register between instruction decode and execute
    ID_EX id_ex_reg(
        .clk(clk), .reset(reset), 
        .flush(flush_execute), // flush on load-use hazard stall (becomes nop) or taken branch
        .Branch(id_branch), .MemRead(id_memread), .MemWrite(id_memwrite), 
        .MemtoReg(id_memtoreg), .RegWrite(id_regwrite), .ALUSrc(id_alusrc), .ALUOp(id_aluop),
        .Funct({id_instruction[30], id_instruction[14:12]}), // funct field: instruction bit 30 and funct3
        .Rs1(rs1), .Rs2(rs2), .Rd(rd),
        .IFID_PCout(id_pc), .ReadData1(id_read_data1), .ReadData2(id_read_data2), .Imm(id_imm),
        // outputs to EX stage
        .IDEX_Branch(ex_branch), .IDEX_MemRead(ex_memread), .IDEX_MemWrite(ex_memwrite),
        .IDEX_MemtoReg(ex_memtoreg), .IDEX_RegWrite(ex_regwrite), .IDEX_ALUSrc(ex_alusrc), .IDEX_ALUOp(ex_aluop),
        .IDEX_Funct(ex_funct), .IDEX_Rs1(ex_rs1), .IDEX_Rs2(ex_rs2), .IDEX_Rd(ex_rd),
        .IDEX_PCout(ex_pc), .IDEX_ReadData1(ex_read_data1), .IDEX_ReadData2(ex_read_data2), .IDEX_Imm(ex_imm)
    );

   //EX Stage-----------------------
    
    // determines forwarding paths to resolve data hazards (bypassing)
    forwarding_unit fwd_unit (
        .idex_rs1(ex_rs1), .idex_rs2(ex_rs2), // source registers in ex stage
        
        .exmem_rd(mem_rd), // destination register of instruction in mem stage
        .exmem_regwrite(mem_regwrite), // regwrite signal of instruction in mem stage
        .exmem_memtoreg(mem_memtoreg),
        
        .memwb_rd(wb_rd), // destination register of instruction in wb stage
        .memwb_regwrite(wb_regwrite), // regwrite signal of instruction in wb stage
        
        .forward_a(forwarda), .forward_b(forwardb) // output: forwarding control signals
    );

    wire [63:0] ex_read_data2_forwarded;

    // mux for alu input a: select from id_read_data1, mem_alu_result (mem->ex bypass), or wb_final_write_data (wb->ex bypass)
    mux3x1 mux_alu_A(.sel(forwarda), .in0(ex_read_data1), .in1(wb_final_write_data), .in2(mem_alu_result), .out(ex_alu_inputa));
    
    // mux for alu input b (data part): select from id_read_data2, mem_alu_result, or wb_final_write_data (bypass logic)
    mux3x1 mux_alu_B_temp(.sel(forwardb), .in0(ex_read_data2), .in1(wb_final_write_data), .in2(mem_alu_result), .out(ex_read_data2_forwarded));
    
    // alu src mux: select alu input b from immediate (for i-type) or forwarded read data (for r-type)
    mux mux_alu_src(ex_alusrc, ex_read_data2_forwarded, ex_imm, ex_alu_inputb);

    // branch target address calculation
    Adder branch_adder(ex_pc, ex_imm, ex_branch_target); 
    
    // alu control determines the specific alu operation
    ALU_Control alu_ctrl(ex_aluop, ex_funct, ex_operation);
    
    // main alu execution
    muxALU main_alu(.a(ex_alu_inputa), .b(ex_alu_inputb), .ALUop(ex_operation), .Zero(ex_zero), .blt(ex_blt), .result(ex_alu_result));

    // --- BRANCH LOGIC (Calculated in EX) ---
    // determine if branch should be taken
    // funct3[2] is 0 for beq (uses zero flag), 1 for blt (uses blt flag)
    assign pcsrc = ex_branch & ( 
        (~ex_funct[2] & ex_zero) | // beq: check zero flag
        ( ex_funct[2] & ex_blt )   // blt: check blt flag
    );

    // --- EX/MEM REG ---
    // pipeline register between execute and memory
    EX_MEM ex_mem_reg(
        .clk(clk), .reset(reset),
        // we disconnect branch/zero/blt from this register as pcsrc is now calculated in ex
        .IDEX_Branch(1'b0), // unused in mem now
        .IDEX_MemRead(ex_memread), .IDEX_MemWrite(ex_memwrite),
        .IDEX_MemtoReg(ex_memtoreg), .IDEX_RegWrite(ex_regwrite),
        .IDEX_PCBranch(ex_branch_target), .ZeroFlag_EX(ex_zero), .BltFlag_EX(ex_blt),
        .ALUResult_EX(ex_alu_result), .WriteData_EX(ex_read_data2_forwarded), // forwarded data to be written to memory
        .IDEX_Rd(ex_rd),
        
        // outputs to MEM stage
        .EXMEM_Branch(), // disconnected
        .EXMEM_MemRead(mem_memread), .EXMEM_MemWrite(mem_memwrite),
        .EXMEM_MemtoReg(mem_memtoreg), .EXMEM_RegWrite(mem_regwrite),
        .EXMEM_PCBranch(mem_branch_target), 
        .EXMEM_ZeroFlag(), .EXMEM_BltFlag(),
        .EXMEM_ALUResult(mem_alu_result), .EXMEM_WriteData(mem_write_data), .EXMEM_Rd(mem_rd)
    );

    
    // data memory access
    Data_Memory dmem(
        .Mem_Addr(mem_alu_result), .Write_Data(mem_write_data[31:0]), // riscv is 64-bit, but dmem seems 32-bit
        .clk(clk), .MemWrite(mem_memwrite), .MemRead(mem_memread), .Read_Data(mem_read_data_32bit)
    );
    
    // sign extension of 32-bit read data to 64-bit for riscv
    assign mem_read_data = {{32{mem_read_data_32bit[31]}}, mem_read_data_32bit};

    // --- MEM/WB REG ---
    // pipeline register between memory and writeback
    MEM_WB mem_wb_reg(
        .clk(clk), .reset(reset),
        .EXMEM_MemtoReg(mem_memtoreg), .EXMEM_RegWrite(mem_regwrite),
        .ReadData_MEM(mem_read_data), .ALUResult_MEM(mem_alu_result), .EXMEM_Rd(mem_rd),
        // outputs to WB stage
        .MEMWB_MemtoReg(wb_memtoreg), .MEMWB_RegWrite(wb_regwrite),
        .MEMWB_ReadData(wb_read_data), .MEMWB_ALUResult(wb_alu_result), .MEMWB_Rd(wb_rd)
    );

   //wb stage------------------------------------------------------------------------------------------------------
    // writeback data mux: select data to write back to register file (from alu or data memory)
    mux wb_mux(wb_memtoreg, wb_alu_result, wb_read_data, wb_final_write_data);

endmodule

