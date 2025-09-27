module alu(
    input  logic [31:0] i_operand_a, i_operand_b,
    input  logic [3:0] i_alu_op,
    output logic [31:0] o_alu_data
);
//encoding the alu_op
	localparam ADD  = 4'd0;
	localparam SUB  = 4'd1;
	localparam SLL  = 4'd2;
	localparam SLT  = 4'd3;
	localparam SLTU = 4'd4;
	localparam XOR  = 4'd5;
	localparam SRL  = 4'd6;
	localparam SRA  = 4'd7;
	localparam OR   = 4'd8;
	localparam AND  = 4'd9;

//signals
    logic [31:0] add_result, sub_result;
    logic        slt_result, sltu_result;
    logic [31:0] and_result, or_result, xor_result;
    logic [31:0] sll_result, srl_result, sra_result;
    logic [31:0] slt_sum;
    logic        slt_cout, sltu_cout;

//OPERATIONS:
//ADD
    FA_32bit add_fa(.a(i_operand_a), .b(i_operand_b), .cin(1'b0), .sum(add_result), .cout());

//SUB  
    FA_32bit sub_fa(.a(i_operand_a), .b(~i_operand_b), .cin(1'b1), .sum(sub_result), .cout());

//SLT (signed comparison)
    FA_32bit slt_fa(.a(i_operand_a), .b(~i_operand_b), .cin(1'b1), .sum(slt_sum), .cout(slt_cout));
    assign slt_result = slt_sum[31]; // Check sign bit for signed comparison

//SLTU (unsigned comparison) 
    FA_32bit sltu_fa(.a(i_operand_a), .b(~i_operand_b), .cin(1'b1), .sum(), .cout(sltu_cout));
    assign sltu_result = ~sltu_cout; // No borrow means a >= b, so a < b when cout = 0

//Logic operations
    assign and_result = i_operand_a & i_operand_b;
    assign or_result = i_operand_a | i_operand_b;
    assign xor_result = i_operand_a ^ i_operand_b;

//Shift operations
    SLL sll_inst(.tmp(i_operand_b[4:0]), .A(i_operand_a), .Sll_out(sll_result));
    SRL srl_inst(.tmp(i_operand_b[4:0]), .A(i_operand_a), .Srl_out(srl_result));
    SRA sra_inst(.tmp(i_operand_b[4:0]), .A(i_operand_a), .Sra_out(sra_result));

// Output selection
always_comb begin
    case(i_alu_op)
        ADD:  o_alu_data = add_result;
        SUB:  o_alu_data = sub_result;
        SLT:  o_alu_data = {31'b0, slt_result};
        SLTU: o_alu_data = {31'b0, sltu_result};
        XOR:  o_alu_data = xor_result;
        OR:   o_alu_data = or_result;
        AND:  o_alu_data = and_result;
        SLL:  o_alu_data = sll_result;
        SRL:  o_alu_data = srl_result;
        SRA:  o_alu_data = sra_result;
        default: o_alu_data = 32'b0;
    endcase
end

endmodule

///////////////////////////// CORRECTED SHIFT MODULES //////////////////////////////////////
module SLL(
    input [4:0] tmp,
    input [31:0] A,
    output [31:0] Sll_out
);
    logic [31:0] temp_0, temp_1, temp_2, temp_3, temp_4;
    assign temp_0 = (tmp[0] == 1'b1) ? {A[30:0], 1'b0} : A;
    assign temp_1 = (tmp[1] == 1'b1) ? {temp_0[29:0], 2'b0} : temp_0;
    assign temp_2 = (tmp[2] == 1'b1) ? {temp_1[27:0], 4'b0} : temp_1;
    assign temp_3 = (tmp[3] == 1'b1) ? {temp_2[23:0], 8'b0} : temp_2;
    assign temp_4 = (tmp[4] == 1'b1) ? {temp_3[15:0], 16'b0} : temp_3;
    assign Sll_out = temp_4;
endmodule

module SRL(
    input [4:0] tmp,
    input [31:0] A,
    output [31:0] Srl_out
);
    logic [31:0] temp_0, temp_1, temp_2, temp_3, temp_4;
    assign temp_0 = (tmp[0] == 1'b1) ? {1'b0, A[31:1]} : A;
    assign temp_1 = (tmp[1] == 1'b1) ? {2'b0, temp_0[31:2]} : temp_0;
    assign temp_2 = (tmp[2] == 1'b1) ? {4'b0, temp_1[31:4]} : temp_1;
    assign temp_3 = (tmp[3] == 1'b1) ? {8'b0, temp_2[31:8]} : temp_2;
    assign temp_4 = (tmp[4] == 1'b1) ? {16'b0, temp_3[31:16]} : temp_3;
    assign Srl_out = temp_4;
endmodule

module SRA(
    input [4:0] tmp,
    input [31:0] A,
    output [31:0] Sra_out
);
    logic [31:0] temp_0, temp_1, temp_2, temp_3, temp_4;
    assign temp_0 = (tmp[0] == 1'b1) ? {A[31], A[31:1]} : A;
    assign temp_1 = (tmp[1] == 1'b1) ? {{2{A[31]}}, temp_0[31:2]} : temp_0;
    assign temp_2 = (tmp[2] == 1'b1) ? {{4{A[31]}}, temp_1[31:4]} : temp_1;
    assign temp_3 = (tmp[3] == 1'b1) ? {{8{A[31]}}, temp_2[31:8]} : temp_2;
    assign temp_4 = (tmp[4] == 1'b1) ? {{16{A[31]}}, temp_3[31:16]} : temp_3;
    assign Sra_out = temp_4;
endmodule