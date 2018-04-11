`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/27 09:04:21
// Design Name: 
// Module Name: encoder83_Pri
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


module encoder83_Pri(
    input [7:0] iData,
    input iEI,
    output reg [2:0] oData,
    output reg oEO
    );
    always @(iData or iEI)
    if(iEI === 1'b0) begin
        oEO = 1;
        casex(iData)
            8'b0xxxxxxx: oData = 0;
            8'b10xxxxxx: oData = 1;
            8'b110xxxxx: oData = 2;
            8'b1110xxxx: oData = 3;
            8'b11110xxx: oData = 4;
            8'b111110xx: oData = 5;
            8'b1111110x: oData = 6;
            8'b11111110: oData = 7;
            default: begin
                oData = 3'b111;
                oEO = 0;
            end
        endcase
    end else begin
        oEO = 0;
        oData = 3'b111;
    end
endmodule
