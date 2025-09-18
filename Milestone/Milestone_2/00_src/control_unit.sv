module control_unit (
    input  logic [31:0] i_instr,
    output logic        o_rd_wren,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,
    output logic        o_pc_sel,
    output logic        o_opa_sel,
    output logic        o_opb_sel,
    output logic [3:0]  o_alu_op
);

    // Extract opcode, funct3, funct7 from instruction
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = i_instr[6:0];
    assign funct3 = i_instr[14:12];
    assign funct7 = i_instr[31:25];

    // Main Decoder instance
    MainDecoder main_dec (
        .opcode(opcode),
        .rd_wren(o_rd_wren),
        .mem_wren(o_mem_wren),
        .wb_sel(o_wb_sel),
        .pc_sel(o_pc_sel),
        .opa_sel(o_opa_sel),
        .opb_sel(o_opb_sel)
    );

    // ALU Decoder instance
    ALUDecoder alu_dec (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(o_alu_op)
    );
endmodule

////////////////Main-decoder/////////////////
module MainDecoder (
    input  logic [6:0] opcode,
    output logic       rd_wren,
    output logic       mem_wren,
    output logic [1:0] wb_sel,
    output logic       pc_sel,
    output logic       opa_sel,
    output logic       opb_sel
);
always_comb begin
	  case (opcode)
			7'b0110011: begin // R-type ALU
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b00; // ALU result
				 pc_sel   = 0;
				 opa_sel  = 0;     // rs1
				 opb_sel  = 0;     // rs2
			end
			7'b0010011: begin // I-type ALU (ADDI, etc.)
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b00; // ALU result
				 pc_sel   = 0;
				 opa_sel  = 0;     // rs1
				 opb_sel  = 1;     // imm
			end
			7'b0000011: begin // LOAD
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b01; // Mem result
				 pc_sel   = 0;
				 opa_sel  = 0;     // rs1
				 opb_sel  = 1;     // imm
			end
			7'b0100011: begin // STORE
				 rd_wren  = 0;
				 mem_wren = 1;
				 wb_sel   = 2'b00;
				 pc_sel   = 0;
				 opa_sel  = 0;     // rs1
				 opb_sel  = 1;     // imm
			end
			7'b1100011: begin // BRANCH
				 rd_wren  = 0;
				 mem_wren = 0;
				 wb_sel   = 2'b00;
				 pc_sel   = 1;     // branch target
				 opa_sel  = 0;     // rs1
				 opb_sel  = 0;     // rs2
			end
			7'b1101111: begin // JAL
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b10; // PC+4
				 pc_sel   = 1;     // jump target
				 opa_sel  = 1;     // PC
				 opb_sel  = 1;     // imm
			end
			7'b1100111: begin // JALR
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b10; // PC+4
				 pc_sel   = 1;     // jump target
				 opa_sel  = 0;     // rs1
				 opb_sel  = 1;     // imm
			end
			7'b0110111: begin // LUI
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b00; // ALU result
				 pc_sel   = 0;
				 opa_sel  = 2;     // zero (custom for LUI)
				 opb_sel  = 1;     // imm
			end
			7'b0010111: begin // AUIPC
				 rd_wren  = 1;
				 mem_wren = 0;
				 wb_sel   = 2'b00; // ALU result
				 pc_sel   = 0;
				 opa_sel  = 1;     // PC
				 opb_sel  = 1;     // imm
			end
			default: begin
				  rd_wren  = 0;
				  mem_wren = 0;
				  wb_sel   = 2'b00;
				  pc_sel   = 0;
				  opa_sel  = 0;
				  opb_sel  = 0;
			end
	  endcase
 end
endmodule
///////ALU
module ALUDecoder (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_op
);

    always_comb begin
        alu_op = 4'b1111; // NOP/invalid by default

        if (opcode == 7'b0110011) begin // R-type
            case (funct3)
                3'b000: alu_op = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB : ADD
                3'b001: alu_op = 4'b0010; // SLL
                3'b010: alu_op = 4'b0011; // SLT
                3'b011: alu_op = 4'b0100; // SLTU
                3'b100: alu_op = 4'b0101; // XOR
                3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA : SRL
                3'b110: alu_op = 4'b1000; // OR
                3'b111: alu_op = 4'b1001; // AND
                default: alu_op = 4'b1111;
            endcase
        end else if (opcode == 7'b0010011) begin // I-type ALU
            case (funct3)
                3'b000: alu_op = 4'b0000; // ADDI
                3'b010: alu_op = 4'b0011; // SLTI
                3'b011: alu_op = 4'b0100; // SLTIU
                3'b100: alu_op = 4'b0101; // XORI
                3'b110: alu_op = 4'b1000; // ORI
                3'b111: alu_op = 4'b1001; // ANDI
                3'b001: alu_op = 4'b0010; // SLLI
                3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRAI : SRLI
                default: alu_op = 4'b1111;
            endcase
        end else if (opcode == 7'b1100011) begin // Branch
            alu_op = 4'b0001; // Use SUB for comparison
        end else if (opcode == 7'b0110111) begin // LUI
            alu_op = 4'b1010; // LUI (custom ALU op)
        end else if (opcode == 7'b0010111) begin // AUIPC
            alu_op = 4'b0000; // ADD
        end else begin
            alu_op = 4'b1111;
        end
    end
endmodule