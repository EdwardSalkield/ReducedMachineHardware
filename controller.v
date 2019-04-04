// The clock circuitry

module _CONTROLLER #(parameter SUB_CYCLES = 13) (input in_CLK, output [SUB_CYCLES-1:0] b_CONTROLLER);
	reg [SUB_CYCLES-1:0] b_CONTROLLER = 0;
	reg [$clog2(SUB_CYCLES)-1:0] counter = 0;
	reg [$clog2(SUB_CYCLES)-1:0] i = 0;

	always @(posedge in_CLK) begin
		counter <= (counter == SUB_CYCLES-1) ? 0 : counter + 1;
	
		for (i=0; i<SUB_CYCLES; i=i+1)
			b_CONTROLLER[i] <= i == counter;

	end
endmodule
