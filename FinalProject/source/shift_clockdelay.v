`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/26 11:03:52
// Design Name: 
// Module Name: shift_clockdelay
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


module shift_clockdelay #(
    parameter DELAYBITS = 10
) (
    input clk_original,
    output clk_delayed
);
    //if(DELAYBITS >= 2) begin
        reg [DELAYBITS-2:0] delaystore;
        wire clk_buf;
        assign clk_buf = clk_original;
        always @(clk_original) begin
            delaystore[0] = clk_buf;
            if(DELAYBITS > 2)
                delaystore[DELAYBITS-2 : 1] = delaystore[DELAYBITS-3 : 0];
        end
        assign clk_delayed = delaystore[DELAYBITS-2];
//    end else if (DELAYBITS == 1) begin
//        reg delaystore1;
//        wire clk_buf;
//        assign clk_buf = clk_original;
//        always @(clk_original) begin
//            delaystore1 = clk_buf;
//        end
//        assign clk_delayed = delaystore1;
//    end
endmodule
