`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/13 20:55:45
// Design Name: 
// Module Name: pcreg_tb
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


module pcreg_tb(

    );
    reg clk;
    reg rst;
    reg ena;
    reg [31:0] data_in;
    wire [31:0] data_out;
    
    pcreg uut (
        .clk(clk),
        .rst(rst),
        .ena(ena),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    initial begin
        clk = 0;
        rst = 0;
        ena = 0;
        data_in = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        #45 ena = 1;
        data_in = 32'b01010101010101010101010101010101;
        #20 data_in = 32'h7f3a4402;
        #20 data_in = 32'hcabbae33;
        #20 ena = 0;
        #20 rst = 1;
        #20 rst = 0;
        #20 data_in = 32'h80808080;
        #10 ena = 1;
        #40 rst = 1;
        #20 rst = 0;
        
    end
endmodule
