module i_mem(
	input [31:0] i_addr,
	output[31:0] o_data
);
logic [31:0] mem [0:2047];
initial begin
	$readmemh("C:/Users/Lenovo/Downloads/imem.hex", mem);
end
assign o_data = mem[i_addr[7:2]];
endmodule
