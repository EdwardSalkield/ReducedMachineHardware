// Accumulator Write Unit
module _AWU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input w_ASU_DATA_OUT, input w_CLK, input w_ACTION_WF, input w_INSTR_1_14, input w_INSTR_1_15, output [INSTR_BITS:0] b_AST_DATA_IN, output w_AST_ENABLE, output [1:0] buff, output [1:0] count);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter;
	reg [INSTR_BITS-1:0] buffer;

	always @ (posedge w_CLK) begin
		if (counter <= INSTR_BITS + 1)
			buffer[counter-1] = w_ASU_DATA_OUT;
		counter = (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end

	assign b_AST_DATA_IN = buffer;
	assign w_AST_ENABLE = ~w_ACTION_WF & (w_INSTR_1_14 | w_INSTR_1_15);
	assign count = counter;
	assign buff = buffer;
endmodule


// Accumulator Read Unit
module _ARU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input [INSTR_BITS-1:0] b_AST_DATA_OUT, input w_A_ZERO, input w_CLK, output w_A_DATA_OUT);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter = 1;
	always @ (posedge w_CLK) begin
		if (counter < INSTR_BITS)
			w_A_DATA_OUT <= (w_A_ZERO) ? 0 : b_AST_DATA_OUT[counter];
		else
			w_A_DATA_OUT <= 0;
		counter <= (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end
endmodule


// Accumulator Storage Tube
module _AST #(parameter INSTR_BITS = 20)
(input w_CLK, input w_XTB, input[INSTR_BITS-1:0] in_data, input w_AST_ENABLE, output[INSTR_BITS-1:0] out_data);
	reg [INSTR_BITS-1:0] memorySpace;
	reg [INSTR_BITS-1:0] data_out_reg;

	always @ (posedge w_CLK) begin
		if (w_XTB & w_AST_ENABLE) begin
			memorySpace <= in_data;
			data_out_reg <= in_data;
		end
		else data_out_reg <= memorySpace;
	end

	assign out_data = data_out_reg;
endmodule

// Subcomponent of _ASU to perform binary addition
module _ASU_BIN_ADDER (input a, input b, input c, output d, output carry);
	assign d = (~a & ~b & c) | (~a & b & ~c) | (a & b & c) | (a & ~b & ~c);
	assign carry = (a & b) | (b & c) | (a & c);
endmodule

// TODO: Define the subtract unit
// Accumulator Subtract Unit
module _ASU (input w_ARU_DATA_OUT, input w_A_DATA_IN, input w_CLK, input w_XTB, output w_ASU_DATA_OUT);
	reg carry = 1;
	reg next_carry;
	reg next_data;

	_ASU_BIN_ADDER aba (w_ARU_DATA_OUT, ~w_A_DATA_IN, carry, next_data, next_carry);

	always @ (posedge w_CLK) begin
		if (w_XTB) begin
			carry <= 1;
			w_ASU_DATA_OUT <= 0;
		end else begin
			carry <= next_carry;
			w_ASU_DATA_OUT <= next_data;
		end
	end
endmodule


module _A #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4)
(input w_XTB, input w_A_DATA_IN, input w_KCC_OUT, input w_ACTION_WF, input w_INSTR_1_14, input w_INSTR_1_15, input w_A_ZERO, input w_CLK, output w_A_DATA_OUT, output w_ARU_DATA_OUT, output [1:0] buff, output w_AST_ENABLE, output [1:0] count);

	wire [INSTR_BITS-1:0] b_AST_DATA_IN;
	wire [INSTR_BITS-1:0] b_AST_DATA_OUT;

	wire w_ASU_DATA_OUT;
	wire w_ARU_DATA_OUT;
	//wire w_AST_ENABLE;

	_AWU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) write_unit
		(w_ASU_DATA_OUT, w_CLK, w_ACTION_WF, w_INSTR_1_14, w_INSTR_1_15, b_AST_DATA_IN,
		w_AST_ENABLE, buff, count);

	_AST #(.INSTR_BITS(INSTR_BITS)) storage_tube
		(w_CLK, w_XTB, b_AST_DATA_IN, w_AST_ENABLE, b_AST_DATA_OUT);

	_ARU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) read_unit (b_AST_DATA_OUT, w_A_ZERO, w_CLK, w_ARU_DATA_OUT);
	
	_ASU subtract_unit (w_ARU_DATA_OUT, w_A_DATA_IN, w_CLK, w_XTB, w_ASU_DATA_OUT);


	assign b_DATA_IN = b_AST_DATA_IN[0];
	assign w_A_DATA_OUT = w_ASU_DATA_OUT;
endmodule
