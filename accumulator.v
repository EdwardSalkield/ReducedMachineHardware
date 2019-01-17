// Accumulator Write Unit
module _AWU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input w_ASU_DATA_OUT, input w_DPG, input w_ACTION_WF, input w_INSTR_1_14, input w_INSTR_1_15, output [INSTR_BITS:0] b_AST_DATA_IN, output w_AST_ENABLE);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter;
	reg [INSTR_BITS-1:0] buffer;

	always @ (posedge w_DPG) begin
		if (counter < INSTR_BITS)
			buffer[counter] = w_ASU_DATA_OUT;
		counter = (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end

	assign b_ST_DATA_IN = buffer;
	assign w_AST_ENABLE = ~w_ACTION_WF & (w_INSTR_1_14 | w_INSTR_1_15);
endmodule


// Accumulator Read Unit
module _ARU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input [INSTR_BITS-1:0] b_AST_DATA_OUT, input w_A_ZERO, input w_DPG, output w_A_DATA_OUT);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter = 0;
	always @ (posedge w_DPG) begin
		if (counter < INSTR_BITS)
			w_A_DATA_OUT <= (w_A_ZERO) ? 0 : b_AST_DATA_OUT[counter];
		else
			w_A_DATA_OUT <= 0;
		counter <= (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end
endmodule


// Accumulator Storage Tube
module _AST #(parameter INSTR_BITS = 20)
(input w_DPG, input w_XTB, input[INSTR_BITS-1:0] in_data, input w_AST_ENABLE, output[INSTR_BITS-1:0] out_data);
	reg [INSTR_BITS-1:0] memorySpace;
	reg [INSTR_BITS-1:0] data_out_reg;

	always @ (posedge w_DPG) begin
		if (w_XTB & w_AST_ENABLE) begin
			memorySpace <= in_data;
			data_out_reg <= in_data;
		end
		else data_out_reg <= memorySpace;
	end

	assign out_data = data_out_reg;
endmodule


// TODO: Define the subtract unit
// Accumulator Subtract Unit
module _ASU (input w_ARU_DATA_OUT, input w_A_DATA_IN, output w_ASU_DATA_OUT, input w_DPG, input w_XTB);
	reg w_carry = 1;
	wire w_AXB;
	wire w_AAB;
	wire w_AXBAC;

	always @ (posedge w_DPG) begin
		if (w_XTB) begin
			w_carry = 1;
		end
		else begin
			w_AXB <= w_ARU_DATA_OUT ^ ~w_A_DATA_IN;
			w_AAC <= w_ARU_DATA_OUT & ~w_A_DATA_IN;
			w_AXBAC <= w_AXB & w_carry;
			w_carry <= w_AXBAC | w_AAB
			w_ASU_DATA_OUT <= w_AXB ^ w_carry;
		end
	end
endmodule

module _A #(parameter INSTR_BITS = 20, parameter INSTR_ADDR_BITS = 10, parameter FLYBACK_TIME = 4)
(input w_XTB, input w_DPG, input w_A_DATA_IN, input w_KCC_OUT, input w_ACTION_WF, input w_INSTR_1_14, input w_INSTR_1_15, input w_A_ZERO, output w_A_DATA_OUT);

	wire [INSTR_BITS-1:0] b_AST_DATA_IN;
	wire [INSTR_BITS-1:0] b_AST_DATA_OUT;

	wire w_ASU_DATA_OUT;
	wire w_ARU_DATA_OUT;
	wire w_AST_ENABLE;

	_AWU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) write_unit
		(w_ASU_DATA_OUT, w_DPG, w_ACTION_WF, w_INSTR_1_14, w_INSTR_1_15, b_AST_DATA_IN,
		w_AST_ENABLE);

	_AST #(.INSTR_BITS(INSTR_BITS), .INSTR_ADDR_BITS(INSTR_ADDR_BITS)) storage_tube
		(w_DPG, w_XTB, b_AST_DATA_IN, w_AST_ENABLE, b_AST_DATA_OUT);

	_ARU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) read_unit (b_AST_DATA_OUT, w_A_ZERO, w_DPG, w_ARU_DATA_OUT);
	
	_ASU subtract_unit (w_ARU_DATA_OUT, w_A_DATA_IN, w_ASU_DATA_OUT);


	assign w_A_DATA_OUT = w_ASU_DATA_OUT;
endmodule
