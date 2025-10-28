module output_buffer(
	input logic i_clk,
	input logic i_reset,
	//data input
	input logic [31:0] i_st_data,
	input logic [31:0] i_io_addr,
	input 				 f_io_wren,
   //IO output
	output logic [31:0] b_io_ledr,
	output logic [31:0] b_io_ledg,
	output logic [31:0] b_io_hexl,
	output logic [31:0] b_io_hexh,
	output logic [31:0] b_io_lcd
);
// Full 32-bit IO addresses inside region 0x1000_0000 .. 0x1001_0FFF
always @(posedge i_clk or negedge i_reset)
	if (~i_reset) begin
	b_io_ledr <= 32'b0;
	b_io_ledg <= 32'b0;
	b_io_hexl <= 32'b0;
	b_io_hexh <= 32'b0;
	b_io_lcd  <= 32'b0;
	end else if (f_io_wren == 1'b1) begin
		case (i_io_addr[31:12])
	32'h1000_0: b_io_ledr <= i_st_data; // Red LEDs
	32'h1000_1: b_io_ledg <= i_st_data; // Green LEDs
	32'h1000_2: b_io_hexl <= i_st_data; // Seven-seg 3-0
	32'h1000_3: b_io_hexh <= i_st_data; // Seven-seg 7-4
	32'h1000_4: b_io_lcd  <= i_st_data; // LCD control
		endcase
	end
endmodule
	