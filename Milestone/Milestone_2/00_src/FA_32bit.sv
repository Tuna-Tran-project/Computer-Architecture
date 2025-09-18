module FA_1bit(
	input a, b,cin,
	output sum,cout
);
assign sum = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);
endmodule 

module FA_4bit(
	input [3:0] a, b,
	input cin,
	output [3:0] sum,
	output cout
);
logic [2:0] carry;

 FA_1bit fa0 (.a(a[0]), .b(b[0]), .cin(cin),      .sum(sum[0]), .cout(carry[0]));
 FA_1bit fa1 (.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
 FA_1bit fa2 (.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
 FA_1bit fa3 (.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(sum[3]), .cout(cout));
endmodule

module FA_32bit(
	input [31:0] a, b,
	input cin,
	output [31:0] sum,
	output cout
);
	logic [6:0] carry;
 FA_4bit fa0 (.a(a[3:0]),   .b(b[3:0]),   .cin(cin),      .sum(sum[3:0]),   .cout(carry[0]));
 FA_4bit fa1 (.a(a[7:4]),   .b(b[7:4]),   .cin(carry[0]), .sum(sum[7:4]),   .cout(carry[1]));
 FA_4bit fa2 (.a(a[11:8]),  .b(b[11:8]),  .cin(carry[1]), .sum(sum[11:8]),  .cout(carry[2]));
 FA_4bit fa3 (.a(a[15:12]), .b(b[15:12]), .cin(carry[2]), .sum(sum[15:12]), .cout(carry[3]));
 FA_1bit fa4 (.a(a[19:16]), .b(b[19:16]), .cin(carry[3]), .sum(sum[19:16]), .cout(carry[4]));
 FA_1bit fa5 (.a(a[23:20]), .b(b[23:20]), .cin(carry[4]), .sum(sum[23:20]), .cout(carry[5]));
 FA_1bit fa6 (.a(a[27:24]), .b(b[27:24]), .cin(carry[5]), .sum(sum[27:24]), .cout(carry[6]));
 FA_1bit fa7 (.a(a[31:28]), .b(b[31:28]), .cin(carry[6]), .sum(sum[31:28]), .cout(cout));
endmodule
