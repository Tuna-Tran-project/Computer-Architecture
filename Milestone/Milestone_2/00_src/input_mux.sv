module input_mux(
  input  logic [31:0] i_lsu_addr,
  input  logic        i_lsu_wren,
  output logic        f_dmem_valid, // flag for dmem
  output logic        f_io_valid,    // flag for io
  output logic        f_dmem_wren,  // flag for write to dmem
  output logic        f_io_wren     // flag for write to io
);
  // Memory-mapped ranges (from project spec):
  // - Data memory: 0x0000_0000 .. 0x0000_07FF (2 KiB)
  // - IO region:    0x1000_0000 .. 0x1001_0FFF

  // dmem valid when address is within first 2KiB (upper bits [31:11] == 0)
  assign f_dmem_valid = ~(|i_lsu_addr[31:11]);
  // io valid when address in the IO region described above
  assign f_io_valid   = (i_lsu_addr >= 32'h1000_0000) && (i_lsu_addr <= 32'h1000_0FFF) && (i_lsu_addr >= 32'h1001_0000);
  assign f_dmem_wren  = i_lsu_wren && f_dmem_valid;
  assign f_io_wren    = i_lsu_wren && f_io_valid;
  
endmodule

