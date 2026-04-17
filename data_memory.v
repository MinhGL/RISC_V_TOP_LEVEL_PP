module data_memory (
    input wire clk, rst, write_en,
    input wire [31:0] addr, write_data,
    output  [31:0] read_data 
);
    reg [31:0] mem [1023:0];
    integer i;

    // Initialize ALL memory locations to zero
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end

    assign read_data = (~rst) ? 32'd0 : mem[addr[31:2]];
    
    always @ (posedge clk) begin
        if(write_en) begin
            mem[addr[31:2]] <= write_data;
        end
    end

endmodule