`include "accumulator.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);
	parameter WORD_LENGTH = 20;	// Number of bits per word

	// The encoding of the structure of an instruction
	parameter [8*3:0] INSTR_STRUCTURE = {8'd10, 8'd3, 8'd1, 8'd6};

	parameter INSTR_ADDR_LOC = 0;
	parameter INSTR_B_LOC = 1;
	parameter INSTR_SPARE_LOC = 2;
	parameter INSTR_FUNCTION_LOC = 3;


	// Parameterised parameters
	parameter INSTR_BITS = WORD_LENGTH;
		// Number of bits in the instruction immediate address
	parameter INSTR_ADDR_BITS = INSTR_STRUCTURE[8*INSTR_ADDR_LOC : (8*INSTR_ADDR_LOC)+8];
		// Number of bits to address the B-tubes
	parameter INSTR_B_BITS = INSTR_STRUCTURE[8*INSTR_B_LOC : (8*INSTR_B_LOC)+8];
		// Number of padding bits in the instruction
	parameter INSTR_SPARE_BITS = INSTR_STRUCTURE[8*INSTR_SPARE_LOC : (8*INSTR_SPARE_LOC)+8];
		// Number of function bits in the instruction
	parameter INSTR_FUNCTION_BITS = INSTR_STRUCTURE[8*INSTR_FUNCTION_LOC : (8*INST_FUNCTION_LOC)+8];

	// Test connecting a 1-bit write unit directly to a 1-bit read unit
	reg w_XTB;		// "write" signal
	reg w_CLK;		// "clock"
	reg w_A_DATA_IN;
	reg w_KCC_OUT;
	reg w_ACTION_WF;
	reg w_INSTR_14;
	reg w_INSTR_15;
	reg w_A_ZERO;
	reg w_ARU_DATA_OUT;

	reg w_A_DATA_OUT;
	
	reg [1:0] datain;
	reg datamem;

	wire w_ST_DATA;
	
	assign buttons[7] = w_XTB;
	assign buttons[6] = w_A_DATA_IN;
	assign buttons[5] = w_CLK;
	assign buttons[4] = w_KCC_OUT;
	assign buttons[3] = w_ACTION_WF;
	//assign buttons[2] = w_INSTR_1_14;
	//assign buttons[1] = w_INSTR_1_15;
	assign w_INSTR_1_14 = 1;
	assign w_INSTR_1_15 = 1;

	assign buttons[0] = w_A_ZERO;

	reg [1:0] buff;
	reg [1:0] count;
	reg w_AST_ENABLE;

	_A #(.INSTR_BITS(2), .FLYBACK_TIME(2)) acc (w_XTB, w_A_DATA_IN, w_KCC_OUT, w_ACTION_WF, w_INSTR_1_14, w_INSTR_1_15, w_A_ZERO, w_CLK, w_A_DATA_OUT, w_ARU_DATA_OUT, buff, w_AST_ENABLE, count);



	assign led[7] = w_XTB;
	assign led[6] = w_A_DATA_IN;
	assign led[5] = w_CLK;
	//assign led[4] = w_KCC_OUT;
	//assign led[3] = w_ACTION_WF;
	assign led[4] = buff[1];
	assign led[3] = buff[0];
	assign led[1] = w_ARU_DATA_OUT;
	assign led[2] = count[0];
	//assign led[1] = w_AST_ENABLE;
	assign led[0] = w_A_DATA_OUT;

endmodule
