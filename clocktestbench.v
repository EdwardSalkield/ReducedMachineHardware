`include "clock.v"

module TESTBENCH (input clk, output [23:0] led, output [3:0] indicators, input [15:0] buttons);
	// Generate clock signal
	reg clock;
	assign clock = buttons[7];
	assign led[7] = clock;

	wire w_div4;
	wire w_div6;
	wire [2:0] ctr1;
	wire [2:0] ctr2;
	wire w_bopg;
	wire w_n_bopg;



	_DV1 div4 (.i(clock), .o(w_div4));
	_DV2 div6 (.i(w_div4), .o(w_div6));
	_BOPG m_bopg (.i4(w_div4), .i6(w_div6), .q(w_bopg), .nq(w_n_bopg));


	reg ready;
	reg reset;
	reg reset_out;
	reg po;
	reg o;
	reg s;
	assign ready = buttons[6];
	assign reset = buttons[5];



	reg [1:0] w_ps;

	_PPG #(.N(2)) ppg (.dashclk(clock), .bo(ready), .reset(reset), .ps(w_ps), .r_out(reset_out));
	//_P p0 (.ready(ready), .dashclk(clock), .reset_in(reset), .reset_out(reset_out), .o(po));

	assign led[6] = ready;
	assign led[5] = reset_out;
	assign led[3:4] = w_ps;

	//_DV1 div6 (.i(w_div4), .o(w_div6), .ctr(ctr2));

	//assign led[6:5] = w_ps;
	//assign led[5:6] = ctr1;
	//assign led[3:4] = ctr2;
	//assign led[2] = w_clkgen;
	assign led[2] = w_div4;
	assign led[1] = w_div6;
	assign led[0] = w_bopg;


endmodule
