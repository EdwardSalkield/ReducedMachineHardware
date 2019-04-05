module _STATICISOR #(parameter WIDTH = 10) (input w_CLK, input ready, input w_HA, input [0:WIDTH-1] b_STAT_in, output [0:WIDTH-1] b_STAT_out);
	reg [0:WIDTH-1] b_STAT_out;
	reg [0:WIDTH-1] state;
	
	always @(posedge w_CLK) if (ready) begin
		if (w_HA)
			// Output data
			b_STAT_out[0:WIDTH-1] <= state[0:WIDTH-1];
		else
			// Input data
			state[0:WIDTH-1] <= b_STAT_in[0:WIDTH-1];
	end
endmodule
