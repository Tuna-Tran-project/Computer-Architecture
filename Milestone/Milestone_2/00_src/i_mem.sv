module i_mem(
	input [31:0] i_addr,
	output[31:0] o_data
);
logic [31:0] mem [0:2047];
initial begin
	$readmemh("C:/Users/Lenovo/Downloads/imem.hex", mem);
	$readmemh("C:/Users/Lenovo/Downloads/test_br_jal_jalr.hex", mem);
end
assign o_data = mem[i_addr[12:2]];
endmodule
