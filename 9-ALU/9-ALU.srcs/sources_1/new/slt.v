`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 08:45:32
// Design Name: 
// Module Name: slt
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


module slt(
    input [31:0] a,
    input [31:0] b,
    output [31:0] r,
    input aluc,
    output zero,
    output negative,
    output carry
    );
    wire signed [31:0] a_s = a;
    wire signed [31:0] b_s = b;
    
    assign r = aluc ? (a_s < b_s) : (a < b);
    assign zero = (r==32'b0);
    assign negative = aluc ? (r[0]) : 0;
    assign carry = aluc ? 0 : r[0];
endmodule
