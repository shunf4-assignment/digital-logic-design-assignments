`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 08:36:46
// Design Name: 
// Module Name: addsub32
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


module addsub32(
    input [31:0] a,
    input [31:0] b,
    input [1:0] aluc,
    output [31:0] r,
    output carry,
    output zero,
    output negative,
    output overflow
    );
    wire [32:0] a_ext = {1'b0, a};
    wire [32:0] b_ext = {1'b0, b};
    wire [32:0] r_add_ext;
    wire [32:0] r_sub_ext;
    assign r_add_ext = a_ext + b_ext;
    assign r_sub_ext = a_ext - b_ext;
    assign r = (aluc[0])?r_sub_ext[31:0]:r_add_ext[31:0];
    assign carry = (aluc==2'b01)?r_sub_ext[32]:(aluc==2'b00)?r_add_ext[32]:'bz;
    assign zero = (r==32'b0);
    assign negative = r[31];
    assign overflow = (aluc==2'b10)?(~(a[31]^b[31])&(r_add_ext[31]^a[31])):(aluc==2'b11)?((a[31]^b[31])&(r_sub_ext[31]^a[31])):'bz;
endmodule
