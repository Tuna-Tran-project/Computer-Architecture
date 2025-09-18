module PC(
	input i_clk, i_rst_n,
	input [31:0] i_pc_next,
	output [31:0] o_pc
);
	logic [31:0] pc;
always @(posedge i_clk or negedge i_rst_n);
	if(rst_n) begin
		pc <= 32'd0;
	end
	else begin
	o_pc <= i_pc_next;
	end
endmodule
