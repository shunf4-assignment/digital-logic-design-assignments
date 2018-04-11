`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 08:46:01
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


module JK_FF(
    input CLK,
    input J,
    input K,
    input RST,
    output reg Q,
    output reg Q_n
    );
    always @(posedge RST or posedge CLK)
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
