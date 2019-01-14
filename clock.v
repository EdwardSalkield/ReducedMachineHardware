// The clock circuitry

// DV1 - divides the clock signal by 4
module _DV1 (input i, output o);
	reg [1:0] counter = 0;

	always @ (negedge i) begin
		counter <= counter + 1;
	end

	assign o = (counter == 0) & i;
	assign ctr = counter;
endmodule


module _DV2 (input i, output o);
	reg [2:0] counter = 0;

	always @ (negedge i) begin
		counter <= (counter == 6) ? 0 : counter + 1;
	end

	assign o = (counter == 0) & i;
	assign ctr = counter;
endmodule

// Generates the "black out pulse" signal, during which the electron beams in
// the CRTs would be in "flyback" to the next line
module _BOPG (input i4, input i6, output q, output nq);
	reg state = 1;
	always @ (posedge i4) begin
		state <= (i6 == 1);
	end
	
	assign q = state;
	assign nq = ~state;
endmodule


// Generates a signal to indicate when the main store ought to write
// Would originally have generated a sawtooth analogue waveform to modulate
// the scanning beam across the screen.
module _XWG (input bo, output xtb);
	assign xtb = bo;
endmodule


// Halver waveform generator
// Generates waveforms HA and HS, which are high during the action and scan
// beats, respectively.
module _HWG (input bo, output ha, output hs);
	reg state = 1;

	always @ (posedge bo) begin
		state <= ~state;
	end

	assign ha = state;
	assign hs = ~state;
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


module _PPG #(parameter N = 20) (input dashclk, input bo, input reset, output [N-1:0] ps, output r_out);
	genvar i;

	// Wire clock
	wire [N-1:0] dashclks;
	wire [N-1:0] ready;
	wire [N-1:0] out;
	wire [N-1:0] reset_in;
	wire [N-1:0] reset_out;


	// Wire readies
	assign ready[0] = bo;
	generate for (i=1; i<N; i=i+1) begin
		assign ready[i] = out[i-1];
	end endgenerate

	// Wire resets
	assign reset_in[N-1] = reset;	//works
	generate for (i=0; i<N-1; i=i+1) begin
		assign reset_in[i] = reset_out[i+1];
	end endgenerate

	//assign reset_in[0] = reset_out[1];

	// Wire all P together
	_P p [N-1:0] (ready, dashclk, reset_in, reset_out, out);

	generate for (i=0; i<N; i=i+1) begin
		assign ps[i] = out[i];
	end endgenerate
	assign r_out = reset_out[0];
endmodule

