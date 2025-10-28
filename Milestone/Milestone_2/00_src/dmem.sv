//import single_cycle_pkg::*;
module dmem(
  input  logic        i_clk,
  input  logic [8:0]  address,   // 2KiB: 512 words
  input  logic [31:0] data,
  input  logic        wren,
  input  logic [2:0]  funct3,    // LD/ST type
  output logic [31:0] q
);

  // 2KiB memory: 512 words, 32-bit
  logic [7:0] tmem [0:2047]; // Use byte addressing for maximum flexibility

  // Store logic
  always_ff @(posedge i_clk) begin
    if (wren) begin
      case (funct3)
        3'b000: tmem[{address,2'b00}]     <= data[7:0];   // SB: Store Byte
        3'b001: begin                    // SH: Store Halfword
          tmem[{address,2'b00}]     <= data[7:0];
          tmem[{address,2'b01}]     <= data[15:8];
        end
        3'b010: begin                    // SW: Store Word
          tmem[{address,2'b00}]     <= data[7:0];
          tmem[{address,2'b01}]     <= data[15:8];
          tmem[{address,2'b10}]     <= data[23:16];
          tmem[{address,2'b11}]     <= data[31:24];
        end
        default: ; 
      endcase
    end
  end

  // Load logic
  // Read bytes into temporaries to avoid indexed/replicated selects directly on the array
  always_comb begin
    logic [7:0] b0, b1, b2, b3;
    b0 = tmem[{address,2'b00}];
    b1 = tmem[{address,2'b01}];
    b2 = tmem[{address,2'b10}];
  b3 = tmem[{address,2'b11}];

    case (funct3)
      3'b000: // LB
        q = {{24{b0[7]}}, b0};
      3'b001: // LH
        q = {{16{b1[7]}}, b1, b0};
      3'b010: // LW
        q = {b3, b2, b1, b0};
      3'b100: // LBU
        q = {24'b0, b0};
      3'b101: // LHU
        q = {16'b0, b1, b0};
      default:
        q = 32'b0;
    endcase
  end

endmodule