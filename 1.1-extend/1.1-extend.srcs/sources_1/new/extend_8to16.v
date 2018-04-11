`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 23:06:00
// Design Name: 
// Module Name: extend_8to16
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

module extend_8to16(
    a, sext, b
);
    parameter INWIDTH = 8;
    parameter OUTWIDTH = 16;
    input [INWIDTH - 1:0] a;
    input sext;
    output [OUTWIDTH - 1:0] b;
    extend #(INWIDTH, OUTWIDTH) (a, sext, b);
endmodule
