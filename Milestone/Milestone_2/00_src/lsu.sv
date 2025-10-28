module lsu(
  // System global input
  input  logic        i_clk,
  input  logic        i_reset,
  input  logic [2:0]  i_funct3,
  
  //Load-Store addr, enable, data
  input  logic [31:0] i_lsu_addr,
  input  logic [31:0] i_st_data,
  input  logic        i_lsu_wren,
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
  output logic [31:0] o_io_lcd,
  
  // IO input
  input  logic [31:0] i_io_sw
);

// ADDRESS IO

  localparam LEDR = 16'h7000;
  localparam LEDG = 16'h7010;
  localparam HEXL = 16'h7020; // hex low
  localparam HEXH = 16'h7024; // hex high
  localparam LCD  = 16'h7030;
  localparam SW   = 16'h7800;
  localparam BTN  = 16'h7810;

  logic [31:0] b_dmem_data;
  logic [31:0] b_io_ledr;
  logic [31:0] b_io_ledg;
  logic [31:0] b_io_hexl;
  logic [31:0] b_io_hexh;
  logic [31:0] b_io_lcd;
  logic [31:0] b_io_sw;
  logic [31:0] b_io_btn;
  
  logic        f_dmem_valid; // flag for dmem
  logic        f_io_valid;   // flag for io
  logic        f_dmem_wren; // flag for write to dmem
  logic        f_io_wren;   // flag for write to io
  
  
input_buffer u0(
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_io_sw(i_io_sw),
  .b_io_sw(b_io_sw)
);  

output_buffer u1(
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_st_data(i_st_data),
  .i_io_addr(i_lsu_addr), // lcd,hex high, hex low, ledg, ledr
  .f_io_wren(f_io_wren),
  .b_io_ledr(b_io_ledr),
  .b_io_ledg(b_io_ledg),
  .b_io_hexl(b_io_hexl),
  .b_io_hexh(b_io_hexh),
  .b_io_lcd(b_io_lcd)
);

dmem dmem_inst(
	.address(i_lsu_addr[10:2]),
	.i_clk(i_clk),
	.data(i_st_data),
	.wren(f_dmem_wren),
  .funct3(i_funct3),
	.q(b_dmem_data)
);


input_mux u2(
  .i_lsu_addr(i_lsu_addr),
  .i_lsu_wren(i_lsu_wren),
  .f_dmem_valid(f_dmem_valid), // flag for dmem
  .f_io_valid(f_io_valid),   // flag for io
  .f_dmem_wren(f_dmem_wren), // flag for write to dmem
  .f_io_wren(f_io_wren)   // flag for write to io
);

output_mux u3(
  // Output buffer and Dmem
  .b_dmem_data(b_dmem_data),
  .b_io_ledr(b_io_ledr),
  .b_io_ledg(b_io_ledg),
  .b_io_hexl(b_io_hexl),
  .b_io_hexh(b_io_hexh),
  .b_io_lcd(b_io_lcd),
  .b_io_sw(b_io_sw),
  .b_io_btn(b_io_btn),
  
  .f_dmem_valid(f_dmem_valid), // flag for dmem
  .f_io_valid(f_io_valid),   // flag for io
  .i_ld_addr(i_lsu_addr),
  .o_ld_data(o_ld_data),
  
  .o_io_ledr(o_io_ledr),
  .o_io_ledg(o_io_ledg),
  .o_io_hex0(o_io_hex0),
  .o_io_hex1(o_io_hex1),
  .o_io_hex2(o_io_hex2),
  .o_io_hex3(o_io_hex3),
  .o_io_hex4(o_io_hex4),
  .o_io_hex5(o_io_hex5),
  .o_io_hex6(o_io_hex6),
  .o_io_hex7(o_io_hex7),
  .o_io_lcd(o_io_lcd)
);

endmodule
