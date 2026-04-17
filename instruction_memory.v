module instruction_memory (
    input  rst,
    input  [31:0] addr,
    output  [31:0] read_data
);

    reg [31:0] mem [1023:0];
    integer i;

    initial begin
        // Initialize ALL memory to zero first
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
        
        // Load from file
        $readmemh("memfile.hex", mem);
        
        
    end

    assign read_data = (rst == 1'b0) ? 32'h00000000 : mem[addr[31:2]];

endmodule