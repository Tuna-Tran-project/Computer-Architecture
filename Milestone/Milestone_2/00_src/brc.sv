module brc(
	input  logic [31:0] i_rs1_data,
	input  logic [31:0] i_rs2_data,
	input  logic        i_br_un,
	output logic        o_br_less,
	output logic        o_br_equal
);

	logic eq_high, lt_high, gt_high;
	logic eq_low,  lt_low,  gt_low;
	wire  eq_mag;
	wire  lt_mag;

	always @(*) begin
		o_br_equal = eq_mag;
		if (i_br_un) begin
			if (i_rs1_data[31] != i_rs2_data[31]) begin
				o_br_less = (i_rs1_data[31] == 1'b1);
			end else begin
				o_br_less = lt_mag;
			end
		end else begin
			o_br_less = lt_mag;
		end
	end

	assign eq_mag = eq_high & eq_low;
	assign lt_mag = (eq_high & lt_low) | lt_high;

	comparator_16bit com16bit_high (
		.i_src_a(i_rs1_data[31:16]),
		.i_src_b(i_rs2_data[31:16]),
		.o_eq(eq_high),
		.o_lt(lt_high),
		.o_gt(gt_high)
	);

	comparator_16bit com16bit_low (
		.i_src_a(i_rs1_data[15:0]),
		.i_src_b(i_rs2_data[15:0]),
		.o_eq(eq_low),
		.o_lt(lt_low),
		.o_gt(gt_low)
	);

endmodule 

// ==================================================
//		1 bit
// ==================================================
module comparator_1bit
(
  input  logic	i_src_a, 
  input  logic	i_src_b,
  output logic	o_eq, 
  output logic	o_lt, 
  output logic	o_gt
);

assign o_eq = ~(i_src_a ^ i_src_b);
assign o_lt = ~ i_src_a & i_src_b;
assign o_gt = ~(o_eq | o_lt);

endmodule 

// ==================================================
// 	2 bit
// ==================================================

module comparator_2bit
(
  input  logic [1:0] i_src_a, 
  input  logic [1:0] i_src_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_1bit	com4bit_high	(.i_src_a(i_src_a[1]), .i_src_b(i_src_b[1]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_1bit	com4bit_low		(.i_src_a(i_src_a[0]), .i_src_b(i_src_b[0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		4 bit
// ==================================================

module comparator_4bit
(
  input  logic [3:0] i_src_a, 
  input  logic [3:0] i_src_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_2bit	com2bit_high	(.i_src_a(i_src_a[3:2]), .i_src_b(i_src_b[3:2]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_2bit	com2bit_low		(.i_src_a(i_src_a[1:0]), .i_src_b(i_src_b[1:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		8 bit
// ==================================================

module comparator_8bit
(
  input  logic [7:0] i_src_a, 
  input  logic [7:0] i_src_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_4bit	com4bit_high	(.i_src_a(i_src_a[7:4]), .i_src_b(i_src_b[7:4]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_4bit	com4bit_low		(.i_src_a(i_src_a[3:0]), .i_src_b(i_src_b[3:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		16 bit
// ==================================================

module comparator_16bit
(
  input  logic [15:0] i_src_a, 
  input  logic [15:0] i_src_b,
  output logic        o_eq, 
  output logic        o_lt, 
  output logic        o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_8bit	com8bit_high	(.i_src_a(i_src_a[15:8]), .i_src_b(i_src_b[15:8]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_8bit	com8bit_low		(.i_src_a(i_src_a[ 7:0]), .i_src_b(i_src_b[ 7:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule 
