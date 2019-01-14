module _ITG (input w_PARA_ACTION_WF, input w_MS_DATA_OUT, input w_INSTR_0_14, input w_INSTR_0_15, output w_ITG_DATA_OUT);
	assign w_ITG_DATA_OUT = w_MS_DATA_OUT & ~w_PARA_ACTION_WF & w_INSTR_0_14 & w_INSTR_0_15;
endmodule

