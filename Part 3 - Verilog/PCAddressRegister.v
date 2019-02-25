/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module PCAddressRegister(
clk,
enable,
clear,
ADDRSelect,
JUMPAddress,
PCAddress
);

input clk;						// clock
input enable;					// enable pin of PC register
input clear;					// clear pin of PC register
input ADDRSelect;				// Address selection signal for adding to the PC. If it's 1, JUMPAddress will be added, else 1 will be added to PC.
input [11:0] JUMPAddress;		// Jump address coming from control unit
output reg [11:0] PCAddress;	// new PC value

wire [11:0] nextAddress;		// wire for calculating new PC

initial begin
PCAddress = 12'h000;			// initial PC value is 0
end

parameter cons = 12'h001;		

// calculate next PC address
assign nextAddress = (ADDRSelect) ? PCAddress + JUMPAddress : PCAddress + cons;

// PCAddress register is trigerred on fall edge
always @ (negedge clk)
begin
	PCAddress = nextAddress;
end
// If PC register needs to be clean
always @ (clear)
begin
	if(clear) begin
	PCAddress = 0;
	end
end
endmodule
