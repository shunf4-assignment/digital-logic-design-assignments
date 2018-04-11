`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/16 08:40:42
// Design Name: 
// Module Name: transmission8
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


module transmission8(
    input [7:0] iData,
    input A,
    input B,
    input C,
    output [7:0] oData
    );
    wire Y;
    selector #(3) s1 (
        .iC(iData),
        .iS({A, B, C}),
        .oZ(Y)
    );
        
    de_selector #(3) d1 (
        .iC(Y),
        .iS({A, B, C}),
        .oZ(oData)
    );
endmodule
