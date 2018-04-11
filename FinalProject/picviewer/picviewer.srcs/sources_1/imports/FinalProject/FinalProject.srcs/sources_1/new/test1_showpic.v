`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/11 18:01:59
// Design Name: 
// Module Name: test1_showpic
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


module test1_showpic(
    input CLK100MHZ,
    input SW0,      //display_ena
    input SW1,      //movement_ena
    input BTNU,     //reset
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    );
    wire [10:0] h_cnt;
    wire [9:0] v_cnt;
    wire inplace;
    wire vga_clk;
    
    vga vga_ctrl(
        CLK100MHZ,
        BTNU,
        vga_clk,
        VGA_HS,
        VGA_VS,
        h_cnt,
        v_cnt,
        inplace
    );
    
    test_img_control imgctrl(
        vga_clk,
        h_cnt,
        v_cnt,
        VGA_VS,
        inplace,
        SW0,
        SW1,
        VGA_R,
        VGA_G,
        VGA_B
    );
endmodule
