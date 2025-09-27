module mux2_1(
	input [31:0] i_a, i_b,
	input i_sel,
	output [31:0]o_c
);
assign o_c = (i_sel) ? i_a : i_b;
endmodule
