`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 19:26:58
// Design Name: 
// Module Name: display7_tb
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


module display7_tb(

    );
    reg [3:0] iData;
    wire [6:0] oData;
    
    display7 uut
    (
        .iData(iData),
        .oData(oData)
    );
    
    initial begin
        iData = 0;
        while(iData < 14)
            #20 iData = iData + 1;
    end
endmodule
