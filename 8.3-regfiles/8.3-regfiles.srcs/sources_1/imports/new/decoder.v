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


module decoder #(
    parameter selectNumWidth = 2
)(
    input [selectNumWidth - 1:0] iData,
    input [1:0] iEna,
    output [2**selectNumWidth - 1:0] oData
    );
    wire enabled;
    assign enabled = ~iEna[0] & iEna[1];
    generate
        genvar i;
        for(i=0;i<2**selectNumWidth;i=i+1)
        begin : assign_odata
            assign oData[i] = (enabled & (iData == i))?1:0;
        end
    endgenerate
    
endmodule
