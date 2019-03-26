// The clock circuitry

// DV1 - prescaler by 4
module _DV1 (input w_CLK, output w_DV1);
	reg [1:0] counter = 0;

	always @ (posedge w_CLK) begin
		counter <= counter + 1;
	end

	assign w_DV1 = (counter == 0) & w_CLK;
endmodule


// DV2 - prescaler by 6
module _DV2 (input w_DV1, output w_DV2);
	reg [2:0] counter = 0;

	always @ (posedge w_DV1) begin
		counter <= (counter == 5) ? 0 : counter + 1;
	end

	assign w_DV2 = (counter == 0) & w_DV1;
endmodule

// Generates the "black out pulse" signal, during which the electron beams in
// the CRTs would be in "flyback" to the next line
module _BOPG (input w_DV1, input w_DV2, output w_BO_WF, output w_PARA_BO_WF);
	reg state = 0;
	reg state2 = 0;

	always @ (posedge ( (w_DV1 && w_DV2 && ~state) || (w_DV1 && ~w_DV2 && state) )) begin
		state <= w_DV2 == 1;
		state2 <= w_DV2 == 1;
	end
	
	assign w_BO_WF = state2;
	assign w_PARA_BO_WF = ~state2;
endmodule


// Generates a signal to indicate when the main store ought to write
// Would originally have generated a sawtooth analogue waveform to modulate
// the scanning beam across the screen.
module _XWG (input w_BO_WF, output w_XTB);
	assign w_XTB = w_BO_WF;
endmodule


// Halver waveform generator
// Generates waveforms HA and HS, which are high during the action and scan
// beats, respectively.
module _HWG (input w_BO_WF, output w_HA_WF, output w_HS_WF);
	reg state = 1;

	always @ (posedge w_BO_WF) begin
		state <= ~state;
	end

	assign w_HA_WF = state;
	assign w_HS_WF = ~state;
endmodule

// This implementation cannot clock against dashclk, reset_in, and ready due
// to RTL limitations.
module _P (input ready, input dashclk, input reset_in, input reset_out, output o);
	reg readied;
	reg spent;

	always @ (negedge dashclk) begin
		//o <= 0;
		if (ready)
			readied <= 1;
		if (reset_in)
			spent <= 0;
		if (readied & ~spent) begin
			readied <= 0;
			spent <= 1;
			//o <= 1;
		end
	end

	assign o = (dashclk & readied & ~spent);
	assign reset_out = reset_in;
endmodule


module _PPG #(parameter LINE_LENGTH = 20) (input w_DPG, input w_BO_WF, input w_PARA_BO_WF, output [LINE_LENGTH-1:0] w_PX, output r_out);
	genvar i;

	// Wire clock
	//wire [LINE_LENGTH-1:0] w_DPGs;
	wire [LINE_LENGTH-1:0] ready;
	wire [LINE_LENGTH-1:0] out;
	wire [LINE_LENGTH-1:0] reset_in;
	wire [LINE_LENGTH-1:0] reset_out;


	// Wire readies
	assign ready[0] = w_BO_WF;
	generate for (i=1; i<LINE_LENGTH; i=i+1) begin
		assign ready[i] = out[i-1];
	end endgenerate

	// Wire resets
	assign reset_in[LINE_LENGTH-1] = w_PARA_BO_WF;
	generate for (i=0; i<LINE_LENGTH-1; i=i+1) begin
		assign reset_in[i] = reset_out[i+1];
	end endgenerate

	//assign reset_in[0] = reset_out[1];

	// Wire all P together
	_P p [LINE_LENGTH-1:0] (ready, w_DPG, reset_in, reset_out, out);

	generate for (i=0; i<LINE_LENGTH; i=i+1) begin
		assign w_PX[i] = out[i];
	end endgenerate
	assign r_out = reset_out[0];
endmodule

module _DPG (input w_CLK, output w_DPG);
	assign w_DPG = ~w_CLK;
endmodule

