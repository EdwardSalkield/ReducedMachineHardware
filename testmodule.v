module testmodule (input [0:1] p, output [0:1] o);
	reg [0:1] state;

	//initial begin
	//	state[0] = 1;
	//	state[1] = 1;
	//end
	
	assign state[0] = p[0];

	assign o = state;


endmodule
