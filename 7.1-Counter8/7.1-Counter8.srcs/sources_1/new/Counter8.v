`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 08:55:11
// Design Name: 
// Module Name: Counter8
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


module Counter8(
    input CLK,
    input rst_n,
    output [2:0] oQ,
    output [6:0] oDisplay
    );
    JK_FF jk1(
        .CLK(CLK),
        .J(1),
        .K(1),
        .RST(~rst_n),
        .Q(oQ[0])
    );
    JK_FF jk2(
        .CLK(CLK),
        .J(oQ[0]),
        .K(oQ[0]),
        .RST(~rst_n),
        .Q(oQ[1])
    );
    JK_FF jk3(
        .CLK(CLK),
        .J(oQ[0] & oQ[1]),
        .K(oQ[0] & oQ[1]),
        .RST(~rst_n),
        .Q(oQ[2])
    );
    display7 disp1(
        .iData({1'b0,oQ}),
        .oData(oDisplay)
    );
endmodule
