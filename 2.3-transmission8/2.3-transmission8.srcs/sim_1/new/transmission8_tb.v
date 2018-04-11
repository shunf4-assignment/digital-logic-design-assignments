`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/16 11:29:11
// Design Name: 
// Module Name: transmission8_tb
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


module transmission8_tb(

    );
    reg [7:0] iData;
    wire A, B, C;
    reg [2:0] iS;
    wire [7:0] oData;
    
    assign A = iS[2];
    assign B = iS[1];
    assign C = iS[0];
    
    transmission8 uut(
        .iData(iData),
        .A(A),
        .B(B),
        .C(C),
        .oData(oData)
    );
    
    initial begin
        #10 iData = 8'b10101010;
        iS = 3'b0;
        repeat (7) begin
            #10
            iS = iS + 1;
        end
    end
endmodule
