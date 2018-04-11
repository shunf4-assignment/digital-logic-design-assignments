`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/11 13:49:34
// Design Name: 
// Module Name: selector41_tb
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


module selector41_tb(
    );
    reg iS1, iS0;
    reg [3:0] iC1, iC2, iC3, iC0;
    wire [3:0] oZ;
    
    selector41 uut (
            .iS0(iS0),
            .iS1(iS1),
            .iC0(iC0),
            .iC1(iC1),
            .iC2(iC2),
            .iC3(iC3),
            .oZ(oZ)
       );
    
    initial begin
        iC0 = 4'b0001;
        iC1 = 4'b0101;
        iC2 = 4'b1010;
        iC3 = 4'b1111;
        #100 iC0 = 4'b0010;
        iC1 = 4'b0000;
        iC2 = 4'b1000;
        iC3 = 4'b1100;
    end
    initial begin
        #20 iS0 = 0;    //start
        iS1 = 0;
        #20 iS0 = 1;
        #20 iS0 = 0;
        iS1 = 1;
        #20 iS0 = 1;
        
        #20 iS0 = 0;    //start
        iS1 = 0;
        #20 iS0 = 1;
        #20 iS0 = 0;
        iS1 = 1;
        #20 iS0 = 1;
    end
endmodule
