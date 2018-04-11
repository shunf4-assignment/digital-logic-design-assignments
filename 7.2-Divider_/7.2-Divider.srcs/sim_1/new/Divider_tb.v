`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 21:45:34
// Design Name: 
// Module Name: Divider_tb
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


module Divider_tb(

    );
    reg I_CLK;
    wire O_CLK;
    reg Rst;
    
//    Divider #(.freqDivisor(3)) uut(
//        .I_CLK(I_CLK),
//        .O_CLK(O_CLK),
//        .Rst(Rst)
//    );
    
    initial begin
        I_CLK = 1;
        Rst = 0;
        forever #10 I_CLK = ~I_CLK;
    end
endmodule
