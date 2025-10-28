module input_buffer(
  // System global input
  input  logic        i_clk,
  input  logic        i_reset,
  
  // IO input
  input  logic [31:0] i_io_sw,
  // IO buffer
  output logic [31:0] b_io_sw
);
  
  always_ff @(posedge i_clk or negedge i_reset)
  begin
    if (!i_reset) begin
      b_io_sw  <= 'd0;
    end else begin
      b_io_sw  <= i_io_sw;
    end
  end
  
endmodule