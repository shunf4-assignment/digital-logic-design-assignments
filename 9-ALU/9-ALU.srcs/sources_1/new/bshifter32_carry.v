`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 08:36:46
// Design Name: 
// Module Name: bshifter32_carry
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


module bshifter32_carry(
    input [4:0] a,
    input [31:0] b,
    input [1:0] aluc,
    output [31:0] r,
    output zero,
    output carry,
    output negative
    );
    wire signed [33:0] b_ext;
    wire signed [33:0] b_ext_shift;
    assign b_ext = {~aluc[0], b, 1'b0};
    assign b_ext_shift = aluc[1]?(b_ext<<<a):(b_ext>>>a);
    assign r = b_ext_shift[32:1];
    assign zero = (r==31'b0);
    assign carry = aluc[1]?b_ext_shift[33]:b_ext_shift[0];
    assign negative = r[31];
endmodule
