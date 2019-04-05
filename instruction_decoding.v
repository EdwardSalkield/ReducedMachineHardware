module _STATICISOR #(parameter WIDTH = 10) (input w_CLK, input ready, input w_HA, input [0:WIDTH-1] b_STAT_in, output [0:WIDTH-1] b_STAT_OUT);
	reg [0:WIDTH-1] b_STAT_OUT;
	reg [0:WIDTH-1] state;
	
	//integer i;
	always @(posedge w_CLK) if (ready) begin
		if (w_HA)
			// Output data
			b_STAT_OUT[0:WIDTH-1] <= state[0:WIDTH-1];
		else begin
			// Input data
			state[0:WIDTH-1] <= b_STAT_in[0:WIDTH-1];

			// Clear the output
			//for (i=0; i<WIDTH; i=i+1)
			//	b_STAT_OUT[i] <= 0;
		end
	end
endmodule
