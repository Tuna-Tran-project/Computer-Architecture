module output_mux(
	input logic i_clk,
	//input_buffer
	input logic [31:0] b_io_btn,
	input logic [31:0] b_io_sw,
	//output_buffer
	input  logic [31:0] b_io_ledr,
	input  logic [31:0] b_io_ledg,
	input  logic [31:0] b_io_hexl,
	input  logic [31:0] b_io_hexh,
	input  logic [31:0] b_io_lcd,
	//D_mem
	input  logic [31:0] b_dmem_data,
	// READ address
	input  logic        f_dmem_valid,
	input  logic        f_io_valid,
	input  logic [31:0] i_ld_addr,
	output logic [31:0] o_ld_data,

	 //IO output
	output logic [31:0] o_io_ledr,
	output logic [31:0] o_io_ledg,
	output logic [ 6:0] o_io_hex0,
	output logic [ 6:0] o_io_hex1,
	output logic [ 6:0] o_io_hex2,
	output logic [ 6:0] o_io_hex3,
	output logic [ 6:0] o_io_hex4,
	output logic [ 6:0] o_io_hex5,
	output logic [ 6:0] o_io_hex6,
	output logic [ 6:0] o_io_hex7,
	output logic [31:0] o_io_lcd
	);

	always_comb begin
	 if (f_dmem_valid) begin
		o_ld_data = b_dmem_data;
	 end else if (f_io_valid) begin
				case (i_ld_addr)
					32'h1000_0: o_ld_data = b_io_ledr;   // Red LEDs
					32'h1000_1: o_ld_data = b_io_ledg;   // Green LEDs
					32'h1000_2: o_ld_data = b_io_hexl;   // Seven-seg LEDs 3-0
					32'h1000_3: o_ld_data = b_io_hexh;   // Seven-seg LEDs 7-4
					32'h1000_4: o_ld_data = b_io_lcd;    // LCD control
					32'h1001_0: o_ld_data = b_io_sw;     // Switches
				default: o_ld_data = 32'd0;
			endcase
	 end
	end
		assign o_io_hex0   = b_io_hexl[ 6: 0];
		assign o_io_hex1   = b_io_hexl[14: 8];
		assign o_io_hex2   = b_io_hexl[22:16];
		assign o_io_hex3   = b_io_hexl[30:24];
		assign o_io_hex4   = b_io_hexh[ 6: 0];
		assign o_io_hex5   = b_io_hexh[14: 8];
		assign o_io_hex6   = b_io_hexh[22:16];
		assign o_io_hex7   = b_io_hexh[30:24];
		assign o_io_lcd    = b_io_lcd;
endmodule