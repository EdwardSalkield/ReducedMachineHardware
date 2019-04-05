// Clock, outputs the halver waveforms
module _CLK (input w_CLK, input ready, output w_HA, output w_HS);
	reg w_HA = 0;
	reg w_HS = 0;

	always @(posedge w_CLK) if (ready) begin
		w_HS <= ~w_HS;
		w_HA <= w_HS;
	end
endmodule


// Prepulse unit - releases a prepulse next bar if triggered
module _PPU (input w_CLK, input ready, input w_PPU_retrig, input w_HA, input w_KSP, input w_PS, output w_PP_WF);
	reg w_PP_WF = 0;
	reg state_C0 = 1;
	
	always @(posedge w_CLK) begin
		if (ready) begin
			if (~w_HA) begin
				// Only output every other SCAN beat
				state_C0 <= ~state_C0;
				
				// If w_PS low, release a prepulse only when
				// KSP operated
				if (w_PS) w_PP_WF <= (w_KSP | w_PPU_retrig) & state_C0;
				else w_PP_WF <= w_KSP & state_C0;
			end else w_PP_WF <= 0;
		end
	end
endmodule


// Stop unit - 
module _SU #(parameter INST_HLT = 6'b111111, parameter INSTR_FUNCTION_BITS = 6)
	(input w_CLK, input ready, input w_PP_WF, input [0:INSTR_FUNCTION_BITS-1] b_FST, output w_PPU_retrig);
	reg w_PPU_retrig = 0;

	always @(posedge w_CLK) if (ready) begin
		// Retrigger the prepulse
		if (w_PP_WF)
			w_PPU_retrig <= 1;
		// Halt on command
		if (b_FST == INST_HLT)
			w_PPU_retrig <= 0;
	end
endmodule


// Instruction Gate and Control Logic Y-Plate Generator
module _GYWG (input w_CLK, input ready, input ready2, input w_HS, input w_HA, input w_PP_WF,
	output w_S1, output w_CL_YPLATE, output w_INSTR_GATE, output w_ACTION_TRIGGER_AUTO,
	output w_ACTION_TRIGGER_MAN);
	
	reg w_S1 = 0;
	reg w_PARA_S1 = 0;
	reg w_CL_YPLATE = 0;
	reg w_PARA_CL_YPLATE = 0;
	reg w_ACTION_TRIGGER_AUTO;
	reg w_ACTION_TRIGGER_MAN;

	reg active_bar = 0;
	reg scan = 0;
	reg manual_state = 0;

	reg w_INSTR_GATE = 0;

	always @(posedge w_CLK) begin
		
		if (ready) begin
			// Set w_S1
			if (w_PP_WF) begin
				active_bar <= 1;
				w_S1 <= 1;
				w_PARA_S1 <= 0;
			end else begin
				w_S1 <= 0;
				w_PARA_S1 <= 1;
			end

			// Set w_CL_YPLATE
			if (w_S1) begin
				w_CL_YPLATE <= 1;
				w_PARA_CL_YPLATE <= 0;
			end else if (w_HA) begin
				w_CL_YPLATE <= 0;
				w_PARA_CL_YPLATE <= 1;
			end

			if (w_HS) begin
				scan <= ~scan;
				w_ACTION_TRIGGER_AUTO <= 0;
				w_ACTION_TRIGGER_MAN <= 0;
			end

			// Set Action Triggers
			if (w_HA) begin
				if (~scan)
					active_bar <= 0;

				if (active_bar) begin
					w_ACTION_TRIGGER_AUTO <= 1;
					manual_state <= ~manual_state;
					w_ACTION_TRIGGER_MAN <= manual_state;
				end
			end
		end
		else if (ready2) begin
			w_INSTR_GATE <= w_HA | (w_PARA_S1 & w_PARA_CL_YPLATE);
		end


	end
endmodule


// AWG - Action Waveform Generator
// Generates the para action waveform from the main one
module _AWG (input w_ACTION, output w_PARA_ACTION);
	assign w_PARA_ACTION = ~w_ACTION;
endmodule
