module PC(
    input        i_clk,
    input        i_rst_n,
    input  [31:0] i_pc_next,
    output logic [31:0] o_pc
);
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            o_pc <= 32'd0;
        end
        else begin
            o_pc <= i_pc_next;
        end
    end
endmodule