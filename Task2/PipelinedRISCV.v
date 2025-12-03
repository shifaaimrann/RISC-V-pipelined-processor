`timescale 1ns/1ps

module PipelinedRISCV(
    input clk,
    input reset
);

    // wire declarations
    
    // instruction fetch wires
    wire [63:0] IF_PC_Out;       // current pc
    wire [63:0] IF_PC_In;        // next pc
    wire [63:0] IF_PC_Plus_4;    // pc + 4
    wire [31:0] IF_Instruction;  // instruction fetched from memory
    wire PCSrc;                  // flag for branch decision

    // if/id register outputs
    wire [31:0] ID_Instruction;
    wire [63:0] ID_PC;

    // decode stage wires
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [63:0] ID_ReadData1, ID_ReadData2;
    wire [63:0] ID_Imm;
    
    // control unit signals
    wire [1:0] ID_ALUOp;
    wire ID_Branch, ID_MemRead, ID_MemtoReg, ID_MemWrite, ID_ALUSrc, ID_RegWrite;

    // id/ex register outputs
    wire [63:0] EX_PC, EX_ReadData1, EX_ReadData2, EX_Imm;
    wire [4:0]  EX_Rs1, EX_Rs2, EX_Rd;
    wire [3:0]  EX_Funct;
    
    wire EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_ALUSrc, EX_RegWrite;
    wire [1:0] EX_ALUOp;

    // execution stage wires (forwarding & alu)
    wire [63:0] EX_ALU_InputB;       // final input b for alu (after immediate mux)
    wire [63:0] EX_ALU_Result;       // alu result
    wire [63:0] EX_Branch_Target;    // branch target address
    wire [3:0]  EX_Operation;        // alu control signal
    wire EX_Zero, EX_Blt;            // alu flags
    
    // forwarding wires
    wire [1:0] ForwardA, ForwardB;
    wire [63:0] ALU_Input_A_Forwarded; // output from mux a
    wire [63:0] ALU_Input_B_Forwarded; // output from mux b

    // ex/mem register outputs
    wire [63:0] MEM_Branch_Target, MEM_ALU_Result, MEM_WriteData;
    wire [4:0]  MEM_Rd;
    wire MEM_Zero;
    wire MEM_Blt;        
    wire [3:0] MEM_Funct;
    
    wire MEM_Branch, MEM_MemRead, MEM_MemtoReg, MEM_MemWrite, MEM_RegWrite;

    // memory stage wires
    wire [63:0] MEM_ReadData;
    wire [31:0] MEM_ReadData_32; 
    
    // mem/wb register outputs
    wire [63:0] WB_ReadData, WB_ALU_Result;
    wire [4:0]  WB_Rd;
    wire WB_MemtoReg, WB_RegWrite;

    // write back stage wires
    wire [63:0] WB_Final_WriteData;


    // stage 1: instruction fetch
    
    // pc mux: decides next pc (either pc+4 or branch target)
    mux mux_PC(PCSrc, IF_PC_Plus_4, MEM_Branch_Target, IF_PC_In);

    // program counter
    Program_Counter pc_inst(IF_PC_In, clk, reset, IF_PC_Out);

    // adder for pc + 4
    Adder pc_adder(IF_PC_Out, 64'd4, IF_PC_Plus_4);

    // instruction memory
    Instruction_memory imem_inst(IF_PC_Out, IF_Instruction);


    // pipeline register: if -> id
    IF_ID if_id_reg(
        .clk(clk), 
        .reset(reset),
        .Instruction(IF_Instruction), 
        .PC_Out(IF_PC_Out),
        .IFID_Instruction(ID_Instruction), 
        .IFID_PCout(ID_PC)
    );


    // stage 2: instruction decode

    // instruction parser
    insparser parser(ID_Instruction, opcode, rd, funct3, rs1, rs2, funct7);

    // control unit
    Control_Unit ctrl_unit(
        .Opcode(opcode), 
        .ALUOp(ID_ALUOp), 
        .Branch(ID_Branch), 
        .MemRead(ID_MemRead), 
        .MemtoReg(ID_MemtoReg), 
        .MemWrite(ID_MemWrite), 
        .ALUSrc(ID_ALUSrc), 
        .RegWrite(ID_RegWrite)
    );

    // register file
    registerFile reg_file(
        .writeData(WB_Final_WriteData), 
        .RS1(rs1), 
        .RS2(rs2), 
        .RD(WB_Rd), 
        .RegWrite(WB_RegWrite), 
        .clk(clk), 
        .reset(reset),
        .ReadData1(ID_ReadData1), 
        .ReadData2(ID_ReadData2)
    );

    // immediate generator
    immediate imm_gen(ID_Instruction, ID_Imm);


    // pipeline register: id -> ex
    ID_EX id_ex_reg(
        .clk(clk), 
        .reset(reset),
        
        // control signals
        .Branch(ID_Branch), .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), 
        .MemtoReg(ID_MemtoReg), .RegWrite(ID_RegWrite), .ALUSrc(ID_ALUSrc), .ALUOp(ID_ALUOp),
        
        // instruction fields & data
        .Funct({ID_Instruction[30], ID_Instruction[14:12]}), 
        .Rs1(rs1), .Rs2(rs2), .Rd(rd),
        .IFID_PCout(ID_PC), .ReadData1(ID_ReadData1), .ReadData2(ID_ReadData2), .Imm(ID_Imm),

        // outputs to ex
        .IDEX_Branch(EX_Branch), .IDEX_MemRead(EX_MemRead), .IDEX_MemWrite(EX_MemWrite),
        .IDEX_MemtoReg(EX_MemtoReg), .IDEX_RegWrite(EX_RegWrite), .IDEX_ALUSrc(EX_ALUSrc), .IDEX_ALUOp(EX_ALUOp),
        .IDEX_Funct(EX_Funct), .IDEX_Rs1(EX_Rs1), .IDEX_Rs2(EX_Rs2), .IDEX_Rd(EX_Rd),
        .IDEX_PCout(EX_PC), .IDEX_ReadData1(EX_ReadData1), .IDEX_ReadData2(EX_ReadData2), .IDEX_Imm(EX_Imm)
    );


    // stage 3: execution

    // forwarding unit
    Forwarding_Unit fwd_unit(
        .EM_RegWrite(MEM_RegWrite), 
        .EM_RD(MEM_Rd), 
        .MW_RegWrite(WB_RegWrite), 
        .MW_RD(WB_Rd), 
        .IDEX_RS1(EX_Rs1), 
        .IDEX_RS2(EX_Rs2), 
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB)
    );

    // forwarding muxes (using mux3x1)
    
    // mux for alu input a
    // 00: original reg data, 01: forward from wb, 10: forward from mem
    mux3x1 mux_fwd_a (
        .sel(ForwardA),
        .in0(EX_ReadData1),
        .in1(WB_Final_WriteData),
        .in2(MEM_ALU_Result),
        .out(ALU_Input_A_Forwarded)
    );

    // mux for alu input b (before immediate mux)
    mux3x1 mux_fwd_b (
        .sel(ForwardB),
        .in0(EX_ReadData2),
        .in1(WB_Final_WriteData),
        .in2(MEM_ALU_Result),
        .out(ALU_Input_B_Forwarded)
    );

    // branch address adder
    Adder branch_adder(EX_PC, EX_Imm, EX_Branch_Target);

    // alu control
    ALU_Control alu_ctrl(EX_ALUOp, EX_Funct, EX_Operation);

    // alu source b mux (immediate vs forwarded register)
    mux alu_src_mux(EX_ALUSrc, ALU_Input_B_Forwarded, EX_Imm, EX_ALU_InputB);

    // main alu
    muxALU main_alu(
        .a(ALU_Input_A_Forwarded), 
        .b(EX_ALU_InputB), 
        .ALUop(EX_Operation), 
        .Zero(EX_Zero), 
        .blt(EX_Blt), 
        .result(EX_ALU_Result)
    );


    // pipeline register: ex -> mem
    EX_MEM ex_mem_reg(
        .clk(clk), 
        .reset(reset),

        // control
        .IDEX_Branch(EX_Branch), .IDEX_MemRead(EX_MemRead), .IDEX_MemWrite(EX_MemWrite),
        .IDEX_MemtoReg(EX_MemtoReg), .IDEX_RegWrite(EX_RegWrite),

        // data
        .IDEX_PCBranch(EX_Branch_Target), 
        .ZeroFlag_EX(EX_Zero), 
        .bltflag_EX(EX_Blt),       
        .funct_EX(EX_Funct),       
        
        .ALUResult_EX(EX_ALU_Result), 
        .WriteData_EX(ALU_Input_B_Forwarded), // passing forwarded data for store
        .IDEX_Rd(EX_Rd),

        // outputs
        .EXMEM_Branch(MEM_Branch), .EXMEM_MemRead(MEM_MemRead), .EXMEM_MemWrite(MEM_MemWrite),
        .EXMEM_MemtoReg(MEM_MemtoReg), .EXMEM_RegWrite(MEM_RegWrite),
        
        .EXMEM_PCBranch(MEM_Branch_Target), 
        .EXMEM_ZeroFlag(MEM_Zero), 
        .EXMEM_bltflag(MEM_Blt), 
        .EXMEM_funct(MEM_Funct),
        
        .EXMEM_ALUResult(MEM_ALU_Result), 
        .EXMEM_WriteData(MEM_WriteData), 
        .EXMEM_Rd(MEM_Rd)
    );


    // stage 4: memory

    // branch logic (supports beq, blt, bne, bge)
    wire branch_condition_met;
    assign branch_condition_met = 
            (MEM_Funct[2:0] == 3'b000) ? MEM_Zero :   // beq
            (MEM_Funct[2:0] == 3'b100) ? MEM_Blt :    // blt
            (MEM_Funct[2:0] == 3'b001) ? ~MEM_Zero :  // bne
            (MEM_Funct[2:0] == 3'b101) ? ~MEM_Blt :   // bge
            1'b0;

    assign PCSrc = MEM_Branch & branch_condition_met;

    // data memory
    Data_Memory dmem(
        .Mem_Addr(MEM_ALU_Result), 
        .Write_Data(MEM_WriteData[31:0]), 
        .clk(clk), 
        .MemWrite(MEM_MemWrite), 
        .MemRead(MEM_MemRead), 
        .Read_Data(MEM_ReadData_32)
    );

    assign MEM_ReadData = {{32{MEM_ReadData_32[31]}}, MEM_ReadData_32};


    // pipeline register: mem -> wb
    MEM_WB mem_wb_reg(
        .clk(clk), 
        .reset(reset),

        // control
        .EXMEM_MemtoReg(MEM_MemtoReg), .EXMEM_RegWrite(MEM_RegWrite),

        // data
        .ReadData_MEM(MEM_ReadData), .ALUResult_MEM(MEM_ALU_Result), .EXMEM_Rd(MEM_Rd),

        // outputs
        .MEMWB_MemtoReg(WB_MemtoReg), .MEMWB_RegWrite(WB_RegWrite),
        .MEMWB_ReadData(WB_ReadData), .MEMWB_ALUResult(WB_ALU_Result), .MEMWB_Rd(WB_Rd)
    );


    // stage 5: write back

    // mux to select between alu result and memory data
    mux wb_mux(WB_MemtoReg, WB_ALU_Result, WB_ReadData, WB_Final_WriteData);

endmodule
