// L staticisor
module LSTAT #(parameter INSTR_BITS = 20, parameter INSTR_L_BITS = 10)
(input [INSTR_L_BITS-1:0] s, input [INSTR_BITS-1:0] ps, input ha, output [INSTR_L_BITS-1:0] out);
	// Create a bank of flip flops for the ps bits to toggle
	reg [INSTR_L_BITS-1:0] state = 0;

	always @(posedge !(&ps | ha)) begin
		state <= (~ps&s) | (ps&state);
	end
	
	assign out = state;

endmodule


// Gates connected to L Staticisor output
// Ensure that the address is only provided to the Main Store during ACTION beats
module GATES #(parameter INSTR_L_BITS = 10)
(input [INSTR_L_BITS-1:0] i, input ha, output [INSTR_L_BITS-1:0] a);
	wire [INSTR_L_BITS-1:0] has = ha;
	assign a = i & ha;
endmodule
