/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module CPU(
clk,
reset_pc_reg,
reset_inst_reg,
reset_reg_file,
reset_flags,
zf,
cf,
adder_carry_out,
instruction
);

// Clock
input wire clk;
// Reset inputs for saved values (registers and flags)
input wire reset_pc_reg;
input wire reset_inst_reg;
input wire reset_reg_file;
input wire reset_flags;

// Flag values
output zf;
output cf;
// Carry out value coming from ALU-adder-
output adder_carry_out;
// Only for test purposes, does nothing in cpu module
output reg [15:0] instruction;


wire [11:0] PCAddress;			// current PC value
wire [11:0] JUMPAddress;		// JUMPAddress came from control unit, input for PCAddressRegister
wire PCRead;					// signal for setting new PC
wire InstRead;					// Instruction executing signal
wire JUMPSig;					// JUMP signal, if it's 1, JUMP operation will be done

wire WriteReg;					// enable pin of registers in the register file
wire MemLoad;					// load signal for RAM
wire MemStore;					// store signal for RAM
wire IMMSignal;					// signal for immediate value (ADDI, ANDI), if it's 1, immediate value will be input of ALU instead of SRC2 register output
wire ALUcontrol;				// to select ALU operation
wire [11:0] LD_ST_Addr;			// load-store address for RAM
wire [15:0] IMM;				// immediate value
wire CompareSignal;				// If there is a compare operation, this value will be 1
wire [3:0] SRC_1;				// source register
wire [3:0] SRC_2;				// source register
wire [3:0] OP_1;				// source register for CMP
wire [3:0] OP_2;				// source register for CMP
wire [3:0] DEST;				// destination register

wire [15:0] operand_1;			// 16 bit operand for compare operation
wire [15:0] operand_2;			// 16 bit operand for compare operation

wire [15:0] ALUresult;			// result coming from ALU
wire [15:0] DataMemVal;			// result coming from RAM

wire [15:0] instructionBuffer;	// wire for buffering next instruction

wire [15:0] reg_file_input;		// input data for DEST register
// If instruction is LD, value coming from RAM will be input of register file, else result of ALU will be stored in the register
assign reg_file_input = (MemLoad) ? DataMemVal : ALUresult;

// SRC1/SRC2/OP1/OP2
wire [3:0] read_reg_1;
wire [3:0] read_reg_2;
// Values stored in SRC1/SRC2/OP1/OP2
wire [15:0] reg_1_data;
wire [15:0] reg_2_data;
// outputs of register file will be stored in these wires if instruction is NOT CMP
wire [15:0] src_1_data;
wire [15:0] src_2_data;

// choose between SRCx or OPx (x=1,2)
assign read_reg_1 = (CompareSignal) ? OP_1 : SRC_1;
assign read_reg_2 = (CompareSignal) ? OP_2 : SRC_2;
// if there is a compare operation, outputs of register file will stored in operand_x (x=1,2)
assign operand_1 = (CompareSignal) ? reg_1_data : 16'h0000;
assign operand_2 = (CompareSignal) ? reg_2_data : 16'h0000;
// if there is no compare operation, outputs of register file will be stored in src_x_data (x=1,2) (Used for ALU or RAM)
assign src_1_data = (CompareSignal) ? 16'h0000: reg_1_data;
assign src_2_data = (CompareSignal) ? 16'h0000: reg_2_data;

// This is for selecting second input for ALU, immediate value or value stored in SRC2 register
wire [15:0] ALU_B_inp;
assign ALU_B_inp = (IMMSignal) ? IMM : src_2_data;

// If instruction register needs to be reseted
always @ (reset_inst_reg)
begin
	if(reset_inst_reg) begin
		instruction = 16'h0000;
	end
end
// Instruction register is trigerred on rising edge, gets next instruction from buffer
always @ (posedge clk)
begin
	instruction = instructionBuffer;
end

PCAddressRegister pc_addr_reg (
.clk(clk),
.enable(PCRead),
.clear(reset_pc_reg),
.ADDRSelect(JUMPSig),
.JUMPAddress(JUMPAddress),
.PCAddress(PCAddress)
);

InstructionMemory inst_mem (
.address(PCAddress),
.data(instructionBuffer)
);

ControlUnit control_unit (
.clk(clk),
.inst(instruction),
.operand_1(operand_1),
.operand_2(operand_2),
.reset_flags(reset_flags),
.zf(zf),
.cf(cf),
.PCRead(PCRead),
.InstRead(InstRead),
.ALUcontrol(ALUcontrol),
.JUMPSignal(JUMPSig),
.JUMPAddress(JUMPAddress),
.MemLoad(MemLoad),
.MemStore(MemStore),
.LD_ST_Addr(LD_ST_Addr),
.IMMSignal(IMMSignal),
.IMM(IMM),
.CompareSignal(CompareSignal),
.SRC_1(SRC_1),
.SRC_2(SRC_2),
.OP_1(OP_1),
.OP_2(OP_2),
.DEST(DEST),
.WriteReg(WriteReg)
);

RegisterFile register_file (
.clk(clk),
.clear(reset_reg_file),
.reg_write(WriteReg),
.input_data(reg_file_input),
.write_reg_no(DEST),
.read_reg_1(read_reg_1),
.read_reg_2(read_reg_2),
.reg_1_data(reg_1_data),
.reg_2_data(reg_2_data)
);

ALU alu (
.A(src_1_data),
.B(ALU_B_inp),
.operation(ALUcontrol),
.carry_out(adder_carry_out),
.result(ALUresult)
);

DataMemory data_memory (
.clk(clk),
.memStore(MemStore),
.memLoad(MemLoad),
.address(LD_ST_Addr),
.input_value(src_1_data),
.output_value(DataMemVal)
);

endmodule