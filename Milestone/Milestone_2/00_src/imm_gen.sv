module imm_gen(
    input  logic [31:0] i_instr,
    output logic [31:0] o_imm_out
);

    logic [31:0] imm_i, imm_s, imm_b, imm_j;
    logic [31:0] u_imm;
    // I-type
    sign_extend #(.IN_WIDTH(12), .OUT_WIDTH(32)) ext_i (
        .in(i_instr[31:20]),
        .out(imm_i)
    );
    // S-type
    sign_extend #(.IN_WIDTH(12), .OUT_WIDTH(32)) ext_s (
        .in({i_instr[31:25], i_instr[11:7]}),
        .out(imm_s)
    );
    // B-type
    sign_extend #(.IN_WIDTH(13), .OUT_WIDTH(32)) ext_b (
        .in({i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0}),
        .out(imm_b)
    );
    // J-type
    sign_extend #(.IN_WIDTH(21), .OUT_WIDTH(32)) ext_j (
        .in({i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0}),
        .out(imm_j)
    );
    // U-type (upper 20 bits shifted left by 12 bits)
    assign u_imm = {i_instr[31:12], 12'b0};

    always_comb begin
        case (i_instr[6:0])
            7'b0010011, 7'b0000011, 7'b1100111: // I-type
                o_imm_out = imm_i;
            7'b0100011: // S-type
                o_imm_out = imm_s;
            7'b1100011: // B-type
                o_imm_out = imm_b;
            7'b0110111, 7'b0010111: // U-type
                o_imm_out = u_imm;
            7'b1101111: // J-type
                o_imm_out = imm_j;
            default:
                o_imm_out = 32'b0;
        endcase
    end
endmodule

module sign_extend #(
    parameter IN_WIDTH = 12,
    parameter OUT_WIDTH = 32
)(
    input  logic [IN_WIDTH-1:0]  in,
    output logic [OUT_WIDTH-1:0] out
);
    assign out = {{(OUT_WIDTH-IN_WIDTH){in[IN_WIDTH-1]}}, in};
endmodule