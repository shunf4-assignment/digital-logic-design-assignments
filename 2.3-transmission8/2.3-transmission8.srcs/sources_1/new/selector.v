`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/11 09:08:00
// Design Name: 
// Module Name: selector41
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
    parameter adsWidth = 3,      //the bitWidth
    parameter bitWidth = 2 ** adsWidth
)(
    input [bitWidth - 1:0] iC,
    input [adsWidth - 1:0] iS,
    output reg oZ
    );
    always @(iS or iC) begin
        //oZ = 1;
        oZ = iC[iS];
    end
endmodule
