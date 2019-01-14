// Gates connected to L Staticisor output
// Ensure that the address is only provided to the Main Store during ACTION beats

module GATES #(parameter INSTR_L_BITS = 10)
(input [INSTR_L_BITS-1:0] i, input ha, output [INSTR_L_BITS-1:0] a);
	wire [INSTR_L_BITS-1:0] has = ha;
	assign a = i & ha;
endmodule
