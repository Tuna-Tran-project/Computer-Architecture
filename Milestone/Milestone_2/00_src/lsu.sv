//import single_cycle_pkg::*;
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
  
  // LD/ST instruction decoding (moved from dmem)
  logic [3:0]  dmem_byte_enable;
  logic [31:0] dmem_write_data;
  logic [31:0] dmem_read_data;
  logic [31:0] processed_read_data;
  logic [31:0] aligned_addr;        // Address after alignment
  logic [1:0]  original_offset;     // Original offset before alignment
  
  // Address alignment based on access type
  always_comb begin
    original_offset = i_lsu_addr[1:0];
    case (i_funct3)
      3'b001, 3'b101: aligned_addr = {i_lsu_addr[31:1], 1'b0};     // Half-word: truncate bit[0]
      3'b010:         aligned_addr = {i_lsu_addr[31:2], 2'b00};    // Word: truncate bits[1:0]  
      default:        aligned_addr = i_lsu_addr;                   // Byte: no truncation
    endcase
  end
  
  // Generate byte enable and write data based on funct3
  always_comb begin
    dmem_byte_enable = 4'b0000;
    dmem_write_data = i_st_data;
    
    if (f_dmem_wren) begin
      case (i_funct3)
        3'b000: begin // SB - store byte (any address)
          case (i_lsu_addr[1:0])  // Use original address for byte positioning
            2'b00: dmem_byte_enable = 4'b0001;
            2'b01: dmem_byte_enable = 4'b0010;
            2'b10: dmem_byte_enable = 4'b0100;
            2'b11: dmem_byte_enable = 4'b1000;
          endcase
          // Replicate byte to all positions
          dmem_write_data = {4{i_st_data[7:0]}};
        end
        3'b001: begin // SH - store halfword (truncate to even address)
          case (aligned_addr[1])  // Use aligned address
            1'b0: dmem_byte_enable = 4'b0011;
            1'b1: dmem_byte_enable = 4'b1100;
          endcase
          // Replicate halfword to both positions
          dmem_write_data = {2{i_st_data[15:0]}};
        end
        3'b010: begin // SW - store word (truncate to 4-byte boundary)
          dmem_byte_enable = 4'b1111;  // Always write all 4 bytes at aligned address
          dmem_write_data = i_st_data;
        end
        default: dmem_byte_enable = 4'b0000;
      endcase
    end
  end
  
  // Process read data based on funct3
  always_comb begin
    case (i_funct3)
      3'b000: begin // LB - load byte (sign-extended, any address)
        case (i_lsu_addr[1:0])  // Use original address for byte selection
          2'b00: processed_read_data = {{24{dmem_read_data[7]}}, dmem_read_data[7:0]};
          2'b01: processed_read_data = {{24{dmem_read_data[15]}}, dmem_read_data[15:8]};
          2'b10: processed_read_data = {{24{dmem_read_data[23]}}, dmem_read_data[23:16]};
          2'b11: processed_read_data = {{24{dmem_read_data[31]}}, dmem_read_data[31:24]};
        endcase
      end
      3'b100: begin // LBU - load byte unsigned (any address)
        case (i_lsu_addr[1:0])  // Use original address for byte selection
          2'b00: processed_read_data = {24'b0, dmem_read_data[7:0]};
          2'b01: processed_read_data = {24'b0, dmem_read_data[15:8]};
          2'b10: processed_read_data = {24'b0, dmem_read_data[23:16]};
          2'b11: processed_read_data = {24'b0, dmem_read_data[31:24]};
        endcase
      end
      3'b001: begin // LH - load halfword (sign-extended, truncate to even address)
        case (aligned_addr[1])  // Use aligned address for halfword selection
          1'b0: processed_read_data = {{16{dmem_read_data[15]}}, dmem_read_data[15:0]};
          1'b1: processed_read_data = {{16{dmem_read_data[31]}}, dmem_read_data[31:16]};
        endcase
      end
      3'b101: begin // LHU - load halfword unsigned (truncate to even address)
        case (aligned_addr[1])  // Use aligned address for halfword selection
          1'b0: processed_read_data = {16'b0, dmem_read_data[15:0]};
          1'b1: processed_read_data = {16'b0, dmem_read_data[31:16]};
        endcase
      end
      3'b010: begin // LW - load word (truncate to 4-byte boundary)
        processed_read_data = dmem_read_data;  // Always read full aligned word
      end
      default: processed_read_data = 32'b0;
    endcase
  end
  
  
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
  .i_funct3(i_funct3),
  .f_io_wren(f_io_wren),
  .b_io_ledr(b_io_ledr),
  .b_io_ledg(b_io_ledg),
  .b_io_hexl(b_io_hexl),
  .b_io_hexh(b_io_hexh),
  .b_io_lcd(b_io_lcd)
);

dmem dmem_inst(
  .i_reset(i_reset),
  .address(aligned_addr[11:0]),  // Use aligned address
	.i_clk(i_clk),
	.data(dmem_write_data),
	.wren(dmem_byte_enable),
	.q(dmem_read_data)
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
  .i_clk(i_clk),
  .b_dmem_data(processed_read_data),
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
