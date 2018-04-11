`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 20:45:12
// Design Name: 
// Module Name: demo_tb
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


module demo_tb(

    );
    reg clk = 0;
    wire equal;
    wire [4:0] cnt;
    reg [7:0] a;
    reg [7:0] b [0:7];
    
    demo uut1(
        clk,
        equal,
        cnt
    );
    initial forever #10 clk = ~clk;
    initial begin
        #10 a = 8'b11000011;
        b[0] = 8'h01;
        b[1] = 8'h02;
        b[2] = 8'h03;
        b[3] = 8'h04;
        b[4] = 8'h05;
        b[5] = 8'h06;
        b[6] = 8'h07;
        b[7] = 8'h08;
        #10
        $display("a: %b", a[7:2]);
        $display("b: %h", b[2+:3]);
    end
endmodule
