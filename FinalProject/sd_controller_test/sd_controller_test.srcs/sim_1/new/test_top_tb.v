`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 19:52:26
// Design Name: 
// Module Name: test_top_tb
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


module test_top_tb(

    );
    reg CLK100MHZ = 0;
    reg BTNU;
    reg [15:0] SW;
    reg BTNR;
    wire [15:0] LED;
    wire SD_SCK;
    wire SD_CMD;
    reg SD_DAT0 = 0;
    wire SD_DAT3;
    wire [7:0] AN;
    wire [7:0] C;
    
    test_top uut(
        .CLK100MHZ(CLK100MHZ),
        .BTNU(BTNU),
        .SW(SW),
        .BTNR(BTNR),
        .LED(LED),
        .SD_SCK(SD_SCK),
        .SD_CMD(SD_CMD),
        .SD_DAT0(SD_DAT0),
        .SD_DAT3(SD_DAT3),
        .AN(AN),
        .C(C)
    );
    
    initial forever #1 CLK100MHZ = ~CLK100MHZ;
    initial begin
        #10 BTNU = 0;
        #10 SW[3] = 1;
        #10 BTNR = 0;
    end
    
    //initial forever #30 SD_DAT0 = ~SD_DAT0;
    initial SD_DAT0 = 1;
    
endmodule
