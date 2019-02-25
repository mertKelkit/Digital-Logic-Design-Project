/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module InstructionMemory(
address,
data
);
// Instruction Memory (ROM) with one input, one output
// outputs data stored in given address
input wire [11:0] address;
output wire [15:0] data;

// size is 4096 by 12 bit address size, 2^12
reg [15:0] mem [0:4095];

assign data = mem[address];

// initialize ROM with a hex file
initial begin
	$readmemh("instructionmem.hex", mem);
end
endmodule
