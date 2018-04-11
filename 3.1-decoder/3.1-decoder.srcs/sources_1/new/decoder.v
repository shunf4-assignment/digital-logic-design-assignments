`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 08:20:46
// Design Name: 
// Module Name: decoder
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


module decoder(
    input [2:0] iData,
    input [1:0] iEna,
    output [7:0] oData
    );
    wire enabled;
    assign enabledNot = iEna[0] | ~iEna[1];
    
    or(oData[0], enabledNot, iData[2], iData[1], iData[0]);
    or(oData[1], enabledNot, iData[2], iData[1], ~iData[0]);
    or(oData[2], enabledNot, iData[2], ~iData[1], iData[0]);
    or(oData[3], enabledNot, iData[2], ~iData[1], ~iData[0]);
    or(oData[4], enabledNot, ~iData[2], iData[1], iData[0]);
    or(oData[5], enabledNot, ~iData[2], iData[1], ~iData[0]);
    or(oData[6], enabledNot, ~iData[2], ~iData[1], iData[0]);
    or(oData[7], enabledNot, ~iData[2], ~iData[1], ~iData[0]);
    
endmodule
