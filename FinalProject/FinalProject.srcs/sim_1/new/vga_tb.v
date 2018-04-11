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
    wire [10:0] h_cnt;
    wire [9:0] v_cnt;
    wire rgbvalid;
    wire clk_65M;
    initial forever #5 clk_100MHz = ~clk_100MHz;
    
    vga uut(clk_100MHz, 1, h_cnt, v_cnt, hsync, vsync, rgbvalid, clk_65M);
endmodule
