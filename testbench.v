`include "LSTAT.v"
`include "switchbank.v"
`include "clock.v"

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

	reg [0:0] ha;
	reg [2:0] s;
	reg [2:0] ps;
	reg [2:0] out;

	
	// Create a switch to control ha
	switchbank #(.N(1)) s_ha (.buttons(buttons[8:8]), .switches(ha));
	//assign ha = buttons[8:8];

	// Switch bank for s
	switchbank #(.N(2)) s_s (.buttons(buttons[4:3]), .switches(s));
	//assign s = buttons[5:4];

	// Create a switch bank to control ps
	switchbank #(.N(3)) s_ps (.buttons(buttons[7:5]), .switches(ps));
	//assign ps = buttons[7:6];

	// Create the LSTAT component, with inputs ha, s, ps, and output out
	LSTAT #(.INSTR_BITS(2), .INSTR_L_BITS(3)) lstat (.s(s), .ps(ps), .ha(ha), .out(out));
	//FSTAT #(.INSTR_BITS(2), .INSTR_F_BITS(2)) lstat (.s(s), .ps(ps), .ha(ha), .out(out));

	// Tie each of the outputs to some LEDs for testing
	//assign led[0] = ha;
	assign led[7:5] = ps;
	assign led[4:3] = s;
	assign led[2:0] = out;

endmodule
