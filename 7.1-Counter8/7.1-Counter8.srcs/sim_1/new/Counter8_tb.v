`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 09:06:24
// Design Name: 
// Module Name: Counter8_tb
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


module Counter8_tb(

    );
    reg CLK;
    reg rst_n;
    wire  [2:0] oQ;
    wire [6:0] oDisplay;
    Counter8 uut(
        .CLK(CLK),
        .rst_n(rst_n),
        .oQ(oQ),
        .oDisplay(oDisplay)
    );
    initial begin
        CLK = 1;
        rst_n = 0;
        
        forever #10 CLK = ~CLK;
    end
    
    initial begin
        #25 rst_n = 1;
        #250 rst_n = 0;
        #80 rst_n = 1;
    end
endmodule
