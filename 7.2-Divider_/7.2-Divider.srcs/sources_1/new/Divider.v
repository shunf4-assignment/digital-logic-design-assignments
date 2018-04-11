`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 09:34:56
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


module Divider #(
    parameter freqDivisor = 20
)(
    input I_CLK,
    input Rst,
    output O_CLK
    );
    wire [1:0] inter_CLK;
    if (freqDivisor % 2 == 0)
    begin
        Counter #(.max_Num(freqDivisor / 2))(
            .CLK(I_CLK),
            .ld_n(~Rst),
            .oCLK(O_CLK)
        );
    end
    else
    begin
        Counter_odd #(.max_Num((freqDivisor - 1) / 2))(
            .CLK(I_CLK),
            .ld_n(~Rst),
            .oCLK(inter_CLK[0])
        );
        Counter_odd #(.max_Num((freqDivisor - 1) / 2))(
            .CLK(~I_CLK),
            .ld_n(~Rst),
            .oCLK(inter_CLK[1])
        );
        assign O_CLK = inter_CLK[0] | inter_CLK[1];
    end
endmodule
