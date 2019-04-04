module _STATICISOR #(parameter WIDTH = 10) (input w_CLK, input ready, input w_HA, input [WIDTH-1:0] b_STAT_in, output [WIDTH-1:0] b_STAT_out);
	reg [WIDTH-1:0] b_STAT_out;
	reg [WIDTH-1:0] state;
	
	always @(posedge w_CLK) if (ready) begin
		if (w_HA)
			// Output data
			b_STAT_out[WIDTH-1:0] <= state[WIDTH-1:0];
		else
			// Input data
			state[WIDTH-1:0] <= b_STAT_in[WIDTH-1:0];
	end
endmodule
