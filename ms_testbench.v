`include "main_store.v"

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
	reg b_MS_ADDR;
	reg w_XTB;		// "write" signal
	reg w_MS_DATA_IN;
	reg w_MS_DATA_OUT;
	reg w_MS_ZERO;
	reg w_DPG;		// "clock"
	reg ctr;

	reg [1:0] datain;
	reg datamem;

	wire w_ST_DATA;
	
	assign buttons[7] = w_DPG;
	assign buttons[6] = w_MS_ZERO;
	assign buttons[5] = w_MS_DATA_IN;
	assign buttons[4] = w_MS_ADDR;
	assign buttons[3] = w_XTB;
	assign buttons[2] = b_MS_ADDR;

	//_WU #(1) write_unit (w_MS_DATA_IN, w_MS_ZERO, w_DPG, w_ST_DATA);
	//_RU #(.N(1)) read_unit (w_ST_DATA, w_MS_DPG, w_MS_DATA_OUT);
	_MS #(.INSTR_BITS(2), .INSTR_ADDR_BITS(1)) main_store (b_MS_ADDR, w_XTB, w_DPG, w_MS_ZERO, w_MS_DATA_IN, w_MS_DATA_OUT, datain, datamem);

	//_ST #(1) mem (w_DPG, w_XTB, 0, w_MS_DATA_IN, datamem);

	assign led[7] = w_DPG;
	assign led[6] = w_MS_ZERO;
	assign led[5] = w_MS_DATA_IN;
	assign led[4] = w_MS_ADDR;
	assign led[3] = w_XTB;
	assign led[1:2] = datain;
	//assign led[1] = datamem;
	assign led[0] = w_MS_DATA_OUT;

endmodule
