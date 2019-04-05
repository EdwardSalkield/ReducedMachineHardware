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

	// Global parameters
	
	// Instruction set
	parameter INST_NOP = 6'b000000;
	parameter INST_CMP = 6'b000101;
	parameter INST_JMP = 6'b001101;
	parameter INST_STA = 6'b010100;
	parameter INST_LDA = 6'b100000;
	parameter INST_Z   = 6'b100100;
	parameter INST_ADD = 6'b101100;
	parameter INST_SUB = 6'b100110;
	parameter INST_NEG = 6'b110110;
	parameter INST_SHR = 6'b111110;
	parameter INST_HLT = 6'b111111;


	//  Instruction structure
	//   Modifiable
	parameter INSTR_BITS = WORD_LENGTH;
	// Number of bits in the instruction immediate address
        parameter INSTR_ADDR_BITS = 10;
	// Number of bits to address the B-tubes
        parameter INSTR_B_BITS = 1;
	// Number of padding bits in the instruction
	parameter INSTR_SPARE_BITS = 3;
	// Number of function bits in the instruction
        parameter INSTR_FUNCTION_BITS = 6;

	parameter TUBE_DEPTH = 2;
	parameter N_TUBES = 2;
	
	reg ZERO = 0;
	reg ONE = 1;

	// Explicit communication controller
	parameter SUB_CYCLES = 9;
	reg [SUB_CYCLES-1:0] b_CONTROLLER;
	_CONTROLLER #(.SUB_CYCLES(SUB_CYCLES)) CONTROLLER (w_CLK, b_CONTROLLER);

	wire [0:INSTR_ADDR_BITS-1] b_LST_OUT;
	wire [0:INSTR_FUNCTION_BITS-1] b_FST_OUT;

	// Timing circuitry
	//  Clock
	wire w_HS, w_HA;
	_CLK CLK (w_CLK, b_CONTROLLER[0], w_HA, w_HS);

	//  Prepulse and stop units
	wire w_PPU_retrig, w_PP_WF;
	_PPU PPU (w_CLK, b_CONTROLLER[1], w_PPU_retrig, w_HA, w_KSP, w_PS, w_PP_WF);
	_SU #(.INST_HLT(INST_HLT), .INSTR_FUNCTION_BITS(INSTR_FUNCTION_BITS)) SU (w_CLK, b_CONTROLLER[8], w_PP_WF, b_FST_OUT, w_PPU_retrig);

	// Instruction Gate and Control Logic Y Plate Generator
	wire w_S1, w_CL_YPLATE, w_INSTR_GATE, w_ACTION_AUTO, w_ACTION_MAN;
	_GYWG GYWG (w_CLK, b_CONTROLLER[2], b_CONTROLLER[3], w_HS, w_HA, w_PP_WF,
		w_S1, w_CL_YPLATE, w_INSTR_GATE, w_ACTION_AUTO, w_ACTION_MAN);

	// Control Logic storage tube
	wire w_CL_data_out;

	// Instruction Gate
	wire w_IG_out;

	// AWG - Action Waveform Generator
	// Generates the Para-Action Waveform from the Action Waveform
	wire w_PARA_ACTION;
	_AWG AWG (w_ACTION, w_PARA_ACTION);
	
	// SS-2 - Staticisor selector switch -  selects between manual and automatic
	//                                      operation of the machine
	wire w_ACTION;
	wire w_SX_in;
	_switch SS2a (w_SS, w_ACTION_MAN, w_ACTION_AUTO, w_ACTION);
	_switch SS2b (w_SS, ~w_HA, w_IG_out, w_SX_in);

	// Sx - Select manual bits to insert into the staticisors
	wire [0:INSTR_BITS-1] b_STAT_in;
	_switch SX [0:INSTR_BITS-1] (b_S, ZERO, w_SX_in, b_STAT_in);


	// Staticisor units
	_STATICISOR #(.WIDTH(INSTR_ADDR_BITS)) LST
		(w_CLK, b_CONTROLLER[4], w_HA, b_STAT_in[0:INSTR_ADDR_BITS-1],
		b_LST_OUT);
	_STATICISOR #(.WIDTH(INSTR_FUNCTION_BITS)) FST
		(w_CLK, b_CONTROLLER[4], w_HA, b_STAT_in[INSTR_BITS-INSTR_FUNCTION_BITS:INSTR_BITS-1], 
		b_FST_OUT);
	
	wire [0:INSTR_ADDR_BITS-1] b_MS_ADDR;
	_LST_GATES #(.N(INSTR_ADDR_BITS)) LST_GATES
		(w_HA, b_LST_OUT, b_MS_ADDR);


	// Main Store Dataflow Circuitry
	//  SEG - S Erase Waveform Generator
	wire [0:LINE_LENGTH-1] b_SE;
	_SEG #(.INST_STA(INST_STA), .LINE_LENGTH(LINE_LENGTH), .INSTR_FUNCTION_BITS(INSTR_FUNCTION_BITS))
		SEG (w_PARA_ACTION, b_FST_OUT, w_KLC, w_HA,
		b_SE);

	// TPR_GATE - Controls the output of the TPR for zeroing circuitry
	// (GATE 56 in diagram)
	wire [0:LINE_LENGTH-1] b_TPR_HA_DATA;
	_GATE #(.WIDTH(LINE_LENGTH)) TPR_GATE (w_HA, b_TPR_DATA_OUT, b_TPR_HA_DATA);

	wire [0:LINE_LENGTH-1] b_TPR_SE;
	_JUNCTION #(.WIDTH(LINE_LENGTH)) TPR_SEG (b_TPR_HA_DATA, b_SE, b_TPR_SE);

	//  KSC - wipes entire storage
	wire [0:LINE_LENGTH-1] b_MS_ZERO;
	_switch KSC [0:LINE_LENGTH-1] (w_KSC, b_TPR_SE, ONE, b_MS_ZERO);

	//  WE - toggles write/erase modes for typewriter
	wire [0:LINE_LENGTH-1] b_WE_OUT;
	_GATE #(.WIDTH(LINE_LENGTH)) WE (!w_WE, b_TPR_SE, b_WE_OUT);
	
	//  KLC - toggles manual rewriting of selected line
	wire [0:LINE_LENGTH-1] b_ITG_SWITCH;
	_GATE #(.WIDTH(LINE_LENGTH)) KLC (!w_KLC, b_WE_OUT, b_ITG_SWITCH);
	
	
	// ITG - Inward Transfer Gate
	wire [0:LINE_LENGTH-1] b_A_DATA_OUT;
	//wire [0:LINE_LENGTH-1] b_TPR_DATA_OUT;
	wire [0:LINE_LENGTH-1] b_ITG_DATA_IN;
	wire [0:LINE_LENGTH-1] b_MS_DATA_IN;

	_JUNCTION #(.WIDTH(LINE_LENGTH)) ITG_JUNCTION (b_A_DATA_OUT, b_TPR_DATA_OUT, b_ITG_DATA_IN);
	_GATEARRAY #(.WIDTH(LINE_LENGTH)) ITG (b_ITG_SWITCH, b_ITG_DATA_IN, b_MS_DATA_IN);


	// Main store
	reg [0:LINE_LENGTH-1] b_MS_DATA_OUT;
	reg [0:4] tube_addr;
	reg [0:4] word_addr;
	_MS #(.LINE_LENGTH(LINE_LENGTH), .INSTR_ADDR_BITS(INSTR_ADDR_BITS), .TUBE_DEPTH(TUBE_DEPTH),
		.N_TUBES(N_TUBES)) MS (w_CLK, b_CONTROLLER[5], b_CONTROLLER[7], b_MS_ADDR, w_HS,
		b_MS_ZERO, b_MS_DATA_IN,
		b_MS_DATA_OUT, tube_addr, word_addr);


	// OTG - Outward Transfer Gate
	wire [0:LINE_LENGTH-1] b_A_DATA_IN;
	_OTG #(.INSTR_FUNCTION_BITS(INSTR_FUNCTION_BITS),
		.INST_LDA(INST_LDA), .INST_ADD(INST_ADD), .INST_SUB(INST_SUB),
		.INST_NEG(INST_NEG), .INST_SHR(INST_SHR),
		.LINE_LENGTH(LINE_LENGTH))
		OTG (b_MS_DATA_OUT, b_FST_OUT, w_PARA_ACTION, b_A_DATA_IN);

	// ACEG - Accumulator and Control Logic Erase Waveform Generator
	wire w_ACEG;
	_ACEG #(.INST_JMP(INST_JMP), .INST_LDA(INST_LDA), .INST_Z(INST_Z), .INST_NEG(INST_NEG), .INST_SHR(INST_SHR), .INST_HLT(INST_HLT)) ACEG
		(w_PARA_ACTION, b_FST_OUT,
		w_ACEG);
	
	// KCC - Accumulator Zero
	wire w_A_ZERO;
	_switch KCC (w_KCC, w_ACEG, ONE, w_A_ZERO);


	// A - Accumulator
	reg [0:LINE_LENGTH-1] b_TUBE;
	reg [0:LINE_LENGTH-1] subtract_unit_out;
	_A #(.LINE_LENGTH(LINE_LENGTH), .INSTR_FUNCTION_BITS(INSTR_FUNCTION_BITS),
		.INST_CMP(INST_CMP), .INST_JMP(INST_JMP), .INST_STA(INST_STA), .INST_HLT(INST_HLT),
		.INST_ADD(INST_ADD), .INST_SHR(INST_SHR), .INST_LDA(INST_LDA)) A
		(w_CLK, b_CONTROLLER[6], b_CONTROLLER[7], w_ACTION, w_A_ZERO, b_A_DATA_IN, b_FST_OUT,
		b_A_DATA_OUT, b_TUBE, subtract_unit_out);


	// Outputs
	//assign w_SL = ~w_PPU_retrig;
	//reg w_SL_internal = ~w_PPU_retrig;

	assign b_OSC[0] = 1;
	assign b_OSC[1] = w_HS;
	assign b_OSC[2] = w_HA;
	assign b_OSC[3] = w_PP_WF;
	assign b_OSC[4] = w_PPU_retrig;
	assign b_OSC[5] = w_S1;
	assign b_OSC[6] = w_CL_YPLATE;
	assign b_OSC[7] = w_INSTR_GATE;
	assign b_OSC[8] = w_ACTION_AUTO;
	assign b_OSC[9] = w_ACTION_MAN;
	assign b_OSC[10] = w_ACTION;
	assign b_OSC[11] = w_PARA_ACTION;
	assign b_OSC[12] = ~w_PPU_retrig;

	//assign b_OSC[13:22] = b_TPR_DATA_OUT[0:9];
	//assign b_OSC[23:32] = b_ITG_DATA_IN[0:9];
	
	assign b_OSC[13] = b_MS_DATA_OUT[0];
	assign b_OSC[14] = b_MS_DATA_OUT[1];
	assign b_OSC[15] = b_MS_DATA_OUT[2];
	assign b_OSC[16] = b_MS_DATA_OUT[3];
	assign b_OSC[17] = b_MS_DATA_OUT[4];

	assign b_OSC[18] = b_MS_DATA_IN[0];
	assign b_OSC[19] = b_MS_DATA_IN[1];
	assign b_OSC[20] = b_MS_DATA_IN[2];
	assign b_OSC[21] = b_MS_DATA_IN[3];
	assign b_OSC[22] = b_MS_DATA_IN[4];

	/*
	assign b_OSC[23] = b_STAT_in[14];
	assign b_OSC[24] = b_STAT_in[15];
	assign b_OSC[25] = b_STAT_in[16];
	assign b_OSC[26] = b_STAT_in[17];
	assign b_OSC[27] = b_STAT_in[18];
	assign b_OSC[28] = b_STAT_in[19];
	*/

	
	assign b_OSC[23] = b_FST_OUT[0];
	assign b_OSC[24] = b_FST_OUT[1];
	assign b_OSC[25] = b_FST_OUT[2];
	assign b_OSC[26] = b_FST_OUT[3];
	assign b_OSC[27] = b_FST_OUT[4];
	assign b_OSC[28] = b_FST_OUT[5];
	

	assign b_OSC[29] = w_A_ZERO;
	assign b_OSC[30] = b_A_DATA_IN[0];
	assign b_OSC[31] = b_A_DATA_IN[1];
	assign b_OSC[32] = b_A_DATA_IN[2];
	assign b_OSC[33] = b_A_DATA_IN[3];
	assign b_OSC[34] = b_A_DATA_IN[4];
	
	/*
	assign b_OSC[35] = subtract_unit_out[0];
	assign b_OSC[36] = subtract_unit_out[1];
	assign b_OSC[37] = subtract_unit_out[2];
	assign b_OSC[38] = subtract_unit_out[3];
	assign b_OSC[39] = subtract_unit_out[4];
	*/


	assign b_OSC[35] = b_A_DATA_OUT[0];
	assign b_OSC[36] = b_A_DATA_OUT[1];
	assign b_OSC[37] = b_A_DATA_OUT[2];
	assign b_OSC[38] = b_A_DATA_OUT[3];
	assign b_OSC[39] = b_A_DATA_OUT[4];

	assign b_OSC[40] = word_addr[0];
	assign b_OSC[41] = word_addr[1];
	assign b_OSC[42] = word_addr[2];
	assign b_OSC[43] = word_addr[3];
	assign b_OSC[44] = word_addr[4];


	assign b_OSC[45] = tube_addr[0];
	assign b_OSC[46] = tube_addr[1];
	assign b_OSC[47] = tube_addr[2];
	assign b_OSC[48] = tube_addr[3];
	assign b_OSC[49] = tube_addr[4];

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
