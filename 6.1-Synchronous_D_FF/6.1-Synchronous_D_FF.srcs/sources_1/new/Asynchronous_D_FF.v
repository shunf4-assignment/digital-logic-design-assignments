`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/12 23:53:53
// Design Name: 
// Module Name: Asynchronous_D_FF
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


//module Asynchronous_D_FF(
//    input CLK,
//    input D,
//    input RST_n,
//    output reg Q1,
//    output reg Q2
//    );
    
//    always @ (posedge CLK or negedge RST_n or posedge RST_n)
//    begin
//        if(~RST_n)
//        begin
//            Q2 <= 1;
//            Q1 <= 0;
//        end
//        else begin
//            Q1 = D;
//            Q2 = ~D;
//        end
//    end
//endmodule

module Asynchronous_D_FF(
    input CLK,
    input D,
    input RST_n,
    output reg Q1,
    output reg Q2
    );
    always @ (posedge (CLK) or negedge (RST_n))
    begin
        if(~RST_n)
        begin
            Q2 = 1;
            Q1 = 0;
        end
        else begin
            Q1 = D;
            Q2 = ~D;
        end
    end
endmodule
