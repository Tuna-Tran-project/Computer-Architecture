module lsu(
  // System global input
  input  logic        i_clk,
  input  logic        i_rst,
  
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
  input  logic [31:0] i_io_sw,
  input  logic [ 3:0] i_io_btn,
  
  input  logic        reg_write,
  output logic [31:0] reg_mem
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
  
  always @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
      reg_mem <= 'd0;
    end else if(reg_write) begin
      reg_mem <= o_ld_data;
    end
  end
  
  
input_buffer u0(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_io_sw(i_io_sw),
  .i_io_btn(i_io_btn),
  .b_io_sw(b_io_sw),
  .b_io_btn(b_io_btn)
);  

output_buffer u1(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_st_data(i_st_data),
  .i_io_addr(i_lsu_addr[15:0]), // lcd,hex high, hex low, ledg, ledr
  .f_io_wren(f_io_wren),
  .b_io_ledr(b_io_ledr),
  .b_io_ledg(b_io_ledg),
  .b_io_hexl(b_io_hexl),
  .b_io_hexh(b_io_hexh),
  .b_io_lcd(b_io_lcd)
);
/*
dmem dmem_inst(
	.address(i_lsu_addr[12:2]),
	.byteena(4'hF),
	.clock(i_clk),
	.data(i_st_data),
	.wren(f_dmem_wren),
	.q(b_dmem_data)
);*/

tmem tmem_inst(
	.address(i_lsu_addr[10:2]),
	.clock(i_clk),
	.data(i_st_data),
	.wren(f_dmem_wren),
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
  .i_ld_addr(i_lsu_addr[15:0]),
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
module input_buffer(
  // System global input
  input  logic        i_clk,
  input  logic        i_rst,
  
  // IO input
  input  logic [31:0] i_io_sw,
  input  logic [ 3:0] i_io_btn,
  
  // IO buffer
  output logic [31:0] b_io_sw,
  output logic [31:0] b_io_btn
);
  
  always_ff @(posedge i_clk or negedge i_rst)
  begin
    if (!i_rst) begin
      b_io_sw  <= 'd0;
      b_io_btn <= 'd0;
    end else begin
      b_io_sw  <= i_io_sw;
      b_io_btn <= {28'd0,i_io_btn};
    end
  end
  
endmodule

module output_buffer(
  // System global input
  input  logic        i_clk,
  input  logic        i_rst,
  
  //Load-Store addr, enable, data
  input  logic [31:0] i_st_data,
  input  logic [15:0] i_io_addr, // lcd,hex high, hex low, ledg, ledr
  input  logic        f_io_wren,
  //IO output
  output logic [31:0] b_io_ledr,
  output logic [31:0] b_io_ledg,
  output logic [31:0] b_io_hexl,
  output logic [31:0] b_io_hexh,
  output logic [31:0] b_io_lcd
);

// ADDRESS FOR IO

  localparam LEDR = 16'h7000;
  localparam LEDG = 16'h7010;
  localparam HEXL = 16'h7020; // hex low
  localparam HEXH = 16'h7024; // hex high
  localparam LCD  = 16'h7030;

  always_ff @(posedge i_clk or negedge i_rst)
  begin
    if (!i_rst) begin
      b_io_ledr <= 'd0;
      b_io_ledg <= 'd0;
      b_io_hexl <= 'd0;
      b_io_hexh <= 'd0;
      b_io_lcd  <= 'd0;
    end else if (f_io_wren) begin
      case (i_io_addr)
        LEDR:  b_io_ledr <= i_st_data;
        LEDG:  b_io_ledg <= i_st_data;
        HEXL:  b_io_hexl <= i_st_data;
        HEXH:  b_io_hexh <= i_st_data;
        LCD :  b_io_lcd  <= i_st_data;
        default: ;
      endcase
    end
  end

endmodule

module input_mux(
  input  logic [31:0] i_lsu_addr,
  input  logic        i_lsu_wren,
  output logic        f_dmem_valid, // flag for dmem
  output logic        f_io_valid,    // flag for io
  output logic        f_dmem_wren,  // flag for write to dmem
  output logic        f_io_wren     // flag for write to io
);
  
  assign f_dmem_valid = ~(|i_lsu_addr[31:14]) & (i_lsu_addr[13]); //only use from 0x2000 to 0x3FFF
  assign f_io_valid   = ~(|i_lsu_addr[31:15]) & (i_lsu_addr[14]); //only use from 0x4000 to 0x7FFF
  assign f_dmem_wren = i_lsu_wren && f_dmem_valid;
  assign f_io_wren   = i_lsu_wren && f_io_valid;
  
endmodule

module output_mux(
  // Output buffer and Dmem
  input  logic [31:0] b_dmem_data,
  input  logic [31:0] b_io_ledr,
  input  logic [31:0] b_io_ledg,
  input  logic [31:0] b_io_hexl,
  input  logic [31:0] b_io_hexh,
  input  logic [31:0] b_io_lcd,
  input  logic [31:0] b_io_sw,
  input  logic [31:0] b_io_btn,
  
  // READ address
  input  logic        f_dmem_valid,
  input  logic        f_io_valid,
  input  logic [15:0] i_ld_addr,
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

  localparam LEDR = 16'h7000;
  localparam LEDG = 16'h7010;
  localparam HEXL = 16'h7020; // hex low
  localparam HEXH = 16'h7024; // hex high
  localparam LCD  = 16'h7030;
  localparam SW   = 16'h7800;
  localparam BTN  = 16'h7810;
  
  always_comb begin
    if (f_dmem_valid) begin
      o_ld_data = b_dmem_data;
    end else if (f_io_valid) begin
      case (i_ld_addr)
        LEDR: o_ld_data = b_io_ledr;
        LEDG: o_ld_data = b_io_ledg;
        HEXL: o_ld_data = b_io_hexl; //hex low
        HEXH: o_ld_data = b_io_hexh; //hex high
        LCD:  o_ld_data = b_io_lcd;
        SW:   o_ld_data = b_io_sw;
        BTN:  o_ld_data = b_io_btn;
        default: o_ld_data = 'd0;
      endcase
    end else begin
      o_ld_data = 'd0;
    end
  end

  //IO output  
  assign o_io_ledr   = b_io_ledr;
  assign o_io_ledg   = b_io_ledg;
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

module tmem(
  input  logic        clock,
  input  logic [ 7:0] address,
  input  logic [31:0] data,
  input  logic        wren,
  output logic [31:0] q
);

  logic [31:0] tmem [0:255];
  
  always_ff @(posedge clock) begin
    if (wren) tmem[address] <= data;
  end

  assign q = wren ? 32'd0 : tmem[address];
  
endmodule