`include "timing.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);

	reg w_PPU_IN;
	reg w_KSP;
	reg w_HA;
	reg w_CLK;
	reg w_PP_WF;
	
	reg w_1_13;
	reg w_1_14;
	reg w_1_15;

	reg w_SU_OUT;
	reg w_STOP_LAMP;
	reg w_ACTION_TRIGGER;

	//assign w_PPU_IN = buttons[7];
	assign w_KSP = buttons[6];
	assign w_HA = buttons[5];
	assign w_CLK = buttons[4];
	assign w_1_13 = buttons[3];
	assign w_1_14 = buttons[3];
	assign w_1_15 = buttons[3];
	assign w_ACTION_TRIGGER = buttons[2];

	assign w_PPU_IN = w_SU_OUT;

	_PPU ppu (w_PPU_IN, w_KSP, w_HA, w_CLK, w_PP_WF);
	_SU su (w_PP_WF, w_1_13, w_1_14, w_1_15, w_SU_OUT, w_STOP_LAMP);
	_AWG awg (w_HA, w_ACTION_TRIGGER, w_ACTION_WF, w_PARA_ACTION_WF);


	//test t (w_CLK, led[1], led[0]);

	assign led[7] = w_PPU_IN;
	assign led[6] = w_KSP;
	assign led[5] = w_HA;
	assign led[4] = w_CLK;
	assign led[3] = w_PP_WF;
	//assign led[2] = w_SU_OUT;
	assign led[2] = w_ACTION_TRIGGER;
	assign led[1] = w_STOP_LAMP;
	assign led[0] = w_ACTION_WF;

endmodule
