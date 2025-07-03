`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 22:23:15
// Design Name: 
// Module Name: rd_ptr_ctrl
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

module wr_ptr_ctrl #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire [ADDR_WIDTH:0]  rd_gray_sync,  // Synced read pointer in gray
    output reg  [ADDR_WIDTH:0]  wr_bin,
    output reg  [ADDR_WIDTH:0]  wr_gray,
    output wire                 full
);

    wire [ADDR_WIDTH:0] wr_bin_next;
    wire [ADDR_WIDTH:0] wr_gray_next;

    assign wr_bin_next  = wr_bin + (wr_en & ~full);
    assign wr_gray_next = wr_bin_next ^ (wr_bin_next >> 1);

    // Full flag logic: compare MSB wrapping
    assign full = (wr_gray_next == {~rd_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1], rd_gray_sync[ADDR_WIDTH-2:0]});

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_bin  <= 0;
            wr_gray <= 0;
        end else begin
            wr_bin  <= wr_bin_next;
            wr_gray <= wr_gray_next;
        end
    end

endmodule
