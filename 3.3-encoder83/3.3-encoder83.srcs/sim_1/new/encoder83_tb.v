`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 23:16:53
// Design Name: 
// Module Name: encoder83_tb
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


module encoder83_tb(

    );
    reg [7:0] iData;
    wire [2:0] oData;
    encoder83 uut(
        .iData(iData),
        .oData(oData)
    );
    initial begin
        iData = 8'b00000000;
        #20 iData = 8'b00000001;
        while(iData != 8'b10000000)
            #20 iData = iData << 1;
        #20 iData = 8'b01010000;
    end
endmodule
