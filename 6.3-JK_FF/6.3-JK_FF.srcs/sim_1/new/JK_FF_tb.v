`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/13 17:21:30
// Design Name: 
// Module Name: JK_FF_tb
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


module JK_FF_tb(

    );
    reg J,K;
    reg CLK;
    reg RST_n;
    wire Q1;
    wire Q2;
    JK_FF uut1(
        .J(J),
        .K(K),
        .CLK(CLK),
        .RST_n(RST_n),
        .Q1(Q1),
        .Q2(Q2)
    );
    
    initial
        CLK = 0;
    
    always #10
        CLK = ~CLK;
    
    initial begin
        J = 0;
        K = 0;
        RST_n = 1;
        #25
        J = 1;
        #20
        J = 0;
        #20
        K = 1;
        #20
        K = 0;
        #20
        J <= 1;
        K <= 1;
        #120
        J <= 1;
        K <= 0;
        #20
        RST_n = 0;
        #60
        RST_n = 1;
    end
endmodule
