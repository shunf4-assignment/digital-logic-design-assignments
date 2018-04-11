`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/28 21:45:07
// Design Name: 
// Module Name: encoder83_Pri_tb
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


module encoder83_Pri_tb(

    );
    reg signed [7:0] iData;
    reg iEI;
    wire [2:0] oData;
    wire oEO;
    
    encoder83_Pri uut(
        .iData(iData),
        .oData(oData),
        .iEI(iEI),
        .oEO(oEO)
    );
    
    initial begin
        iEI = 1;  //DISABLE
        iData = 8'b10110111; //6
        #20
        iEI = 0; //ENABLE
        iData = 8'b11111111; //NO INPUT
        #20
        iData = 8'b00000000; //7's got priority
        #20
        iData = 8'b10xxxxxx; //6
        while(iData != 8'b11111111)
            #20 iData = iData >>> 1; //right-shift with sign
    end
    
endmodule
