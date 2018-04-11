`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 20:10:12
// Design Name: 
// Module Name: selector
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



module selector #(
    parameter bitWidth = 4,
    parameter inputNum = 4,
    parameter selectNumWidth = 2
)(
    input [bitWidth * inputNum - 1:0] iC,
    input [selectNumWidth - 1:0] iS,
    output [bitWidth - 1:0] oZ
    );
    assign oZ = iC[iS * bitWidth +: bitWidth];
    
endmodule
