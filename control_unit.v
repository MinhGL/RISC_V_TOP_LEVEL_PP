module control_unit(
    input  [6:0] op, funct7,
    input  [2:0] funct3,
    output  reg_write, mem_write, alu_src, jump, branch, jalr,
    output  [1:0] result_src, imm_src, 
    output  [3:0] alu_control
);
    wire [1:0] alu_op;
    // Generate synthetic funct3 for LUI and AUIPC to distinguish them
    wire [2:0] funct3_modified;
    
    // For LUI (0110111), use funct3=001
    // For AUIPC (0010111), use funct3=000
    assign funct3_modified = (op == 7'b0110111) ? 3'b001 :  // LUI
                            (op == 7'b0010111) ? 3'b000 :  // AUIPC
                            funct3;                         // Normal instructions

    main_decoder main_decoder(
        .op(op),
        .result_src(result_src),
        .imm_src(imm_src),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump),
        .branch(branch),
        .jalr(jalr)
    );

    alu_decoder alu_decoder(
        .alu_op(alu_op),
        .funct3(funct3_modified),
        .funct7(funct7),
        .op(op),
        .alu_control(alu_control)
    );
endmodule