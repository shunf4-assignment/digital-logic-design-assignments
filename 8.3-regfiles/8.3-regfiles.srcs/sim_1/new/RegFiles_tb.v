`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 21:09:37
// Design Name: 
// Module Name: RegFiles_tb
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


module Regfiles_tb(

    );
    reg clk;
    reg rst;
    reg we;
    reg [4:0] raddr1;
    reg [4:0] raddr2;
    reg [4:0] waddr;
    reg [31:0] wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    
    Regfiles uut(
        clk,
        rst,
        we,
        raddr1,
        raddr2,
        waddr,
        wdata,
        rdata1,
        rdata2
    );
    
    initial
    begin
        clk = 1;
        rst = 0;
        we = 0;
        raddr1 = 0;
        raddr2 = 0;
        waddr = 0;
        wdata = 0;
        forever #10 clk = ~clk;
    end
    
    integer j;
    
    initial
    begin
    // test writing
        #45 we = 1;
        
        #2
        $display("rdata1 : %h == zzzzzzzz ?", rdata1);
        $display("rdata2 : %h == zzzzzzzz ?", rdata2);
        for(j = 0; j < 32; j = j + 1)
        begin
            wdata = {27'h7fffff8 ,j[4:0]};
            waddr = j[4:0];
            raddr1 = j[4:0];
            #10
            we = 0;
            #10
            we = 1;
        end
        
    //test reading
        #18
        we = 0;
        raddr1 = 5'd14;
        raddr2 = 5'd0;
        #2
        $display("rdata1 : %h == ffffff0e ?", rdata1);
        $display("rdata2 : %h == ffffff00 ?", rdata2);
        #18
        raddr1 = 5'd4;
        raddr2 = 5'd31;
        #2
        $display("rdata1 : %h == ffffff04 ?", rdata1);
        $display("rdata2 : %h == ffffffff ?", rdata2);
        #18
        
    //test resetting
        rst = 1;
        #2
        $display("rdata1 : %h == 00000000 ?", rdata1);
        $display("rdata2 : %h == 00000000 ?", rdata2);
    end
    
endmodule
