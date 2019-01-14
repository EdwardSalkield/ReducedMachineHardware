// Uses button presses to emulate switches
module switchbank #(parameter N = 1) (input [N-1:0] buttons, output [N-1:0] switches);
	always @ (posedge |buttons) begin
		switches <= switches ^ buttons;
	end
endmodule
