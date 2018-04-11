`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/16 09:42:59
// Design Name: 
// Module Name: selector_tb
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


module selector_tb(

    );
    reg [7:0] iC;
    reg [2:0] iS;
    wire oZ;
    selector #(3) uut(.iC(iC), .iS(iS), .oZ(oZ));
    initial begin
        #10 iC = 8'b01010101;
        iS = 0;
        #10 iS = 1;
        #10 iS = 0;
    end
endmodule
