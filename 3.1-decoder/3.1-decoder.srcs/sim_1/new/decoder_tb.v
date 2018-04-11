`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 08:34:54
// Design Name: 
// Module Name: decoder_tb
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


module decoder_tb(

    );
    reg [2:0] iData;
    reg [1:0] iEna;
    wire [7:0] oData;
    
    decoder uut (
        .iData(iData),
        .iEna(iEna),
        .oData(oData)
    );
    
    initial begin
        iData = 5'b101;
        iEna = 2'b01;   //not enabled
    end
    
    initial begin
        #20 iData = 5'b000;
        #20 iEna = 2'b00;
        //enable
        #20 iEna = 2'b10;
        while(iData < 7)
            #20 iData = iData + 1;

        #20 iEna = 2'b11;
    end
endmodule
