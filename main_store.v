module _MS #(parameter LINE_LENGTH = 40, parameter INSTR_ADDR_BITS = 10, parameter TUBE_DEPTH = 32,
	parameter N_TUBES = 2)
	(input w_CLK, input ready_out, input ready_in, input [0:INSTR_ADDR_BITS-1] b_MS_ADDR, input w_HS,
	input [0:LINE_LENGTH-1] b_MS_ZERO, input [0:LINE_LENGTH-1] b_MS_DATA_IN,
	output [0:LINE_LENGTH-1] b_MS_DATA_OUT);

	
	reg [0:LINE_LENGTH-1] b_MS_DATA_OUT;
	reg [LINE_LENGTH-1:0] b_TUBES [0:N_TUBES-1] [0:TUBE_DEPTH-1];	// Data within the tubes
		// Little-endian to work with built-in for loops

	// Pointers to next data to be accessed
	reg [0:$clog2(TUBE_DEPTH)] scan_addr;
	integer n_bit, tube;
	wire [0:4] tube_addr = b_MS_ADDR[0:4];
	wire [0:4] word_addr = b_MS_ADDR[5:9];

	always @(posedge w_CLK) begin
		if (ready_out) begin
			if (w_HS)
				// During SCAN beats, output zero (since can't
				// choose between arbitrary n tubes
				for (n_bit=0; n_bit<LINE_LENGTH; n_bit=n_bit+1)
					b_MS_DATA_OUT[n_bit] <= 0;

			else begin
				// During ACTION beats, output specified data
				for (n_bit=0; n_bit<LINE_LENGTH; n_bit=n_bit+1)
					b_MS_DATA_OUT[n_bit] <= b_TUBES[tube_addr][word_addr][n_bit];

			end
		end

		else if (ready_in) begin
			if (w_HS) begin
				// If zeroing, clear data in all tubes' scanpos position
				for (tube=0; tube<N_TUBES; tube=tube+1)
					for (n_bit=0; n_bit<LINE_LENGTH; n_bit=n_bit+1)
						b_TUBES[tube][scan_addr][n_bit] <=
							b_TUBES[tube][scan_addr][n_bit]
							& !b_MS_ZERO[n_bit];

				// Increment scan_addr "beam position"
				scan_addr <= (scan_addr == TUBE_DEPTH - 1) ? 0 : scan_addr + 1;
			end

			else
				// During ACTION beats, if zeroing, zero the requested line,
				// and write the requested n_bits in
				for (n_bit=0; n_bit<LINE_LENGTH; n_bit=n_bit+1)
					b_TUBES[tube_addr][word_addr][n_bit] <=
						b_MS_DATA_IN[n_bit]
							| (b_TUBES[tube_addr][word_addr][n_bit]
						&  !b_MS_ZERO[n_bit]);
		end
	end

	
endmodule

module _A #(parameter LINE_LENGTH = 40, parameter INSTR_FUNCTION_BITS = 6, parameter INST_Z = 6'b100100)
	(input w_CLK, input ready_out, input ready_in, input w_ACTION, input w_A_ZERO,
	input [0:LINE_LENGTH-1] b_A_DATA_IN, input [0:INSTR_FUNCTION_BITS-1] b_FST_OUT,
	output [0:LINE_LENGTH-1] b_A_DATA_OUT);

	reg [0:LINE_LENGTH-1] b_A_DATA_OUT;
	reg [0:LINE_LENGTH-1] b_TUBE;	// Data within the tubes


	always @(posedge w_CLK) begin
		if (ready_out)
			b_A_DATA_OUT <= (w_A_ZERO ? 0 : b_TUBE) - b_A_DATA_IN;

		else if (ready_in)
			if (w_ACTION)
				b_TUBE <= (b_FST_OUT == INST_Z) ? 0 : b_A_DATA_OUT;
	end

	
endmodule

