module _switch (input switch, input w_0, input w_1, output w_out);
	assign w_out = (switch) ? w_1 : w_0;
endmodule


