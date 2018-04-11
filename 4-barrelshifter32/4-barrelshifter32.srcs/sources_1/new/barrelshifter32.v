`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/30 11:06:08
// Design Name: 
// Module Name: barrelshifter32
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


module barrelshifter32(
    input wire signed [31:0] a,
    input wire [4:0] b,
    input [1:0] aluc,
    output [31:0] c
    );
    assign c=aluc[0]?(a<<<b):(aluc[1]?(a>>b):(a>>>b));
endmodule
