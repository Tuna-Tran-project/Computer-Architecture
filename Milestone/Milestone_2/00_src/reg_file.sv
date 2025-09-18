module reg_file(
	input i_clk, i_rst,
	input  [4:0]	i_rs1_addr,
	input  [4:0] 	i_rs2_addr,
	input  [4:0] 	i_rd_addr,	
	input 			i_rd_wren,
	input  [31:0]	i_rd_data,
	output [31:0]	o_rs1_data,
	output [31:0]	o_rs2_data
);
logic [31:0] registers [31:0];// 32 registers
//READ PORTS
assign o_rs1_data = (i_rs1_addr == 1'b0) ? 32'd0: registers[i_rs1_addr];
assign o_rs2_data = (i_rs2_addr == 1'b0) ? 32'd0: registers[i_rs2_addr];
//WRITE PORTS
always_ff @(posedge i_clk or negedge i_rst)
	if(!i_rst) begin
		integer i;
       for (i = 0; i < 32; i = i + 1)
         registers[i] <= 32'b0;
	end
	else if (i_rd_wren && (i_rd_addr != 5'd0)) begin
		registers[i_rd_addr] <= i_rd_data;
	end
endmodule
