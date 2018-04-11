`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 19:50:59
// Design Name: 
// Module Name: vga_clkgen_tb
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


module vga_clkgen_tb(

    );
    reg clk_100MHz = 0;
    wire clk_65MHz, clk_48kHz;
    initial forever #5 clk_100MHz = ~clk_100MHz;
    
    vga_clkgen uut(clk_100MHz, clk_65MHz, clk_48kHz);
    
endmodule
