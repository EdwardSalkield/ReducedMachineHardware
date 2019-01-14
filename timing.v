module _PPU (input w_PPU_IN, input w_KSP, input w_HA, input w_CLK, output w_PP_WF);
	reg triggered = 0;	// If triggered, releases a prepulse next bar
	reg out;

	always @ (negedge w_HA | w_CLK) begin
		// Set
		if (out == 0) begin
			if (w_KSP | w_PPU_IN) begin
				out <= 1;
			end
		end

		// Reset
		else begin
			out <= 0;
		end

	end
	
	assign w_PP_WF = ~out;
endmodule


module _SU (input w_PP_WF, input w_1_13, input w_1_14, input w_1_15, output w_SU_OUT, output w_STOP_LAMP);
	reg running = 0;
	
	always @ (negedge w_PP_WF or posedge w_1_13 & w_1_14 & w_1_15) begin
		if (~w_PP_WF) begin
			running <= 1;
		end
		else
			running <= 0;
	end

	assign w_SU_OUT = running;
	assign w_STOP_LAMP = ~running;
endmodule


module _AWG (input w_HA, input w_ACTION_TRIGGER, output w_ACTION_WF, output w_PARA_ACTION_WF);
	reg trigger;

	always @ (negedge w_ACTION_TRIGGER & w_HA) begin
		trigger <= ~w_ACTION_TRIGGER;
	end
	
	assign w_ACTION_WF = trigger;
	assign w_PARA_ACTION_WF = ~trigger;
endmodule

module test (input w_CLK, output w_1, output w_2);
	reg state1;
	reg state2;

	always @ (posedge w_CLK) begin
		state1 <= ~state1;
	end

	always @ (posedge w_CLK) begin
		state2 <= ~state2;
	end

	assign w_1 = state1;
	assign w_2 = state2;
endmodule


module _GYWG (input w_HA, input w_HS, input w_PP_WF, input w_CLK, output w_CL_YPLATE, output w_INSTR_GATE, output w_ACTION_TRIGGER_AUTO, output w_ACTION_TRIGGER_MAN, output test);
	reg trigger1;
	reg trigger2;
	wire w_S1;
	wire w_PARA_S1;

	always @ (negedge w_PP_WF & w_HS) begin
		trigger1 <= ~w_PP_WF;
	end

	assign w_S1 = trigger1;
	assign w_PARA_S1 = ~trigger1;
	assign test = w_S1;

	always @ (negedge w_S1 | w_HS) begin
		trigger2 <= ~trigger2;
	end


	assign w_CL_YPLATE = trigger2;
	assign w_CL_PARA_YPLATE = ~trigger2;

	reg gate;
	assign gate = w_HA | (w_PARA_S1 & w_PARA_CL_YPLATE);
	assign w_INSTR_GATE = gate;

	reg trigger_man;
	reg trigger_auto;
	
	reg man_pulses = 1;

	always @ (negedge w_CLK) begin
		if (w_CL_PARA_YPLATE & man_pulses == 0) begin
			trigger_man <= 1;
			man_pulses <= 1;
		end
		else if (man_pulses == 1) begin
			trigger_man <= 0;
		end

		if (w_CL_YPLATE) begin
			man_pulses <= 0;
		end

	end

	reg auto_pulses = 0;
	always @ (negedge w_CLK) begin
		if (w_CL_YPLATE & auto_pulses == 0) begin
			trigger_auto <= 1;
			auto_pulses <= 1;
		end
		else if (auto_pulses == 1) begin
			trigger_auto <= 0;
		end

		if (w_CL_PARA_YPLATE) begin
			auto_pulses <= 0;
		end
	end

	assign w_ACTION_TRIGGER_MAN = trigger_man;
	assign w_ACTION_TRIGGER_AUTO = trigger_man | trigger_auto;
endmodule
