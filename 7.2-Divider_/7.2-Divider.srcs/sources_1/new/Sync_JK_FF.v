`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 12:49:33
// Design Name: 
// Module Name: Sync_JK_FF
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


module Sync_JK_FF(
    input CLK,
    input J,
    input K,
    input RST,
    output reg Q,
    output reg Q_n
    );
    always @(posedge CLK)
    begin
        if(RST)
        begin
            Q <= 0;
            Q_n <= 1;
        end
        else if (J & K)
        begin
            Q_n <= Q;
            Q <= Q_n;
        end
        else if(J)
        begin
            Q <= 1;
            Q_n <= 0;
        end
        else if(K)
        begin
            Q <= 0;
            Q_n <= 1;
        end
    end
endmodule
