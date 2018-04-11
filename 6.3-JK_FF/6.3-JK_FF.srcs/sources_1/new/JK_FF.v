`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/13 10:53:22
// Design Name: 
// Module Name: JK_FF
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

//Asynchronous Reset
module JK_FF(
    input CLK,
    input J,
    input K,
    input RST_n,
    output reg Q1,
    output reg Q2
    );
    
    always @ (negedge RST_n or posedge CLK)
    begin
        if(~RST_n)
        begin
            Q1 <= 0;
            Q2 <= 1;
        end
        else if(J & K)
        begin
            Q2 <= Q1;
            Q1 <= Q2;
        end
        else if(J)
        begin
            Q1 <= 1;
            Q2 <= 0;
        end
        else if(K)
        begin
            Q1 <= 0;
            Q2 <= 1;
        end
    end
endmodule
