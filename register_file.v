module register_file (
    input wire clk, rst, write_en_3,
    input wire [4:0] addr_1, addr_2, addr_3,
    input wire [31:0] write_data_3,
    output  [31:0] read_data_1, read_data_2
);

    reg [31:0] register [31:0];
    integer i;

    // Initialize ALL registers to zero
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            register[i] = 32'h00000000;
        end
    end

    // CRITICAL FIX: Internal bypassing for same-cycle read-after-write
    // If we're writing to a register that's being read, bypass the write data
    assign read_data_1 = (rst == 1'b0) ? 32'd0 : 
                         ((write_en_3 && (addr_1 == addr_3) && (addr_1 != 5'h00)) ? write_data_3 : register[addr_1]);
    
    assign read_data_2 = (rst == 1'b0) ? 32'd0 : 
                         ((write_en_3 && (addr_2 == addr_3) && (addr_2 != 5'h00)) ? write_data_3 : register[addr_2]);

    // Write on positive edge
    always @ (posedge clk) begin
        if (write_en_3 & (addr_3 != 5'h00)) begin
            register[addr_3] <= write_data_3; 
        end    
    end

endmodule

`timescale 1ns / 1ps

module tb_register_file;

    // Khai báo tín hiệu
    reg clk;
    reg rst;
    reg write_en_3;
    reg [4:0] addr_1;
    reg [4:0] addr_2;
    reg [4:0] addr_3;
    reg [31:0] write_data_3;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // Khởi tạo module register_file (DUT)
    register_file uut (
        .clk(clk), 
        .rst(rst), 
        .write_en_3(write_en_3), 
        .addr_1(addr_1), 
        .addr_2(addr_2), 
        .addr_3(addr_3), 
        .write_data_3(write_data_3), 
        .read_data_1(read_data_1), 
        .read_data_2(read_data_2)
    );

    // Tạo xung clock (chu kỳ 10ns)
    always #5 clk = ~clk;

    initial begin
        // 1. Khởi tạo giá trị ban đầu
        clk = 0;
        rst = 0; // Reset active low (dựa trên dòng 4 của code gốc)
        write_en_3 = 0;
        addr_1 = 0; addr_2 = 0; addr_3 = 0;
        write_data_3 = 0;

        // Bật màn hình theo dõi
        $display("Time | Rst | W_En | W_Addr | W_Data   | R_Addr1 | R_Data1  | R_Addr2 | R_Data2");
        $display("-----------------------------------------------------------------------------");
        
        // 2. Thả Reset
        #10 rst = 1;

        // 3. TEST 1: Ghi và Đọc cơ bản (Write Read-After-Write)
        // Ghi 100 vào Reg 1, Ghi 200 vào Reg 2
        #10 write_en_3 = 1; addr_3 = 5'd1; write_data_3 = 32'd100;
        #10 addr_3 = 5'd2; write_data_3 = 32'd200;
        
        // Dừng ghi và đọc lại Reg 1 và Reg 2
        #10 write_en_3 = 0; addr_3 = 0; 
            addr_1 = 5'd1; addr_2 = 5'd2;

        // 4. TEST 2: Kiểm tra Thanh ghi 0 (Hardwired Zero)
        // Cố gắng ghi 999 vào Reg 0
        #10 write_en_3 = 1; addr_3 = 5'd0; write_data_3 = 32'd999;
        // Đọc lại Reg 0 tại cổng 1
        #10 write_en_3 = 0; addr_1 = 5'd0;

        // 5. TEST 3: Kiểm tra Bypassing (Quan trọng)
        // Ghi 555 vào Reg 3 VÀ đọc Reg 3 cùng lúc
        #10 write_en_3 = 1; 
            addr_3 = 5'd3; write_data_3 = 32'd555;
            addr_1 = 5'd3; // Đọc cùng địa chỉ đang ghi
            addr_2 = 5'd1; // Cổng 2 đọc Reg 1 cũ

        // 6. TEST 4: Kiểm tra Reset Output
        // Đang có dữ liệu đầu ra, kéo Reset xuống thấp
        #10 write_en_3 = 0; rst = 0;

        // Kết thúc mô phỏng
        #20 $finish;
    end

    // Monitor để in kết quả tự động khi tín hiệu thay đổi
    initial begin
        $monitor("%4t |  %b  |  %b   |   %2d   | %8h |   %2d    | %8h |   %2d    | %8h", 
                 $time, rst, write_en_3, addr_3, write_data_3, addr_1, read_data_1, addr_2, read_data_2);
    end

endmodule