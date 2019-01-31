`include "data_flow.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);
	parameter WORD_LENGTH = 20;	// Number of bits per word

	// The encoding of the structure of an instruction
	parameter [8*3:0] INSTR_STRUCTURE = {8'd10, 8'd3, 8'd1, 8'd6};

	parameter INSTR_ADDR_LOC = 0;
	parameter INSTR_B_LOC = 1;
	parameter INSTR_SPARE_LOC = 2;
	parameter INSTR_FUNCTION_LOC = 3;


	// Parameterised parameters
	//parameter INSTR_BITS = WORD_LENGTH;
	parameter INSTR_BITS = 2;
		// Number of bits in the instruction immediate address
	parameter INSTR_ADDR_BITS = INSTR_STRUCTURE[8*INSTR_ADDR_LOC : (8*INSTR_ADDR_LOC)+8];
		// Number of bits to address the B-tubes
	parameter INSTR_B_BITS = INSTR_STRUCTURE[8*INSTR_B_LOC : (8*INSTR_B_LOC)+8];
		// Number of padding bits in the instruction
	parameter INSTR_SPARE_BITS = INSTR_STRUCTURE[8*INSTR_SPARE_LOC : (8*INSTR_SPARE_LOC)+8];
		// Number of function bits in the instruction
	parameter INSTR_FUNCTION_BITS = INSTR_STRUCTURE[8*INSTR_FUNCTION_LOC : (8*INST_FUNCTION_LOC)+8];

	reg b_PS [INSTR_BITS-1];
	reg w_ACTION_TRIGGER;
	reg w_PARA_S1;
	reg w_INSTR;
	reg w_INSTR;
	reg w_INSTR;
	reg w_CLK;
	reg w_TU_OUT;
	
	assign buttons[7] = w_CLK;
	assign buttons[6] = b_PS[0];
	assign buttons[5] = b_PS[1];
	assign buttons[4] = w_PARA_S1;
	assign buttons[3] = w_INSTR;

	_TU #(.INSTR_BITS(2)) test_unit (b_PS, w_ACTION_TRIGGER, w_PARA_S1, w_INSTR, w_INSTR, w_INSTR, w_CLK, w_TU_OUT);

	assign led[7] = w_CLK;
	assign led[6] = b_PS[0];
	assign led[5] = b_PS[1];
	assign led[4] = w_PARA_S1;
	assign led[3] = w_INSTR;
	assign led[0] = w_TU_OUT;

endmodule
