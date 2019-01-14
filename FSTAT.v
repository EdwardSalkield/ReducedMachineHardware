// L staticisor

module FSTAT #(parameter INSTR_BITS = 20, parameter INSTR_F_BITS = 10)
(input [0:INSTR_F_BITS-1] s, input [0:INSTR_BITS-1] ps, input ha, output [0:INSTR_F_BITS-1] i1, output [0:INSTR_F_BITS-1] i0);
	// Create a bank of flip flops for the ps bits to toggle
	reg [0:INSTR_F_BITS-1] state = 0;

	always @(posedge !(&ps | ha)) begin
		state <= (~ps&s) | (ps&state);
	end
	
	assign i1 = state;
	assign i0 = ~state;

endmodule
