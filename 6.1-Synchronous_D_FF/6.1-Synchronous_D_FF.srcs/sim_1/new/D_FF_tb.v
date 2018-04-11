`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/12 23:56:33
// Design Name: 
// Module Name: D_FF_tb
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


module D_FF_tb(

    );
    reg D;
    reg CLK;
    reg RST_n;
    wire Q1;
    wire Q2;
    Synchronous_D_FF uut1(
    //Asynchronous_D_FF uut1(
        .D(D),
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
        D = 0;
        RST_n = 1;
        #25 D = 1;
        #20 D = 0;
        #20 D = 1;
        #20 RST_n = 0;
        #30 RST_n = 1;
    end
endmodule

