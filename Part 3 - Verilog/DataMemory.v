/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module DataMemory(
clk,
memStore,
memLoad,
address,
input_value,
output_value
);

input clk;							// clock
input memStore;						// memStore signal, if it's 1, store operation will be done
input memLoad;						// memLoad signal, if it's 1, load operation will be done
input [11:0] address;				// address port of RAM
input [15:0] input_value;			// if memStore is 1, this value will be stored in the given address
output wire [15:0] output_value;	// if memLoad is 1, this value will come from given address

// size is 4096 by 12 bit address size, 2^12
reg [15:0] mem [0:4095];

assign output_value = (memLoad) ? mem[address] : 16'h0000;

// If rising edge, store value in the given address
always @ (posedge clk)
begin
	if(memStore) begin
		mem[address] = input_value;
	end
end
// initialize RAM with a hex file
initial begin
	$readmemh("datamem.hex", mem);
end
endmodule