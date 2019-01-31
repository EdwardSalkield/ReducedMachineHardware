module _WU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input w_MS_DATA_INSTR_BITS, input w_MS_LOOPBACK, input w_CLK, output [INSTR_BITS:0] b_ST_DATA_IN);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter;
	reg [INSTR_BITS-1:0] buffer;

	always @ (posedge w_CLK) begin
		if (counter < INSTR_BITS)
			buffer[counter] = w_MS_DATA_INSTR_BITS;
		if (counter != 0) buffer[counter-1] = w_MS_LOOPBACK | buffer[counter-1];
		counter = (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end

	assign b_ST_DATA_IN = buffer;
endmodule


module _RU #(parameter INSTR_BITS = 20, parameter FLYBACK_TIME = 4) (input [INSTR_BITS-1:0] b_ST_DATA_OUT, input w_MS_ZERO, input w_CLK, output w_MS_DATA_OUT);
	reg [$clog2(INSTR_BITS + FLYBACK_TIME):0] counter = 0;
	always @ (posedge w_CLK) begin
		if (counter < INSTR_BITS)
			w_MS_DATA_OUT <= (w_MS_ZERO) ? 0 : b_ST_DATA_OUT[counter];
		else
			w_MS_DATA_OUT <= 0;
		counter <= (counter == INSTR_BITS + FLYBACK_TIME - 1) ? 0 : counter + 1;
	end
endmodule


module _ST #(parameter INSTR_BITS = 20, parameter INSTR_ADDR_BITS = 10)
(input w_CLK, input w_XTB, input[INSTR_ADDR_BITS-1:0] b_MS_ADDR, input[INSTR_BITS-1:0] in_data, output[INSTR_BITS-1:0
] out_data);
	reg [INSTR_BITS-1:0] memorySpace [0:2**INSTR_ADDR_BITS-1];
	reg [INSTR_BITS-1:0] data_out_reg;

	always @ (posedge w_CLK) begin
		if (w_XTB) begin
			memorySpace[b_MS_ADDR] <= in_data;
			data_out_reg <= in_data;
		end
		else data_out_reg <= memorySpace[b_MS_ADDR];
	end

	assign out_data = data_out_reg;
endmodule


module _MS #(parameter INSTR_BITS = 20, parameter INSTR_ADDR_BITS = 10, parameter FLYBACK_TIME = 4)
(input [INSTR_ADDR_BITS-1:0] b_MS_ADDR, input w_XTB, input w_CLK, input w_MS_ZERO, input w_MS_DATA_IN, output w_MS_DATA_OUT, output [INSTR_BITS-1:0] datain, output [INSTR_BITS-1:0] datamem);

	wire [INSTR_BITS-1:0] b_ST_DATA_IN;
	wire [INSTR_BITS-1:0] b_ST_DATA_OUT;
	wire w_MS_LOOPBACK;


	_WU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) write_unit (w_MS_DATA_IN, w_MS_LOOPBACK, w_CLK, b_ST_DATA_IN);
	_ST #(.INSTR_BITS(INSTR_BITS), .INSTR_ADDR_BITS(INSTR_ADDR_BITS)) storage_tube
		(w_CLK, w_XTB, b_MS_ADDR, b_ST_DATA_IN, b_ST_DATA_OUT);
	_RU #(.INSTR_BITS(INSTR_BITS), .FLYBACK_TIME(FLYBACK_TIME)) read_unit (b_ST_DATA_OUT, w_MS_ZERO, w_CLK, w_MS_LOOPBACK);

	assign datain = b_ST_DATA_IN;
	assign datamem = b_ST_DATA_OUT;
	assign w_MS_DATA_OUT = w_MS_LOOPBACK;
endmodule
