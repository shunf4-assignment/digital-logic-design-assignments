`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 19:26:28
// Design Name: 
// Module Name: display7
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


module display7(
    input [3:0] iData,
    output reg [6:0] oData
    );
//    assign oData[0] = ~iData[3] & ~iData[1] & (iData[2] ^ iData[0]);
//    assign oData[1] = ~iData[3] & iData[2] & (iData[1] ^ iData[0]);
//    assign oData[2] = ~iData[3] & ~iData[2] & iData[1] & ~iData[0];
//    assign oData[3] = ~iData[3] & ( ~iData[2] & ~iData[1] & iData[0] | iData[2] & ~iData[1] & ~iData[0] | iData[2] & iData[1] & iData[0]);
//    assign oData[4] = iData[0] | ( iData[3] | iData[2] | iData[1]) & (iData[3] | iData[2] | ~iData[1]) & (iData[3] | ~iData[2] | ~iData[1]) & (~iData[3] | iData[2] | iData[1]);
//    assign oData[5] = ~iData[3] & ~iData[2] & (iData[1] | iData[0]) | iData[2] & iData[1] & iData[0];
//            //oData[5]: not precise
//    assign oData[6] = ~(iData[3] | iData[2] | iData[1]) | iData[2] & iData[1] & iData[0];
    always @(iData) case (iData)
        0:oData = 7'b1000000;
        1:oData = 7'b1111001;
        2:oData = 7'b0100100;
        3:oData = 7'b0110000;
        4:oData = 7'b0011001;
        5:oData = 7'b0010010;
        6:oData = 7'b0000010;
        7:oData = 7'b1111000;
        8:oData = 7'b0000000;
        9:oData = 7'b0010000;
        default:
        oData = 7'b1111111;
    endcase
    
endmodule