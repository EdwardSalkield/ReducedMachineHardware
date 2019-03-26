`include "data_flow.v"
`include "main_store.v"
`include "clock.v"

module TESTBENCH #(parameter LINE_LENGTH = 40, parameter WORD_LENGTH = 20, parameter PAGE_SIZE = 32, parameter PAGES_PER_TUBE = 2, parameter S_TUBES = 2, parameter n_OSC = 1) (input w_CLK, input [LINE_LENGTH-1:0] TPR, input [WORD_LENGTH-1:0] S, input PS, input KSP, input SS, input KLC, input KSC, output SL, output [S_TUBES-1:0] DISP_DATA, output [3:0] LEDS, output [n_OSC-1:0] b_OSC);


	// Clock circuitry
	//  Clock prescaler wires
	wire w_DV1;
	wire w_DV2;
	wire w_BO_WF;
	wire w_PARA_BO_WF;
	wire b_PXTB;
	wire w_HA_WF;
	wire w_HS_WF;
	wire w_DPG;
	reg [WORD_LENGTH-1:0] w_PX;
	reg r_out;
	reg w_TEST;

	_DV1 DV1 (w_CLK, w_DV1);
	_DV2 DV2 (w_DV1, w_DV2);
	_BOPG BOPG (w_DV1, w_DV2, w_BO_WF, w_PARA_BO_WF);
	//_DPG DPG (w_CLK, w_DPG);
	
	//assign w_PARA_BO_WF = ~w_BO_WF;
	assign w_TEST = ~w_CLK || w_BO_WF;

	//_XWG XWG (w_BO_WF, b_PXTB);
	//_HWG HWG (w_BO_WF, w_HA_WF, w_HS_WF);

	_PPG #(.LINE_LENGTH(WORD_LENGTH)) PPG (w_DPG, w_BO_WF, w_PARA_BO_WF, w_PX, r_out);
	//assign LEDS[0] = w_CLK;
	assign LEDS[0] = w_CLK;
	assign LEDS[1] = w_DV1;
	assign LEDS[2] = w_DV2;
	assign LEDS[3] = w_BO_WF;

	/*
	reg b_MS_ADDR;
	reg b_PXTB;
	reg w_CLK;
	reg w_MS_ZERO;
	reg w_MS_DATA_IN;
	reg w_MS_DATA_OUT;

	_MS #(.INSTR_BITS(WORD_LENGTH), .INSTR_ADDR_BITS(1), .FLYBACK_TIME = 4)
	(b_MS_ADDR, b_PXTB, w_CLK, w_MS_ZERO, w_MS_DATA_IN,
		w_MS_DATA_OUT)

	assign b_MS_ADDR = 0;
	assign b_PXTB = PS;
	assign w_MS_ZERO = 0;
	assign w_MS_DATA_IN = TPR_DATA;
	assign w_CLK = CLK;
	assign DISP_DATA[0] = w_MS_DATA_OUT

	//assign DISP_DATA[0] = 1;
	//assign DISP_DATA[1] = 1;
	assign SL = CLK;
	assign LEDS[0] = CLK;
	assign LEDS[1] = TPR_CLK;
	assign LEDS[2] = */

       // Oscilloscope assignment
       //assign b_OSC[0] = CLK;
       //assign b_OSC[1] = w_DV1;
       //assign b_OSC[2] = w_DV2;
       //assign b_OSC[3] = w_BO_WF;
       //assign b_OSC[4] = w_PARA_BO_WF;

	assign b_OSC[0] = w_CLK;
	assign b_OSC[1] = w_DV1;
	assign b_OSC[2] = w_DV2;
	assign b_OSC[3] = w_BO_WF;
	assign b_OSC[4] = w_PARA_BO_WF;
	assign b_OSC[5] = w_TEST;
	assign b_OSC[6] = b_PX[0];
	assign b_OSC[7] = b_PX[1];
	assign b_OSC[8] = b_PX[2];
	assign b_OSC[9] = b_PX[3];
endmodule
