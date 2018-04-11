`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/30 11:15:45
// Design Name: 
// Module Name: barrelshifter32_tb
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


module barrelshifter32_tb(

    );
     reg signed [31:0] a;
     reg [4:0] b;
     reg [1:0] aluc;
     wire [31:0] c;
     
     barrelshifter32 uut(
        .a(a),
        .b(b),
        .aluc(aluc),
        .c(c)
     );
     
     initial begin
        aluc = 2'b00;
        #20
        a = 32'b11011000101011100010000100110101;
        b = 0;
        #10 b = 3;
        while((b - 3) < b)
            #10 b = b + 3;
            
        #20 aluc = 2'b10;
        b = 0;
        #10 b = 3;
        while((b - 3) < b)
            #10 b = b + 3;
            
        #20 aluc = 2'b01;
        b = 0;
        #10 b = 3;
        while((b - 3) < b)
            #10 b = b + 3;
            
        #20 aluc = 2'b11;
        b = 0;
        #10 b = 3;
        while((b - 3) < b)
            #10 b = b + 3;
     end
endmodule
