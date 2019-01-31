// Outward Transfer Gate - controls the flow of data from the Main Store
module _OTG (input w_PARA_ACTION_WF, input w_MS_DATA_OUT, input w_INSTR_0_14, input w_INSTR_0_15, output w_ITG_DATA_OUT);
	assign w_ITG_DATA_OUT = w_MS_DATA_OUT & ~w_PARA_ACTION_WF & w_INSTR_0_14 & w_INSTR_0_15;
endmodule


// Inward Transfer Gate - controls the flow of data to the Main Store
module _ITG (input w_KLC_OUT, input w_MS_DATA_OUT, output w_ITG_DATA_OUT);
	assign w_ITG_DATA_OUT = ~w_KLC_OUT & w_MS_DATA_OUT;
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
