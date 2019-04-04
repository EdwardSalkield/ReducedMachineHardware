`include "reduced_machine.v"

// Possible to have DISP_DATA based on S_TUBES instead of hard-coded?

module top (input CLK, input TPR_CLK, input TPR_DATA, input S_CLK, input S_DATA, input PS, input KSP,
	input SS, input KLC, input KSC, input WE, input KCC,
	output SL, /*output DISP_CLK,*/ output [1:0] DISP_DATA, output [3:0] LEDS, output OSC);

	parameter LINE_LENGTH = 40;
	parameter WORD_LENGTH = 20;
	parameter PAGE_SIZE = 32;
	parameter PAGES_PER_TUBE = 2;
	parameter S_TUBES = 2;
	parameter OSC_driven = 1;	// Whether the oscilloscope is on
	parameter n_OSC = 40;		//The number of lines driven by the oscilloscope

	//assign LEDS[0] = CLK;

	// Typewriter prescaler and decoder
	reg [$clog2(LINE_LENGTH):0] TPR_counter = 0;
	reg [0:LINE_LENGTH-1] b_TPR_DATA_OUT;

	// Maybe need initial begin for this buffer

	always @ (posedge TPR_CLK) begin
		b_TPR_DATA_OUT[TPR_counter] <= TPR_DATA;
		TPR_counter <= (TPR_counter == LINE_LENGTH - 1) ? 0 : TPR_counter + 1;
	end


	// Staticisor switch prescaler and decoder
	reg [$clog2(WORD_LENGTH):0] S_counter = 0;
	reg [WORD_LENGTH-1:0] S;

	// Maybe need initial begin for this buffer

	always @ (posedge S_CLK) begin
		S[S_counter] <= S_DATA;
		S_counter <= (S_counter == WORD_LENGTH - 1) ? 0 : S_counter + 1;
	end

	assign LEDS[0] = TPR_CLK;
	assign LEDS[1] = TPR_DATA;

	// Set up oscilloscope input
	reg actual_clock;
	reg [$clog2(n_OSC+1):0] OSC_counter;
	reg [n_OSC-1:0] b_OSC;
	reg OSC_out;

	//assign b_OSC[0] = 0;
	//assign b_OSC[1] = 1;

	if (OSC_driven) begin
		// Subdivide clock into number of oscilloscope
		always @ (posedge CLK) begin
			actual_clock <= (OSC_counter < n_OSC + 1);
			OSC_counter <= (OSC_counter == (n_OSC * 2) +1 ) ? 0 : OSC_counter + 1;

			// Oscillator output
			if (OSC_counter != 0 && OSC_counter != n_OSC + 1)
				OSC_out <= b_OSC[(OSC_counter%(n_OSC+1))-1];

		end
	end
	else begin
		assign actual_clock = CLK;
	end

	//assign LEDS[0] = OSC_out;
	//assign LEDS[1] = OSC_counter[0];
	assign LEDS[2] = OSC_counter[1];
	assign LEDS[3] = OSC_counter[2];
			
	assign OSC = OSC_out;


	


    // Connect up the processor

    reg nothing;
	TESTBENCH #(
		.LINE_LENGTH(LINE_LENGTH),
		.WORD_LENGTH(WORD_LENGTH),
		.PAGE_SIZE(PAGE_SIZE),
		.PAGES_PER_TUBE(PAGES_PER_TUBE),
		.S_TUBES(S_TUBES),
		.n_OSC(n_OSC))
	cpu(
		.w_CLK(actual_clock),
		.b_TPR_DATA_OUT(b_TPR_DATA_OUT),
		.b_S(S),
		.w_PS(PS),
		.w_KSP(KSP),
		.w_SS(SS),
		.w_KLC(KLC),
		.w_KSC(KSC),
		.w_WE(WE),
		.w_KCC(KCC),
		.w_SL(SL),
		.DISP_DATA(DISP_DATA),
		.LEDS(LEDS),
		.b_OSC(b_OSC)
	);

	

    // Handle output stuff
	assign DISP_CLK = CLK;
	//assign LEDS[3] = OSC;

	// Oscillator output
endmodule 
