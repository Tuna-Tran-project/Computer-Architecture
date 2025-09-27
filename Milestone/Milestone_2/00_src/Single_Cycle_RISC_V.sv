module Single_Cycle_RISC_V(
	input logic i_clk, i_rst,
	// IO input
	input  logic [31:0] i_io_sw,
	input  logic [3:0]  i_io_btn,
	// debug
	output logic [31:0] o_pc_debug,
   output logic        o_insn_vld,
	output logic br_equal, br_less,
	output logic [31:0] alu_data, rs1_data , rs2_data, imm_data, wb_data, ld_data,
	output logic [31:0] operand_a, operand_b, pc, instr,
	output logic opa_sel, opb_sel, mem_wren,
	output logic [3:0] alu_op,
	output logic [1:0] wb_sel,
	output logic [4:0] rs1_addr, rs2_addr,rd_addr,
	
	// IO output
	output logic [31:0] o_io_ledr,
	output logic [31:0] o_io_ledg,
	output logic [6:0]  o_io_hex0,
	output logic [6:0]  o_io_hex1,
	output logic [6:0]  o_io_hex2,
	output logic [6:0]  o_io_hex3,
	output logic [6:0]  o_io_hex4,
	output logic [6:0]  o_io_hex5,
	output logic [6:0]  o_io_hex6,
	output logic [6:0]  o_io_hex7,
	output logic [31:0] o_io_lcd
	);
/////////////////wires//////////////////
//PC wires//
	logic [31:0] 	pc_next, pc_four;
//	logic [31:0] 	instr;
	logic		  		pc_sel;
//reg file wires//
	//	logic [4:0]		rs1_addr, rs2_addr, rd_addr;
	//logic	[31:0] 	rs1_data , rs2_data;
	logic				rd_wren;
//imm_gen//
	//logic [31:0] imm_data;
//brc wires//
	logic br_un;
	//logic br_less;
	//br_equal;
//ALU///
	//logic [31:0] operand_a, operand_b;
	//alu_data;
//control signals//
/*	logic opa_sel, opb_sel;
	logic [3:0] alu_op;
	logic mem_wren;
	logic [1:0] wb_sel; */

//LSU 
	//logic [31:0] ld_data;
//wb
//	logic [31:0] wb_data;
/////////////Instantiate module/////////////
///PC///
assign pc_next = (pc_sel == 1'b0) ? pc_four : alu_data;
	PC program_counter(
		.i_clk(i_clk),
		.i_rst_n(i_rst),
		.i_pc_next(pc_next),
		.o_pc(pc)
	);
assign pc_four = pc + 32'd4;

i_mem instruction_mem (
	.i_addr(pc),
	.o_data(instr)
);
////reg file///
assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr	 = instr[11:7];
reg_file register (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_rs1_addr(rs1_addr),
	.i_rs2_addr(rs2_addr),
	.i_rd_addr(rd_addr),
	.i_rd_wren(rd_wren),
	.i_rd_data(wb_data),
	.o_rs1_data(rs1_data),
	.o_rs2_data(rs2_data)
);
///imm_gen//
imm_gen immediate(
	.i_instr(instr),
	.o_imm_out(imm_data)
);
///brc//
brc br(
	.i_rs1_data(rs1_data),
	.i_rs2_data(rs2_data),
	.i_br_un   (br_un),
	.o_br_less (br_less),
	.o_br_equal(br_equal)
);
assign operand_a = (opa_sel) ? pc : rs1_data; //mux operand_a
assign operand_b = (opb_sel) ? imm_data : rs2_data; //mux operand_b
///alu//
alu ALU(
	.i_operand_a(operand_a),
	.i_operand_b(operand_b),
	.i_alu_op(alu_op),
	.o_alu_data(alu_data)
);
//////////LSU////////
lsu lsu_inst (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_lsu_addr(alu_data),
	.i_st_data(rs2_data),
	.i_lsu_wren(mem_wren),
	.o_ld_data(ld_data),
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
	.o_io_lcd(o_io_lcd),
	.i_io_sw(i_io_sw),
	.i_io_btn(i_io_btn),
	.reg_write(rd_wren),   // Connect register write enable
	.reg_mem(reg_mem)      // Connect LSU output for register file
);
/////////wb/////////
assign wb_data = (wb_sel == 2'b00) ? alu_data : 
					  (wb_sel == 2'b01) ? ld_data :
					  (wb_sel == 2'b10) ? pc_four : 32'd0;
//////Control unit///////
control_unit control(
	.i_instr(instr),
	.i_br_less(br_less),
	.i_br_equal(br_equal),
	.o_br_un(br_un),
	.o_rd_wren(rd_wren),
	.o_mem_wren(mem_wren),
	.o_wb_sel(wb_sel),
	.o_pc_sel(pc_sel),
	.o_opa_sel(opa_sel),
	.o_opb_sel(opb_sel),
	.o_alu_op(alu_op)
);
always @(posedge i_clk or negedge i_rst) begin
	if(~i_rst) 
	o_pc_debug <= 32'd0;
	else
	o_pc_debug <= pc;
end

endmodule
