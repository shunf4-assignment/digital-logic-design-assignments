`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/12 23:43:01
// Design Name: 
// Module Name: Synchronous_D_FF
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


module Synchronous_D_FF(
    input CLK,
    input D,
    input RST_n,
    output reg Q1,
    output reg Q2
    );
    always @ (posedge CLK)
    begin
        if(~RST_n)
        begin
            Q1 = 0;
        end
        else
        begin
            Q1 = D;
        end
        Q2 = ~Q1;   
    end
endmodule
