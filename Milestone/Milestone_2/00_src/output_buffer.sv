module output_buffer(
	input logic        i_clk,
	input logic        i_reset,
	//data input
	input logic [31:0] i_st_data,
	input logic [31:0] i_io_addr,
	input logic [2:0]  i_funct3,
	input 		   f_io_wren,
   //IO output
	output logic [31:0] b_io_ledr,
	output logic [31:0] b_io_ledg,
	output logic [31:0] b_io_hexl,
	output logic [31:0] b_io_hexh,
	output logic [31:0] b_io_lcd
);
	logic [31:0] write_mask;
	logic [31:0] write_data;
	logic [1:0]  addr_offset;

	always @(*) begin
		case (i_funct3)
			3'b000: begin // SB
				case (addr_offset)
					2'b00: begin
						write_mask = 32'h0000_00FF;
						write_data = {24'h000000, i_st_data[7:0]};
					end
					2'b01: begin
						write_mask = 32'h0000_FF00;
						write_data = {16'h0000, i_st_data[7:0], 8'h00};
					end
					2'b10: begin
						write_mask = 32'h00FF_0000;
						write_data = {8'h00, i_st_data[7:0], 16'h0000};
					end
					2'b11: begin
						write_mask = 32'hFF00_0000;
						write_data = {i_st_data[7:0], 24'h000000};
					end
				endcase
			end
			3'b001: begin // SH
				if (addr_offset[1] == 1'b0) begin
					write_mask = 32'h0000_FFFF;
					write_data = {16'h0000, i_st_data[15:0]};
				end else begin
					write_mask = 32'hFFFF_0000;
					write_data = {i_st_data[15:0], 16'h0000};
				end
			end
			3'b010: begin // SW
				write_mask = 32'hFFFF_FFFF;
				write_data = i_st_data;
			end
			default: begin
				write_mask   = 32'h0000_0000;
				write_data   = 32'h0000_0000;
				addr_offset  = i_io_addr[1:0];
			end
		endcase
	end

	// Full 32-bit IO addresses inside region 0x1000_0000 .. 0x1001_0FFF
	// combinational next-state for IO outputs
	logic [31:0] next_b_io_ledr, next_b_io_ledg, next_b_io_hexl, next_b_io_hexh, next_b_io_lcd;

	always_comb begin
		// default: hold current values
		next_b_io_ledr = b_io_ledr;
		next_b_io_ledg = b_io_ledg;
		next_b_io_hexl = b_io_hexl;
		next_b_io_hexh = b_io_hexh;
		next_b_io_lcd  = b_io_lcd;

		if (f_io_wren == 1'b1) begin
			case (i_io_addr[31:12])
				32'h1000_0: if (write_mask != 32'h0000_0000) next_b_io_ledr = (b_io_ledr & ~write_mask) | (write_data & write_mask); // Red LEDs
				32'h1000_1: if (write_mask != 32'h0000_0000) next_b_io_ledg = (b_io_ledg & ~write_mask) | (write_data & write_mask); // Green LEDs
				32'h1000_2: if (write_mask != 32'h0000_0000) next_b_io_hexl = (b_io_hexl & ~write_mask) | (write_data & write_mask); // Seven-seg 3-0
				32'h1000_3: if (write_mask != 32'h0000_0000) next_b_io_hexh = (b_io_hexh & ~write_mask) | (write_data & write_mask); // Seven-seg 7-4
				32'h1000_4: if (write_mask != 32'h0000_0000) next_b_io_lcd  = (b_io_lcd  & ~write_mask) | (write_data & write_mask); // LCD control
				default: ; // no change
			endcase
		end
	end

	// flip-flops: register the next-state on clock / async reset
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (~i_reset) begin
			b_io_ledr <= 32'b0;
			b_io_ledg <= 32'b0;
			b_io_hexl <= 32'b0;
			b_io_hexh <= 32'b0;
			b_io_lcd  <= 32'b0;
		end else begin
			b_io_ledr <= next_b_io_ledr;
			b_io_ledg <= next_b_io_ledg;
			b_io_hexl <= next_b_io_hexl;
			b_io_hexh <= next_b_io_hexh;
			b_io_lcd  <= next_b_io_lcd;
		end
	end
endmodule
	
