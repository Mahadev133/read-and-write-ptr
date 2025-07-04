`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 22:58:57
// Design Name: 
// Module Name: tb_async_fifo
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

module tb_async_fifo;

    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;
    localparam DEPTH = 1 << ADDR_WIDTH;

    reg wr_clk = 0, rd_clk = 0, rst = 1;
    reg wr_en = 0, rd_en = 0;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    // Clock generators
    always #5 wr_clk = ~wr_clk;  // 100MHz
    always #7 rd_clk = ~rd_clk;  // ~71MHz

    async_fifo #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) fifo_inst (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    integer i;

    initial begin
        $display("==== Start FIFO Test ====");
        #20 rst = 0;

        // 1️⃣ Normal Write and Read Test
        $display("\n[1] Write → Read Test");
        for (i = 0; i < DEPTH - 2; i = i + 1) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en = 1;
                din = i + 8'hA0;
                $display("Wrote: %h", din);
            end
        end
        @(posedge wr_clk) wr_en = 0;

        #40;
        for (i = 0; i < DEPTH - 2; i = i + 1) begin
            @(posedge rd_clk);
            if (!empty) begin
                rd_en = 1;
                $display("Read : %h", dout);
            end
        end
        @(posedge rd_clk) rd_en = 0;

        // 2️⃣ Full Prevention Test
        $display("\n[2] FIFO Full Prevention Test");
        for (i = 0; i < DEPTH + 4; i = i + 1) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en = 1;
                din = i + 8'hB0;
                $display("Wrote: %h", din);
            end else begin
                $display("Cannot write: FIFO is FULL");
                wr_en = 0;
            end
        end
        @(posedge wr_clk) wr_en = 0;

        // 3️⃣ Empty Prevention Test
        $display("\n[3] FIFO Empty Prevention Test");
        #50;
        for (i = 0; i < DEPTH + 4; i = i + 1) begin
            @(posedge rd_clk);
            if (!empty) begin
                rd_en = 1;
                $display("Read : %h", dout);
            end else begin
                $display("Cannot read: FIFO is EMPTY");
                rd_en = 0;
            end
        end
        @(posedge rd_clk) rd_en = 0;

        #100;
        $display("\n==== Test Completed ====");
        $finish;
    end

endmodule
