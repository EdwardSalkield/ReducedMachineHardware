// Uses button presses to emulate switches
module switchbank #(parameter N = 1) (input [N-1:0] buttons, output [N-1:0] switches);
	always @ (posedge |buttons) begin
		switches <= switches ^ buttons;
	end
endmodule

// SS/2 - selects between manual and automatic insertion of bits into LST and FST
module s_selector (input trigger, input a, input b, output out);
	reg state = 0;
	always @ (posedge trigger) begin
		state <= ~state;
	end

	assign out = state ? a : b;
endmodule
		
