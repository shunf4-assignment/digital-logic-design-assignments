`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 23:06:41
// Design Name: 
// Module Name: Divider
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


module Divider(
input I_CLK,
input Rst,
output reg O_CLK
    );
    integer i = 0;
    parameter divide_n = 20;
    initial begin
        O_CLK = 0;
    end
    always@(posedge I_CLK)begin
        if(Rst == 0)begin
            if(i == divide_n/2)begin
                i = 1;
                O_CLK=~O_CLK;
            end
            else begin
                i = i+1;
            end
        end
        else begin
            i = 0;
            O_CLK = 0;
        end
    end
endmodule