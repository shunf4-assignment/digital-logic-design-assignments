`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/21 08:07:17
// Design Name: 
// Module Name: Counter8_final
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


module Counter8_final(
    input CLK,
    input rst_n,
    output [2:0] oQ,
    output [6:0] oDisplay
    );
    wire O_CLK;
    Divider #(.freqDivisor(100000000)) d1(
        .I_CLK(CLK),
        .Rst(~rst_n),
        .O_CLK(O_CLK)
    );
    Counter8(
        .CLK(O_CLK),
        .rst_n(rst_n),
        .oQ(oQ),
        .oDisplay(oDisplay)
    );
endmodule
