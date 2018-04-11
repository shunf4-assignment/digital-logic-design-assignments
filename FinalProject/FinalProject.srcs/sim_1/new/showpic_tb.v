`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/11 20:16:32
// Design Name: 
// Module Name: showpic_tb
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


module showpic_tb(

    );
    reg CLK100MHZ = 0;
    reg BTNU = 0;
    wire [3:0] VGA_R;
    wire [3:0] VGA_G;
    wire [3:0] VGA_B;
    wire VGA_HS;
    wire VGA_VS;
    initial forever #1 CLK100MHZ = ~CLK100MHZ;
    
    test1_showpic uut(CLK100MHZ, 1, BTNU, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS);
endmodule
