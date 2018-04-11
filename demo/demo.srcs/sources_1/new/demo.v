`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 20:42:51
// Design Name: 
// Module Name: demo
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


module demo(
    input clk,
    output reg equal,
    output reg [4:0] cnt = 0
    );
    //reg [4:0] cnt = 0;
    always @(posedge clk)begin
        cnt = cnt + 1;
        if(cnt == 4)
            equal <= 1;
    end
endmodule
