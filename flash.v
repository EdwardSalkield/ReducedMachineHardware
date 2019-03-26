`include "reduced_machine.v"

// Possible to have DISP_DATA based on S_TUBES instead of hard-coded?

module top (input CLK, input TPR_CLK, input TPR_DATA, input S_CLK, input S_DATA, input PS, input KSP, input SS, input KLC, input KSC, output SL, output DISP_CLK, output [1:0] DISP_DATA, output [3:0] LEDS, output OSC);

	parameter LINE_LENGTH = 40;
	parameter WORD_LENGTH = 20;
	parameter PAGE_SIZE = 32;
	parameter PAGES_PER_TUBE = 2;
	parameter S_TUBES = 2;
	parameter OSC_driven = 1;	// Whether the oscilloscope is on
	parameter n_OSC = 6 + 4;		// The number of lines driven by the oscilloscope

	//assign LEDS[1] = CLK;

	// Typewriter prescaler and decoder
	reg [$clog2(LINE_LENGTH):0] TPR_counter = 0;
	reg [LINE_LENGTH-1:0] TPR = 0;

	// Maybe need initial begin for this buffer

	always @ (posedge TPR_CLK) begin
		if (TPR_counter < LINE_LENGTH)
			TPR[TPR_counter] = TPR_DATA;
		TPR_counter = (TPR_counter == LINE_LENGTH - 1) ? 0 : TPR_counter + 1;
	end


	// Staticisor switch prescaler and decoder
	reg [$clog2(WORD_LENGTH):0] S_counter = 0;
	reg [WORD_LENGTH-1:0] S = 0;

	// Maybe need initial begin for this buffer

	always @ (posedge S_CLK) begin
		if (S_counter < WORD_LENGTH)
			S[S_counter] = S_DATA;
		S_counter = (S_counter == WORD_LENGTH - 1) ? 0 : S_counter + 1;
	end


	// Set up oscilloscope input
	reg actual_clock;
	reg [$clog2(n_OSC)+1:0] OSC_counter = 0;
	reg [n_OSC-1:0] b_OSC;


	if (OSC_driven) begin
		// Subdivide clock into number of oscilloscope
		always @ (posedge CLK) begin
			actual_clock = (OSC_counter < n_OSC + 1);
			OSC_counter = (OSC_counter == (n_OSC * 2) +1 ) ? 0 : OSC_counter + 1;
		end
	end
	else begin
		assign actual_clock = CLK;
	end
			


	


    // Connect up the processor

	TESTBENCH #(
		.LINE_LENGTH(LINE_LENGTH),
		.WORD_LENGTH(WORD_LENGTH),
		.PAGE_SIZE(PAGE_SIZE),
		.PAGES_PER_TUBE(PAGES_PER_TUBE),
		.S_TUBES(S_TUBES),
		.n_OSC(n_OSC))
	cpu(
		.w_CLK(actual_clock),
		.TPR(TPR),
		.S(S),
		.PS(PS),
		.KSP(KSP),
		.SS(SS),
		.KLC(KLC),
		.KSC(KSC),
		.SL(SL),
		.DISP_DATA(DISP_DATA),
		.LEDS(LEDS),
		.b_OSC(b_OSC)
	);

	

    // Handle output stuff
	assign DISP_CLK = CLK;

	// Oscillator output
	if (OSC_driven) begin
		always @ (posedge CLK) begin
			if (OSC_counter != 0 && OSC_counter != n_OSC + 1)
				OSC = b_OSC[(OSC_counter%(n_OSC+1))-1];
		end
	end
   
endmodule 
