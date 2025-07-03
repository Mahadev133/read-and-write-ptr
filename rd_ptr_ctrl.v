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


module rd_ptr_ctrl #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH:0]  wr_gray_sync, // Synced write pointer in gray
    output reg  [ADDR_WIDTH:0]  rd_bin,
    output reg  [ADDR_WIDTH:0]  rd_gray,
    output wire                 empty
);

    wire [ADDR_WIDTH:0] rd_bin_next;
    wire [ADDR_WIDTH:0] rd_gray_next;

    assign rd_bin_next  = rd_bin + (rd_en & ~empty);
    assign rd_gray_next = rd_bin_next ^ (rd_bin_next >> 1);

    assign empty = (rd_gray == wr_gray_sync);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_bin  <= 0;
            rd_gray <= 0;
        end else begin
            rd_bin  <= rd_bin_next;
            rd_gray <= rd_gray_next;
        end
    end

endmodule
