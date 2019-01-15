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

