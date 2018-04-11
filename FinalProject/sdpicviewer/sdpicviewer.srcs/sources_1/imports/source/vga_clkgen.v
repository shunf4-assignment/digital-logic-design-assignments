`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 19:46:05
// Design Name: 
// Module Name: vga_clkgen
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


module vga_clkgen(
    input clk_100M,
    input rst_n,
    output clk
    );
    clk_wiz_0 clkgen(
        clk_100M,
        clk,
        ~rst_n,
        null
    );
endmodule
