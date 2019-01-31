// Accumulator Subtract Unit testbench

`include "accumulator.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);

	// Test subtract unit
	reg w_ARU_DATA_OUT;
	reg w_A_DATA_IN;
	reg w_DPG;
	reg w_XTB;
	reg w_ASU_DATA_OUT;
	reg d;
	reg next_carry;
	reg a;
	reg b;
	reg c;

	assign w_ARU_DATA_OUT = buttons[7];
	assign w_A_DATA_IN = buttons[6];
	assign w_CLK = buttons[5];
	assign w_XTB = buttons[4];

	_ASU asu (w_ARU_DATA_OUT, w_A_DATA_IN, w_CLK, w_XTB, w_ASU_DATA_OUT);

	assign led[7] = w_ARU_DATA_OUT;
	assign led[6] = w_A_DATA_IN;
	assign led[5] = w_CLK;
	assign led[4] = w_XTB;
	assign led[2] = next_carry;
	assign led[1] = w_next_data;
	assign led[0] = w_ASU_DATA_OUT;

endmodule
