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

module _A #(parameter LINE_LENGTH = 40, parameter INSTR_FUNCTION_BITS = 6,
	parameter INST_CMP = 6'b000101, parameter INST_JMP = 6'b001101, parameter INST_STA = 6'b010100,
	parameter INST_HLT = 6'b111111,
	parameter INST_ADD = 6'b101100, parameter INST_SHR = 6'b111110, parameter INST_LDA = 6'b100000)
	(input w_CLK, input ready_out, input ready_in, input w_ACTION, input w_A_ZERO,
	input [0:LINE_LENGTH-1] b_A_DATA_IN, input [0:INSTR_FUNCTION_BITS-1] b_FST_OUT,
	output [0:LINE_LENGTH-1] b_A_DATA_OUT, output [0:LINE_LENGTH-1] b_TUBE);

	reg [0:LINE_LENGTH-1] b_A_DATA_OUT;
	reg [0:LINE_LENGTH-1] b_TUBE;	// Data within the tubes

	// Asynchronous circuitry
	wire write_unit_block = (b_FST_OUT == INST_JMP | b_FST_OUT == INST_HLT);
	wire add_condition = b_FST_OUT == INST_ADD | b_FST_OUT == INST_SHR | b_FST_OUT == INST_LDA;
	wire [0:LINE_LENGTH-1] read_unit_out;
	wire [0:LINE_LENGTH-1] subtract_unit_out;

	genvar i;
	generate for (i=0; i<LINE_LENGTH; i=i+1) begin
		assign read_unit_out[i] = (w_A_ZERO | write_unit_block ? 0 : b_TUBE[i]);
	end endgenerate

	assign subtract_unit_out[0:LINE_LENGTH-1] = add_condition ? read_unit_out[LINE_LENGTH-1:0] + b_A_DATA_IN[LINE_LENGTH-1:0]
		: read_unit_out[LINE_LENGTH-1:0] - b_A_DATA_IN[LINE_LENGTH-1:0];	// TODO: Two's complement subtraction


	always @(posedge w_CLK) begin
		if (ready_out)
			// Apply bit shift
			b_A_DATA_OUT <= (b_FST_OUT == INST_SHR) ? subtract_unit_out >> 1
			: subtract_unit_out;

		else if (ready_in)
			//if (w_ACTION)
			// Test if writing to A
			if (!write_unit_block)
				b_TUBE <= b_A_DATA_OUT;

	end

	
endmodule

