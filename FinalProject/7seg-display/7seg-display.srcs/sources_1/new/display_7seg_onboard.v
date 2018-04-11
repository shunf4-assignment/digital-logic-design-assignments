`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/16 15:21:11
// Design Name: 
// Module Name: display_7seg_onboard
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


module display_7seg_onboard(
    input clk_100MHz,
    input le,
    input rst,
    input [3:0] digit0,
    input [3:0] digit1,
    input [1:0] digit_sel,
    input [1:0] dot,
    output [7:0] AN,
    output [7:0] C
    );
    
    reg [3:0] digit7_r;
    reg [3:0] digit6_r;
    reg [3:0] digit5_r;
    reg [3:0] digit4_r;
    reg [3:0] digit3_r;
    reg [3:0] digit2_r;
    reg [3:0] digit1_r;
    reg [3:0] digit0_r;
    
    reg [7:0] dot_r;
    
    always @(le or rst) begin
        if (rst) begin
             digit0_r = 0;
             digit1_r = 0;
             digit2_r = 0;
             digit3_r = 0;
             digit4_r = 0;
             digit5_r = 0;
             digit6_r = 0;
             digit7_r = 0;
             dot_r = 0;
        end
        else if (le) begin
            if(digit_sel == 0) begin
                digit0_r = digit0;
                digit1_r = digit1;
                dot_r[1:0] = dot;
            end else
            if(digit_sel == 1) begin
                digit2_r = digit0;
                digit3_r = digit1;
                dot_r[3:2] = dot;
            end else
            if(digit_sel == 2) begin
                digit4_r = digit0;
                digit5_r = digit1;
                dot_r[5:4] = dot;
            end else
            if(digit_sel == 3) begin
                digit6_r = digit0;
                digit7_r = digit1;
                dot_r[7:6] = dot;
            end
        end
    end
    
    display_7seg uut(
        clk_100MHz,
        rst,
        1,
        digit7_r,
        digit6_r,
        digit5_r,
        digit4_r,
        digit3_r,
        digit2_r,
        digit1_r,
        digit0_r,
        dot_r,
        null,
        AN,
        C
    );
endmodule
