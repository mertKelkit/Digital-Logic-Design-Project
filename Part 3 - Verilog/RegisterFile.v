/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module RegisterFile(
clk,
clear,
reg_write,
input_data,
write_reg_no,
read_reg_1,
read_reg_2,
reg_1_data,
reg_2_data
);

input clk;					// clock
input clear;				// clear pin for registers
input reg_write;			// enable pin for registers
input [15:0] input_data;	// if reg_write is 1, this data will be stored in the register write_reg_no
input [3:0] write_reg_no;	// destination register
input [3:0] read_reg_1;		// register number to output value stored in it (SRC1 or OP1)
input [3:0] read_reg_2;		// register number to output value stored in it (SRC2 or OP2)
output [15:0] reg_1_data;	// data stored inside read_reg_1
output [15:0] reg_2_data;	// data stored inside read_reg_2

integer i;
// 16 registers having 16 bits data size
reg [15:0] registers [0:15];

// initialize registers with 0
initial begin
	for(i=0; i<16; i=i+1)
	begin
	registers[i] = 16'h0;
	end
end
// registers are triggered on rising edge
always @ (posedge clk)
begin
	// if we are allowed to store data inside a register...
	if(reg_write) begin
		registers[write_reg_no] = input_data;
	end
end
// if registers need to be cleared
always @ (clear)
begin
	// reset all registers
	if(clear) begin
		for(i=0; i<16; i=i+1)
		begin
		registers[i] = 16'h0;
		end
	end
end

assign reg_1_data = registers[read_reg_1];
assign reg_2_data = registers[read_reg_2];

endmodule
