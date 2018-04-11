`timescale 1ns / 1ns
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
    reg [63:0] num = 0;
    reg [1:0] inter_CLK = 0;
    reg [1:0] odd_Pause = 0;
    
    if(freqDivisor % 2 == 0)
    begin
        always @(posedge I_CLK)
        begin
            if(Rst)
            begin
                num[31:0] = 32'b0;
                inter_CLK[0] = 0;
                odd_Pause = 0;
            end
            else
            begin
                num[31:0] = num[31:0] + 1;
                if(num[31:0] % (freqDivisor /2) == 0)
                begin
                    num[31:0] = 32'b0;
                    inter_CLK[0] = ~inter_CLK[0];
                end
            end
        end
        assign O_CLK = inter_CLK[0];
    end
    else
    begin
        always @(posedge I_CLK)
        begin
            if(Rst)
            begin
                num[31:0] = 32'b0;
                inter_CLK[0] = 1'b0;
                odd_Pause[0] = 0;
                num[63:32] = 32'b0;
                inter_CLK[1] = 1'b0;
                odd_Pause[1] = 0;
            end
            else
            begin
                num[31:0] = num[31:0] + 1;
                if(num[31:0] % (freqDivisor /2) == 0)
                begin
                    if((inter_CLK[0] == 0 & odd_Pause[0] == 0))
                    begin
                        odd_Pause[0] = 1;
                        num[31:0] = num[31:0] - 1;
                    end
                    else
                    begin
                        inter_CLK[0] = ~inter_CLK[0];
                        odd_Pause[0] = 0;
                        num[31:0] = 32'b0;
                    end
                end
            end
        end
        always @(negedge I_CLK)
        begin
            if(Rst)
            begin
                num[63:32] = 32'b0;
                inter_CLK[1] = 1'b0;
                odd_Pause[1] = 0;
            end
            else
            begin
                num[63:32] = num[63:32] + 1;
                if(num[63:32] % (freqDivisor /2) == 0)
                begin
                    if(inter_CLK[1] == 0 & odd_Pause[1] == 0)
                    begin
                        odd_Pause[1] = 1;
                        num[63:32] = num[63:32] - 1;
                    end
                    else
                    begin
                        inter_CLK[1] = ~inter_CLK[1];
                        odd_Pause[1] = 0;
                        num[63:32] = 32'b0;
                    end
                end
            end
        end
        assign O_CLK = inter_CLK[1] | inter_CLK[0];
    end
endmodule
