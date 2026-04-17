module mux (
    input  [31:0] a, b,
    input  s,
    output  [31:0] c
);
    assign c = s ? b : a;
endmodule

module mux_3_1 (
    input  [31:0] a, b, c,
    input  [1:0] s,
    output  [31:0] d 
);
    // s = 00: select a
    // s = 01: select b
    // s = 10: select c
    assign d = (s == 2'b00) ? a : 
               (s == 2'b01) ? b : 
               (s == 2'b10) ? c : 
               32'h00000000;
endmodule