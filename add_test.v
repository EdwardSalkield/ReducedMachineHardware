`include "controller.v"
`include "timing.v"
`include "switches.v"
`include "instruction_decoding.v"
`include "data_flow.v"
`include "main_store.v"

module TESTBENCH #(parameter LINE_LENGTH = 40, parameter WORD_LENGTH = 20, parameter PAGE_SIZE = 32,
	parameter PAGES_PER_TUBE = 2, parameter S_TUBES = 2, parameter n_OSC = 1)
	(input w_CLK, input [0:LINE_LENGTH-1] b_TPR_DATA_OUT, input [0:WORD_LENGTH-1] b_S, input w_PS,
	input w_KSP, input w_SS, input w_KLC, input w_KSC, input w_WE, input w_KCC,
	output w_SL, output [S_TUBES-1:0] DISP_DATA, output [3:0] LEDS, output [n_OSC-1:0] b_OSC);

	reg [0:4] test_1;
	reg [0:4] test_2;
	reg [0:4] test_3;

	//assign test_1 = 1;
	assign test_1[0] = 1;
	assign test_1[1] = 0;
	assign test_1[2] = 0;
	assign test_1[3] = 0;
	assign test_1[4] = 0;

	//assign test_2 = 1;
	assign test_2[0] = 1;
	assign test_2[1] = 1;
	assign test_2[2] = 1;
	assign test_2[3] = 0;
	assign test_2[4] = 0;

	reg [0:4] test_1_flip;
	reg [0:4] test_2_flip;
	reg [0:4] test_3_flip;

	genvar i;
	generate for (i=0; i<5; i=i+1) begin
		assign test_1_flip[i] = test_1[4-i];
		assign test_2_flip[i] = test_2[4-i];
		assign test_3[i] = test_3_flip[4-i];
	end endgenerate

	assign test_3_flip = test_1_flip + test_2_flip;


	assign b_OSC[0] = test_1[0];
	assign b_OSC[1] = test_1[1];
	assign b_OSC[2] = test_1[2];
	assign b_OSC[3] = test_1[3];
	assign b_OSC[4] = test_1[4];

	assign b_OSC[5] = test_2[0];
	assign b_OSC[6] = test_2[1];
	assign b_OSC[7] = test_2[2];
	assign b_OSC[8] = test_2[3];
	assign b_OSC[9] = test_2[4];

	assign b_OSC[10] = test_3[0];
	assign b_OSC[11] = test_3[1];
	assign b_OSC[12] = test_3[2];
	assign b_OSC[13] = test_3[3];
	assign b_OSC[14] = test_3[4];

	/*
	assign b_OSC[33] = b_ITG_SWITCH[0];
	assign b_OSC[34] = b_MS_ZERO[0];
	assign b_OSC[35] = b_TPR_SE[0];
	assign b_OSC[36] = b_TPR_HA_DATA[0];
	assign b_OSC[37] = b_SE[0];
	assign b_OSC[38] = w_KSC;
	assign b_OSC[39] = w_WE;
	*/

endmodule
