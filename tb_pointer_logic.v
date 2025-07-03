`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 22:25:52
// Design Name: 
// Module Name: tb_pointer_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module tb_pointer_logic;

    parameter ADDR_WIDTH = 4;
    reg wr_clk = 0, rd_clk = 0, rst = 1;
    reg wr_en = 0, rd_en = 0;

    wire full, empty;
    wire [ADDR_WIDTH:0] wr_gray, rd_gray;
    wire [ADDR_WIDTH:0] wr_bin, rd_bin;
    wire [ADDR_WIDTH:0] wr_gray_sync, rd_gray_sync;

    // Clock generation
    always #5 wr_clk = ~wr_clk;
    always #7 rd_clk = ~rd_clk;

    // Instantiate write pointer logic
    wr_ptr_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) wr_ctrl (
        .clk(wr_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_gray_sync(rd_gray_sync),
        .wr_bin(wr_bin),
        .wr_gray(wr_gray),
        .full(full)
    );

    // Instantiate read pointer logic
    rd_ptr_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) rd_ctrl (
        .clk(rd_clk),
        .rst(rst),
        .rd_en(rd_en),
        .wr_gray_sync(wr_gray_sync),
        .rd_bin(rd_bin),
        .rd_gray(rd_gray),
        .empty(empty)
    );

    // Synchronizer: write pointer into read clock domain
    sync_gray #(.WIDTH(ADDR_WIDTH+1)) sync_w2r (
        .clk(rd_clk),
        .async_gray_in(wr_gray),
        .sync_gray_out(wr_gray_sync)
    );

    // Synchronizer: read pointer into write clock domain
    sync_gray #(.WIDTH(ADDR_WIDTH+1)) sync_r2w (
        .clk(wr_clk),
        .async_gray_in(rd_gray),
        .sync_gray_out(rd_gray_sync)
    );

    integer i;

    initial begin
        $display("Start simulation...");
        
        wr_en = 0;
        rd_en = 0;

        repeat (3) @(posedge wr_clk);
        rst = 0;  // Deassert reset on a clock edge

        // Write to FIFO
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge wr_clk);
            wr_en = 1;
            $display("WRITE: bin=%0d, gray=%b, full=%b", wr_bin, wr_gray, full);
        end
        @(posedge wr_clk); wr_en = 0;

        // Read from FIFO
        #40;
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge rd_clk);
            rd_en = 1;
            $display("READ : bin=%0d, gray=%b, empty=%b", rd_bin, rd_gray, empty);
        end
        @(posedge rd_clk); rd_en = 0;

        #100;
        $finish;
    end

endmodule


