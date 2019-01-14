`include "timing.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);

	reg w_HA;
	reg w_HS;
	reg w_PP_WF;

	reg w_CL_YPLATE;
	reg w_INSTR_GATE;
	reg w_ACTION_TRIGGER_AUTO;
	reg w_ACTION_TRIGGER_MAN;

	reg test;
	reg w_CLK;

	assign w_HA = buttons[7];
	assign w_HS = buttons[6];
	assign w_PP_WF = buttons[5];
	assign w_CLK = buttons[4];

	_GYWG gywg (w_HA, w_HS, w_PP_WF, w_CLK, w_CL_YPLATE, w_INSTR_GATE, w_ACTION_TRIGGER_AUTO, w_ACTION_TRIGGER_MAN, test);


	//test t (w_CLK, led[1], led[0]);

	assign led[7] = w_HA;
	assign led[6] = w_HS;
	assign led[5] = w_PP_WF;
	assign led[4] = w_CL_YPLATE;
	assign led[3] = w_INSTR_GATE;
	assign led[2] = w_ACTION_TRIGGER_AUTO;
	assign led[1] = w_ACTION_TRIGGER_MAN;
	assign led[0] = test;

endmodule
