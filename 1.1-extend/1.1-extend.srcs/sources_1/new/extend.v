`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 22:41:38
// Design Name: 
// Module Name: extend
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


module extend #(
    parameter INWIDTH = 16,
    parameter OUTWIDTH = 32
)(
    input [INWIDTH - 1:0] a,
    input sext,
    output [OUTWIDTH - 1:0] b
);
    assign b = sext ? {{(OUTWIDTH - INWIDTH){a[INWIDTH - 1]}}, a} : a;
endmodule
