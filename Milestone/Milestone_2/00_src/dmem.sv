//import single_cycle_pkg::*;
module dmem(
  input  logic        i_clk,
  input  logic        i_reset,
  input  logic [10:0] address,   // 2 KiB byte addressing
  input  logic [31:0] data,
  input  logic        wren,
  input  logic [2:0]  funct3,    // LD/ST type
  output logic [31:0] q
);

  localparam DEPTH = 2048;

  logic [7:0] tmem [0:DEPTH-1];

  logic [12:0] addr0_ext;
  logic [12:0] addr1_ext;
  logic [12:0] addr2_ext;
  logic [12:0] addr3_ext;
  logic        addr0_valid;
  logic        addr1_valid;
  logic        addr2_valid;
  logic        addr3_valid;
  logic [11:0] addr0;
  logic [11:0] addr1;
  logic [11:0] addr2;
  logic [11:0] addr3;
  logic [7:0]  b0;
  logic [7:0]  b1;
  logic [7:0]  b2;
  logic [7:0]  b3;

  assign addr0_ext = {1'b0, address};
  assign addr1_ext = addr0_ext + 13'd1;
  assign addr2_ext = addr0_ext + 13'd2;
  assign addr3_ext = addr0_ext + 13'd3;

  assign addr0_valid = (addr0_ext[12] == 1'b0);
  assign addr1_valid = (addr1_ext[12] == 1'b0);
  assign addr2_valid = (addr2_ext[12] == 1'b0);
  assign addr3_valid = (addr3_ext[12] == 1'b0);

  assign addr0 = addr0_ext[11:0];
  assign addr1 = addr1_ext[11:0];
  assign addr2 = addr2_ext[11:0];
  assign addr3 = addr3_ext[11:0];

  always_ff @(posedge i_clk or negedge i_reset) begin
    if (~i_reset) begin
      tmem <= '{default:8'h00};
    end else if (wren) begin
      case (funct3)
        3'b000: begin // SB
          if (addr0_valid)
            tmem[addr0] <= data[7:0];
        end
        3'b001: begin // SH
          if (addr0_valid)
            tmem[addr0] <= data[7:0];
          if (addr1_valid)
            tmem[addr1] <= data[15:8];
        end
        3'b010: begin // SW
          if (addr0_valid)
            tmem[addr0] <= data[7:0];
          if (addr1_valid)
            tmem[addr1] <= data[15:8];
          if (addr2_valid)
            tmem[addr2] <= data[23:16];
          if (addr3_valid)
            tmem[addr3] <= data[31:24];
        end
        default: ;
      endcase
    end
  end

  always_comb begin
    b0 = (addr0_valid) ? tmem[addr0] : 8'h00;
    b1 = (addr1_valid) ? tmem[addr1] : 8'h00;
    b2 = (addr2_valid) ? tmem[addr2] : 8'h00;
    b3 = (addr3_valid) ? tmem[addr3] : 8'h00;

    case (funct3)
      3'b000: q = {{24{b0[7]}}, b0};             // LB
      3'b100: q = {24'b0, b0};                   // LBU
      3'b001: q = {{16{b1[7]}}, b1, b0};         // LH
      3'b101: q = {16'b0, b1, b0};               // LHU
      3'b010: q = {b3, b2, b1, b0};              // LW
      default: q = 32'b0;
    endcase
  end

endmodule
