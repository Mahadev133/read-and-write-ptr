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

module sync_gray #(
    parameter WIDTH = 5
)(
    input  wire clk,
    input  wire [WIDTH-1:0] async_gray_in,
    output reg  [WIDTH-1:0] sync_gray_out
);

    reg [WIDTH-1:0] sync_ff1;

    always @(posedge clk) begin
        sync_ff1       <= async_gray_in;
        sync_gray_out  <= sync_ff1;
    end

endmodule
