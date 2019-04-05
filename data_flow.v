// LST Gates - controls the flow of data from the L Staticisor
module _LST_GATES #(parameter N=10) (input w_HA, input [N-1:0] b_LST_out,
	output [N-1:0] b_LST_GATES_out);

	genvar i;
	generate for (i=0; i<N; i=i+1)
		assign b_LST_GATES_out[i] = w_HA & b_LST_out[i];
	endgenerate

endmodule

module _JUNCTION #(parameter WIDTH = 40) (input [0:WIDTH-1] data_in_1, input [0:WIDTH-1] data_in_2,
	output [0:WIDTH-1] data_out);

	genvar i;
	generate for (i=0; i<WIDTH; i=i+1)
		assign data_out[i] = data_in_1[i] | data_in_2[i];
	endgenerate
endmodule

module _GATE #(parameter WIDTH = 40) (input gate, input [0:WIDTH-1] data_in,
	output [0:WIDTH-1] data_out);

	genvar i;
	generate for (i=0; i<WIDTH; i=i+1)
		assign data_out[i] = gate & data_in[i];
	endgenerate
endmodule

module _GATEARRAY #(parameter WIDTH = 40) (input [0:WIDTH-1] gate, input [0:WIDTH-1] data_in,
	output [0:WIDTH-1] data_out);

	genvar i;
	generate for (i=0; i<WIDTH; i=i+1)
		assign data_out[i] = gate[i] & data_in[i];
	endgenerate
endmodule


// SEG - S Erase Waveform Generator
module _SEG #(parameter INST_STA = 6'b010100, parameter LINE_LENGTH = 40,
	parameter INSTR_FUNCTION_BITS = 6)
	(input w_PARA_ACTION, input [0:INSTR_FUNCTION_BITS-1] b_FST, input w_KLC, input w_HA,
	output [0:LINE_LENGTH-1] b_SE);


	genvar i;
	generate for (i=0; i<LINE_LENGTH; i=i+1)
		assign b_SE[i] = (~w_PARA_ACTION & (b_FST == INST_STA)) | (w_KLC & w_HA);
	endgenerate
endmodule


// ACEG - Accumulator and Control Logic Erase Waveform Generator
module _ACEG #( parameter INST_JMP = 6'b000101, parameter INST_LDA = 6'b100000,
	parameter INST_Z = 6'b100100, parameter INST_NEG = 6'b110110,
	parameter INST_SHR = 6'b111110, parameter INST_HLT = 6'b111111,
	parameter INSTR_FUNCTION_BITS = 6)
	(input w_PARA_ACTION, input [0:INSTR_FUNCTION_BITS-1] b_FST,
	output w_ACEG);
	
	assign w_ACEG = ~w_PARA_ACTION &
			(b_FST == INST_JMP |
			b_FST == INST_LDA |
			b_FST == INST_Z | 
			b_FST == INST_NEG | 
			b_FST == INST_SHR |
			b_FST == INST_HLT);
endmodule
	

// OTG -  Outward Transfer Gate
// Controls the flow of data from the Main Store
module _OTG #(parameter INSTR_FUNCTION_BITS = 6,
	parameter INST_LDA = 6'b100000, parameter INST_ADD = 6'b101100, parameter INST_SUB = 6'b100110,
	parameter INST_NEG = 6'b110110, parameter INST_SHR = 6'b111110,
	parameter LINE_LENGTH = 40)
	(input [0:LINE_LENGTH-1] b_MS_DATA_OUT, input [0:INSTR_FUNCTION_BITS-1] b_FST,
	input w_PARA_ACTION,
	output [0:LINE_LENGTH-1] b_A_DATA_IN);

	genvar i;
	generate for (i=0; i<LINE_LENGTH; i=i+1)
		assign b_A_DATA_IN[i] = b_MS_DATA_OUT[i] & ~w_PARA_ACTION &
			(b_FST == INST_LDA |
			b_FST == INST_ADD |
			b_FST == INST_SUB |
			b_FST == INST_NEG |
			b_FST == INST_SHR);
	endgenerate
endmodule


// TU - Test Unit
// Instructs CL 

/*

module _OTG (input w_PARA_ACTION, input w_MS_DATA_OUT, input w_INSTR_0_14, input w_INSTR_0_15, output w_ITG_DATA_OUT);
	assign w_ITG_DATA_OUT = w_MS_DATA_OUT & ~w_PARA_ACTION & w_INSTR_0_14 & w_INSTR_0_15;
endmodule




// S Erase Waveform Generator - 
module _SEG (input w_ACTION_PARA_WF, input w_INSTR_1_13, input w_INSTR_1_14, input w_INSTR_0_15, output w_S_ERASE_WF);
	assign w_S_ERASE_WF = ~w_ACTION_PARA_WF & w_INSTR_1_13 & w_INSTR_1_14 & w_INSTR_0_15;
endmodule
 

// Instruction Gate
module _IG (input w_INSTR_GATE, input w_CL_DATA_OUT, output w_IG_DATA_OUT);
	assign w_IG_DATA_OUT = ~w_INSTR_GATE & w_CL_DATA_OUT;
endmodule

// Test Unit
module _TU #(parameter INSTR_BITS = 20) (input [INSTR_BITS-1:0] w_PS, input w_ACTION_TRIGGER, input w_PARA_S1, input w_INSTR_0_13, input w_INSTR_1_14, input w_INSTR_1_15, input w_CLK, output w_TU_OUT);
	reg scan2 = 0;		// State flips each SCAN beat, therefore high during SCAN2 beats in
				// automatic operation
	reg trigger50 = 0;
	reg prev_action_trigger = 0;

	wire gate53;
	wire gate52;

	always @ (negedge w_ACTION_TRIGGER) begin
		scan2 <= ~scan2;
	end

	always @ (posedge w_CLK) begin
		// If the final bit is a 1, and the FST bits are set
		// appropriately, set the trigger
		if (w_INSTR_0_13 & w_INSTR_1_14 & w_INSTR_1_15 & w_PS[INSTR_BITS-1]) begin
			trigger50 <= 1;
		end

		// If at the end of SCAN1, reset the trigger
		else if (w_ACTION_TRIGGER & ~scan2) begin
			trigger50 <= 0;
		end

		
	end

	assign gate53 = ~trigger50 & w_PS[0];
	assign gate52 = trigger50 & w_PS[1];

	assign w_TU_OUT = gate52 | gate53;

endmodule
*/
