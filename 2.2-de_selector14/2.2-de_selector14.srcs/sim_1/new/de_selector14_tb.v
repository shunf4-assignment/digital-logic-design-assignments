`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/11 21:23:38
// Design Name: 
// Module Name: de_selector14_tb
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


module de_selector14_tb(

    );
    reg iC, iS1, iS0;
    wire oZ0, oZ1, oZ2, oZ3;
    de_selector14 uut (
        .iC(iC),
        .iS0(iS0),
        .iS1(iS1),
        .oZ0(oZ0),
        .oZ1(oZ1),
        .oZ2(oZ2),
        .oZ3(oZ3)
    );
    initial begin
        iC = 0;
        #20 iS0 = 0; iS1 = 0;
        #20 iS0 = 1; iS1 = 0;
        #20 iS0 = 0; iS1 = 1;
        #20 iS0 = 1; iS1 = 1;
        #20
        iC = 1;
        #20 iS0 = 0; iS1 = 0;
        #20 iS0 = 1; iS1 = 0;
        #20 iS0 = 0; iS1 = 1;
        #20 iS0 = 1; iS1 = 1;
    end
endmodule
