`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 22:52:03
// Design Name: 
// Module Name: async_fifo
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


module async_fifo #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  wr_clk,
    input  wire                  rd_clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty
);

    // Internal pointers
    wire [ADDR_WIDTH:0] wr_bin, wr_gray, rd_gray_sync;
    wire [ADDR_WIDTH:0] rd_bin, rd_gray, wr_gray_sync;

    // Write Pointer Control
    wr_ptr_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) wr_ctrl (
        .clk(wr_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_gray_sync(rd_gray_sync),
        .wr_bin(wr_bin),
        .wr_gray(wr_gray),
        .full(full)
    );

    // Read Pointer Control
    rd_ptr_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) rd_ctrl (
        .clk(rd_clk),
        .rst(rst),
        .rd_en(rd_en),
        .wr_gray_sync(wr_gray_sync),
        .rd_bin(rd_bin),
        .rd_gray(rd_gray),
        .empty(empty)
    );

    // Synchronizers
    sync_gray #(.WIDTH(ADDR_WIDTH+1)) sync_w2r (
        .clk(rd_clk),
        .async_gray_in(wr_gray),
        .sync_gray_out(wr_gray_sync)
    );

    sync_gray #(.WIDTH(ADDR_WIDTH+1)) sync_r2w (
        .clk(wr_clk),
        .async_gray_in(rd_gray),
        .sync_gray_out(rd_gray_sync)
    );

    // Dual-port memory
    dual_port_memory #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mem (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .wr_en(wr_en & ~full),
        .rd_en(rd_en & ~empty),
        .wr_addr(wr_bin[ADDR_WIDTH-1:0]),
        .rd_addr(rd_bin[ADDR_WIDTH-1:0]),
        .din(din),
        .dout(dout)
    );

endmodule

