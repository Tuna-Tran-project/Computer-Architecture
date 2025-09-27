module brc(
	input logic [31:0] i_rs1_data, i_rs2_data,
	input logic 		 i_br_un,
	output logic		 o_br_less, o_br_equal
);
logic [31:0] br_result;
logic br_cout;
FA_32bit sub_fa(.a(i_rs1_data), .b(~i_rs2_data), .cin(1'b1), .sum(br_result), .cout(br_cout));
always @(*) begin
	case(i_br_un)
		1'b0: begin//unsigned
		o_br_less = ~br_cout == 1'b0;
		o_br_equal= (br_result == 32'd0) ;
		end
		1'b1: begin//signed
		o_br_less = br_result[31]; // br_result = 1'b1 when rs1 < rs2	
		o_br_equal= (br_result == 32'd0);
		end
		default: begin
		o_br_less = 1'b0;
		o_br_equal = 1'b0;
		end
	endcase
end

endmodule
