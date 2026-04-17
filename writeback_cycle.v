module writeback_cycle (
    input wire [1:0] result_src_w,
    input wire [31:0] alu_result_w, read_data_w, pc_plus_4_w,
    output  [31:0] result_w
);
    // Result source MUX
    // 00: ALU result
    // 01: Memory read data
    // 10: PC + 4 (for JAL/JALR)
    mux_3_1 result_mux (
        .a(alu_result_w),
        .b(read_data_w),
        .c(pc_plus_4_w),
        .s(result_src_w),
        .d(result_w)
    );
    
endmodule