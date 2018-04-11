`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/06 08:55:49
// Design Name: 
// Module Name: DataCompare8
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


module DataCompare8(
    input [7:0] iData_a,
    input [7:0] iData_b,
    output [2:0] oData
    );
    wire [2:0] mData;
    DataCompare4 dc1(
        .iData_a(iData_a[3:0]),
        .iData_b(iData_b[3:0]),
        .iData(3'b001),
        .oData(mData)
    );
    DataCompare4 dc2(
        .iData_a(iData_a[7:4]),
        .iData_b(iData_b[7:4]),
        .iData(mData),
        .oData(oData)
    );
endmodule
