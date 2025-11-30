`timescale 1ns/1ps

module PipelinedRISCV(
    input clk,
    input reset
);

    // =========================================================================
    // 1. WIRE DECLARATIONS (Organized by Stage)
    // =========================================================================

    // --- IF Stage Wires (Instruction Fetch) ---
    wire [63:0] IF_PC_Out;       // Current PC
    wire [63:0] IF_PC_In;        // Next PC (Input to PC Register)
    wire [63:0] IF_PC_Plus_4;    // PC + 4
    wire [31:0] IF_Instruction;  // Instruction from Memory
    wire PCSrc;                  // Branch decision flag (from MEM stage)

    // --- IF/ID Register Outputs ---
    wire [31:0] ID_Instruction;  // Instruction passed to Decode
    wire [63:0] ID_PC;           // PC passed to Decode

    // --- ID Stage Wires (Instruction Decode) ---
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [63:0] ID_ReadData1, ID_ReadData2; // Values read from RegFile
    wire [63:0] ID_Imm;                     // Extended Immediate
    
    // Control Unit Signals (Generated in ID)
    wire [1:0] ID_ALUOp;
    wire ID_Branch, ID_MemRead, ID_MemtoReg, ID_MemWrite, ID_ALUSrc, ID_RegWrite;

    // --- ID/EX Register Outputs ---
    // These carry the Control Signals and Data into the Execution Stage
    wire [63:0] EX_PC, EX_ReadData1, EX_ReadData2, EX_Imm;
    wire [4:0]  EX_Rs1, EX_Rs2, EX_Rd;
    wire [3:0]  EX_Funct; // Combined funct7[5] and funct3
    
    wire EX_Branch, EX_MemRead, EX_MemtoReg, EX_MemWrite, EX_ALUSrc, EX_RegWrite;
    wire [1:0] EX_ALUOp;

    // --- EX Stage Wires (Execution) ---
    wire [63:0] EX_ALU_InputB;     // Second input to ALU (Reg vs Imm)
    wire [63:0] EX_ALU_Result;     // Result of ALU calculation
    wire [63:0] EX_Branch_Target;  // Calculated Address for Branching
    wire [3:0]  EX_Operation;      // ALU Control Signal
    wire EX_Zero, EX_Blt;          // Flags from ALU (Zero and Less Than)

    // --- EX/MEM Register Outputs ---
    // These latch the results from EX to be used in Memory Stage
    wire [63:0] MEM_Branch_Target, MEM_ALU_Result, MEM_WriteData;
    wire [4:0]  MEM_Rd;
    wire MEM_Zero; // Note: Your EX_MEM reg only carries Zero, not Blt (Blt support needed for sorting usually)
    
    wire MEM_Branch, MEM_MemRead, MEM_MemtoReg, MEM_MemWrite, MEM_RegWrite;

    // --- MEM Stage Wires (Memory Access) ---
    wire [63:0] MEM_ReadData;      // Data read from Data Memory
    
    // --- MEM/WB Register Outputs ---
    // These carry final data to the Write Back Stage
    wire [63:0] WB_ReadData, WB_ALU_Result;
    wire [4:0]  WB_Rd;
    wire WB_MemtoReg, WB_RegWrite;

    // --- WB Stage Wires (Write Back) ---
    wire [63:0] WB_Final_WriteData; // The data actually written back to Register File


    // =========================================================================
    // STAGE 1: INSTRUCTION FETCH (IF)
    // =========================================================================
    // Goal: Fetch 32-bit instruction from memory and increment PC.

    // 1. PC Mux: Selects next PC. 
    // If PCSrc is 1 (Branch taken), jump to Branch Target. Else, PC+4.
    // Note: Your 'mux' module definition is mux(S, A, B). If S=0 -> A, If S=1 -> B.
    mux mux_PC(PCSrc, IF_PC_Plus_4, MEM_Branch_Target, IF_PC_In);
    
    // 2. Program Counter: Updates on clock edge.
    Program_Counter pc_inst(IF_PC_In, clk, reset, IF_PC_Out);
    
    // 3. Adder: Calculates PC + 4.
    Adder pc_adder(IF_PC_Out, 64'd4, IF_PC_Plus_4);
    
    // 4. Instruction Memory: Fetches instruction using current PC.
    Instruction_memory imem_inst(IF_PC_Out, IF_Instruction);


    // =========================================================================
    // PIPELINE REGISTER: IF -> ID
    // =========================================================================
    IF_ID if_id_reg(
        .clk(clk), 
        .reset(reset),
        .Instruction(IF_Instruction), 
        .PC_Out(IF_PC_Out),
        .IFID_Instruction(ID_Instruction), 
        .IFID_PCout(ID_PC)
    );


    // =========================================================================
    // STAGE 2: INSTRUCTION DECODE (ID)
    // =========================================================================
    // Goal: Read Registers and Generate Control Signals.
    
    // 1. Instruction Parser: Splits 32-bit instruction into opcode, rd, rs1, etc.
    insparser parser(ID_Instruction, opcode, rd, funct3, rs1, rs2, funct7);

    // 2. Control Unit: Generates signals based on Opcode.
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

    // 3. Register File: Reads data from rs1 and rs2. 
    // Note: 'writeData' comes all the way from the WB stage (WB_Final_WriteData).
    registerFile reg_file(
        .writeData(WB_Final_WriteData), 
        .RS1(rs1), 
        .RS2(rs2), 
        .RD(WB_Rd), 
        .RegWrite(WB_RegWrite), // Control signal from WB stage
        .clk(clk), 
        .reset(reset),
        .ReadData1(ID_ReadData1), 
        .ReadData2(ID_ReadData2)
    );

    // 4. Immediate Generator: Sign-extends 12-bit offsets to 64-bit.
    immediate imm_gen(ID_Instruction, ID_Imm);


    // =========================================================================
    // PIPELINE REGISTER: ID -> EX
    // =========================================================================
    ID_EX id_ex_reg(
        .clk(clk), 
        .reset(reset),
        
        // --- Control Inputs from ID ---
        .Branch(ID_Branch), .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), 
        .MemtoReg(ID_MemtoReg), .RegWrite(ID_RegWrite), .ALUSrc(ID_ALUSrc), .ALUOp(ID_ALUOp),
        
        // --- Data Inputs from ID ---
        // Note: We combine funct7[5] and funct3 to make a 4-bit ALU control code.
        .Funct({ID_Instruction[30], ID_Instruction[14:12]}), 
        .Rs1(rs1), .Rs2(rs2), .Rd(rd),
        .IFID_PCout(ID_PC), .ReadData1(ID_ReadData1), .ReadData2(ID_ReadData2), .Imm(ID_Imm),

        // --- Outputs to EX ---
        .IDEX_Branch(EX_Branch), .IDEX_MemRead(EX_MemRead), .IDEX_MemWrite(EX_MemWrite),
        .IDEX_MemtoReg(EX_MemtoReg), .IDEX_RegWrite(EX_RegWrite), .IDEX_ALUSrc(EX_ALUSrc), .IDEX_ALUOp(EX_ALUOp),
        .IDEX_Funct(EX_Funct), .IDEX_Rs1(EX_Rs1), .IDEX_Rs2(EX_Rs2), .IDEX_Rd(EX_Rd),
        .IDEX_PCout(EX_PC), .IDEX_ReadData1(EX_ReadData1), .IDEX_ReadData2(EX_ReadData2), .IDEX_Imm(EX_Imm)
    );


    // =========================================================================
    // STAGE 3: EXECUTION (EX)
    // =========================================================================
    // Goal: Perform ALU calculations and compute Branch Target.

    // 1. Branch Address Adder: PC + Immediate.
    // Your 'immediate' module already handles the shift left 1 for branches.
    Adder branch_adder(EX_PC, EX_Imm, EX_Branch_Target);

    // 2. ALU Control: Decides operation (Add, Sub, And, etc.) based on ALUOp + Funct.
    ALU_Control alu_ctrl(EX_ALUOp, EX_Funct, EX_Operation);

    // 3. ALU Source Mux: Selects between Register Data (ReadData2) and Immediate.
    // If ALUSrc = 0 -> Reg, If ALUSrc = 1 -> Imm.
    mux alu_src_mux(EX_ALUSrc, EX_ReadData2, EX_Imm, EX_ALU_InputB);

    // 4. Main ALU: Performs the actual calculation.
    muxALU main_alu(
        .a(EX_ReadData1), 
        .b(EX_ALU_InputB), 
        .ALUop(EX_Operation), 
        .Zero(EX_Zero), 
        .blt(EX_Blt), 
        .result(EX_ALU_Result)
    );


    // =========================================================================
    // PIPELINE REGISTER: EX -> MEM
    // =========================================================================
    EX_MEM ex_mem_reg(
        .clk(clk), 
        .reset(reset),

        // --- Control Inputs from EX ---
        .IDEX_Branch(EX_Branch), .IDEX_MemRead(EX_MemRead), .IDEX_MemWrite(EX_MemWrite),
        .IDEX_MemtoReg(EX_MemtoReg), .IDEX_RegWrite(EX_RegWrite),

        // --- Data Inputs from EX ---
        .IDEX_PCBranch(EX_Branch_Target), .ZeroFlag_EX(EX_Zero), 
        .ALUResult_EX(EX_ALU_Result), .WriteData_EX(EX_ReadData2), .IDEX_Rd(EX_Rd),

        // --- Outputs to MEM ---
        .EXMEM_Branch(MEM_Branch), .EXMEM_MemRead(MEM_MemRead), .EXMEM_MemWrite(MEM_MemWrite),
        .EXMEM_MemtoReg(MEM_MemtoReg), .EXMEM_RegWrite(MEM_RegWrite),
        .EXMEM_PCBranch(MEM_Branch_Target), .EXMEM_ZeroFlag(MEM_Zero), 
        .EXMEM_ALUResult(MEM_ALU_Result), .EXMEM_WriteData(MEM_WriteData), .EXMEM_Rd(MEM_Rd)
    );


    // =========================================================================
    // STAGE 4: MEMORY (MEM)
    // =========================================================================
    // Goal: Access Data Memory and Decide on Branching.

    // 1. Branch Logic: AND Gate.
    // If (Branch Instruction is Active) AND (Zero Flag is True), then Branch.
    // Note: This logic works for BEQ. For your sorting, you might need BLT.
    // Since your EX_MEM register doesn't carry 'blt', this only supports BEQ for now.
    assign PCSrc = MEM_Branch & MEM_Zero; 

    // 2. Data Memory: Read or Write data.
    Data_Memory dmem(
        .Mem_Addr(MEM_ALU_Result), 
        .Write_Data(MEM_WriteData), 
        .clk(clk), 
        .MemWrite(MEM_MemWrite), 
        .MemRead(MEM_MemRead), 
        .Read_Data(MEM_ReadData)
    );


    // =========================================================================
    // PIPELINE REGISTER: MEM -> WB
    // =========================================================================
    MEM_WB mem_wb_reg(
        .clk(clk), 
        .reset(reset),

        // --- Control Inputs from MEM ---
        .EXMEM_MemtoReg(MEM_MemtoReg), .EXMEM_RegWrite(MEM_RegWrite),

        // --- Data Inputs from MEM ---
        .ReadData_MEM(MEM_ReadData), .ALUResult_MEM(MEM_ALU_Result), .EXMEM_Rd(MEM_Rd),

        // --- Outputs to WB ---
        .MEMWB_MemtoReg(WB_MemtoReg), .MEMWB_RegWrite(WB_RegWrite),
        .MEMWB_ReadData(WB_ReadData), .MEMWB_ALUResult(WB_ALU_Result), .MEMWB_Rd(WB_Rd)
    );


    // =========================================================================
    // STAGE 5: WRITE BACK (WB)
    // =========================================================================
    // Goal: Select result and write back to Register File.

    // 1. Write Back Mux:
    // If MemtoReg = 1 -> Select Memory Data (Load instruction).
    // If MemtoReg = 0 -> Select ALU Result (Add/Sub/etc).
    // Note: Your mux(S, A, B) logic is S=0->A, S=1->B.
    // If MemToReg is 1, we want Memory. So B should be Memory.
    // Wiring: A=ALU, B=Memory.
    mux wb_mux(WB_MemtoReg, WB_ALU_Result, WB_ReadData, WB_Final_WriteData);

endmodule