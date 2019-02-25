/* 
	Mert KELKİT - 150115013
	Furkan NAKIP - 150115032
*/
module ALU (
A,
B,
operation,
carry_out,
result
);
// A and B are operands
input [15:0] A;
input [15:0] B;
// operation signal (ALUSignal, comes from control unit). If it's 1, addition operation will be done, else and operation will be done
input operation;
// carry out coming from adder
output wire carry_out;
// result of operation
output wire [15:0] result;
// carry in is a constant, 0
parameter carry_in = 1'b0;
// assign result with vector concatenation
assign {cout, result} = (operation) ? carry_in + B + A : {1'b0, A & B};
endmodule