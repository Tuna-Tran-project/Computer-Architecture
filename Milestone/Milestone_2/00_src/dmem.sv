//import single_cycle_pkg::*;
module dmem(
  input  logic        i_clk,
  input  logic        i_reset,
  input  logic [10:0] address,   // 2 KiB byte addressing  
  input  logic [31:0] data,      // Write data (32-bit aligned)
  input  logic [3:0]  wren,      // Byte enable: [3]=addr+3, [2]=addr+2, [1]=addr+1, [0]=addr+0
  output logic [31:0] q          // Read data (32-bit aligned)
);

  localparam DEPTH = 2048;

  logic [7:0] tmem [0:DEPTH-1];

  // Simple 4-byte aligned access
  logic [10:0] base_addr;
  logic [7:0]  b0, b1, b2, b3;

  // Align to 4-byte boundary for reading
  assign base_addr = {address[10:2], 2'b00};

  always_ff @(posedge i_clk or negedge i_reset) begin
    if (~i_reset) begin
      tmem <= '{default:8'h00};
    end 
	 else begin
      // Write bytes based on byte enable
      if (wren[0]) tmem[base_addr]     <= data[7:0];
      if (wren[1]) tmem[base_addr + 1] <= data[15:8];
      if (wren[2]) tmem[base_addr + 2] <= data[23:16];
      if (wren[3]) tmem[base_addr + 3] <= data[31:24];
    end
  end

  always_comb begin
    // Always read 4 aligned bytes
    b0 = tmem[base_addr];
    b1 = tmem[base_addr + 1];
    b2 = tmem[base_addr + 2];
    b3 = tmem[base_addr + 3];
    
    q = {b3, b2, b1, b0};  // Return all 4 bytes
  end

endmodule
