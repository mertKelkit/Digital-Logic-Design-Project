/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module ControlUnit(
// inputs
clk,
inst,
operand_1,
operand_2,
reset_flags,
// outputs
zf,
cf,
PCRead,
InstRead,
ALUcontrol,
JUMPSignal,
JUMPAddress,
MemLoad,
MemStore,
LD_ST_Addr,
IMMSignal,
IMM,
CompareSignal,
SRC_1,
SRC_2,
OP_1,
OP_2,
DEST,
WriteReg
);

input clk;							// clock
input wire [15:0] inst;				// current instruction
input [15:0] operand_1;		// 16 bit data for CMP instruction
input [15:0] operand_2;		// 16 bit data for CMP instruction
input reset_flags;					// clear pin for flags' registers

// operand_1 > operand_2: zf = 0, cf = 0; operand_1 = operand_2: zf = 1, cf = 0; operand_1 < operand_2: zf = 0, cf = 1.
output reg zf; 
output reg cf;


output wire PCRead;					// PCRead signal
output wire InstRead;				// Instruction read signal
output wire ALUcontrol;				// ALU operation selection signal
output wire JUMPSignal;				// JUMPSignal for determining jump operation will be done or not
output wire [11:0] JUMPAddress;		// PC relative jump address
output wire MemLoad;				// Memory load signal
output wire MemStore;				// Memory store signal
output wire [11:0] LD_ST_Addr;		// Load or Store address, it will go to address input of the RAM
output wire IMMSignal;				// if instruction uses immediate values, this signal will be 1
output wire [15:0] IMM;				// immediate value coming from ADDI or ANDI instructions
output wire CompareSignal;			// this will be enable pin of flag registers, if there is a compare operation, this signal will be 1
output wire [3:0] SRC_1;			// source register
output wire [3:0] SRC_2;			// source register
output wire [3:0] OP_1;				// source register for CMP
output wire [3:0] OP_2;				// source register for CMP
output wire [3:0] DEST;				// destination register
output wire WriteReg;				// enable signal of register file, permission for writing to destination register

// opcode and instruction signals
wire [3:0] opcode;
wire AND, ADD,
	LD, ST,
	ANDI, ADDI,
	CMP, JUMP,
	JE, JA, 
	JB, JBE, 
	JAE;

// result of comparison
wire above, equal, below;

// initial flag values are x (?)
initial zf = 1'bx;
initial cf = 1'bx;

// getting opcode and set signals according to opcode
assign opcode = inst[15:12];
	
assign AND = (opcode == 4'b0001) ? 1'b1 : 1'b0;
assign ADD = (opcode == 4'b0010) ? 1'b1 : 1'b0;
assign LD = (opcode == 4'b0011) ? 1'b1 : 1'b0;
assign ST = (opcode == 4'b0100) ? 1'b1 : 1'b0;
assign ANDI = (opcode == 4'b0101) ? 1'b1 : 1'b0;
assign ADDI = (opcode == 4'b0111) ? 1'b1 : 1'b0;
assign CMP = (opcode == 4'b1000) ? 1'b1 : 1'b0;
assign JUMP = (opcode == 4'b1001) ? 1'b1 : 1'b0;
assign JE = (opcode == 4'b1010) ? 1'b1 : 1'b0;
assign JA = (opcode == 4'b1011) ? 1'b1 : 1'b0;
assign JB = (opcode == 4'b1100) ? 1'b1 : 1'b0;
assign JBE = (opcode == 4'b1101) ? 1'b1 : 1'b0;
assign JAE = (opcode == 4'b1110) ? 1'b1 : 1'b0;

// ensure that PCRead and InstRead signal won't be equal at the same time
assign PCRead = clk;
assign InstRead = ~clk;

// parse the remaining instructions
assign LD_ST_Addr = {4'b0000, inst[7:0]};
assign JUMPAddress = inst[11:0];
assign DEST = inst[11:8];
assign SRC_1 = (MemStore) ? DEST : inst[7:4];
assign OP_1 = inst[7:4];
assign SRC_2 = inst[3:0];
assign OP_2 = inst[3:0];
assign IMM = {{12{inst[3]}}, inst[3:0]};
assign ALUcontrol = inst[13];

// set signals -explained above- according to current instruction
assign MemLoad = (LD) ? 1'b1 : 1'b0;
assign MemStore = (ST) ? 1'b1 : 1'b0;
assign IMMSignal = (ANDI || ADDI) ? 1'b1 : 1'b0;
assign WriteReg = (ANDI || ADDI || AND || ADD || LD) ? 1'b1 : 1'b0;
assign CompareSignal = (CMP) ? 1'b1 : 1'b0;
assign JUMPSignal = (JUMP || (JE && zf && !cf) || (JA && !zf && !cf) || (JB && !zf && cf) || (JAE && !cf) || (JBE && (zf || cf)))
																			? 1'b1 : 1'b0;
// set comparison results																			
assign above = (operand_1 > operand_2) ? 1'b1 : 1'b0;
assign equal = (operand_1 == operand_2) ? 1'b1 : 1'b0;
assign below = (operand_1 < operand_2) ? 1'b1 : 1'b0;

// flag registers are trigerred on fall edge
always @ (negedge clk)
begin
	if(CompareSignal) begin
		zf = (equal) ? 1'b1 : 1'b0;
		cf = ((~above) & (~equal)) ? 1'b1 : 1'b0;
	end
end
// if flags need to be reseted
always @ (reset_flags)
begin
	if(reset_flags) begin
		zf = 1'bx;
		cf = 1'bx;
	end
end
endmodule