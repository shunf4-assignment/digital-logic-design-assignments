`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 22:02:55
// Design Name: 
// Module Name: vga_tb
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


module vga_tb(

    );
    reg clk_100MHz = 0;
    wire hsync, vsync;
    wire [10:0] x;
    wire [9:0] y;
    wire inplace;
    wire clk_out;
    initial forever #5 clk_100MHz = ~clk_100MHz;
    
    vga uut(clk_100MHz, 0, clk_out, hsync, vsync, x, y, inplace);
endmodule
