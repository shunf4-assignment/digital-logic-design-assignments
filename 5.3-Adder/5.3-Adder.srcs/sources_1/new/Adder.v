`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/06 09:20:24
// Design Name: 
// Module Name: Adder
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


module Adder(
    input iSA,
    input [7:0] iData_a,
    input [7:0] iData_b,
    output reg [8:0] oData,
    output reg oData_C
    );
    reg [7:0] intermediate1;  //unsigned
    reg [8:0] intermediate2;
    always @(iSA or iData_a or iData_b or oData or oData_C)
    begin
        if(iSA)
        begin
            if(iData_a[7] ^ iData_b[7])
            begin
                //Negative + Positive | Positive + Negative
                intermediate1 = iData_a[6:0];
                intermediate1 = intermediate1 - iData_b[6:0];
                oData = {(iData_a[7])^(intermediate1 <= 0), (intermediate1 >= 0)?(intermediate1):(-intermediate1)};
                oData_C = 0;
            end
            else
            begin
                //Negative + Negative | Positive + Positive
                intermediate1 = iData_a[6:0];
                intermediate1 = intermediate1 + iData_b[6:0];
                oData = {iData_a[7], intermediate1};
                oData_C = intermediate1[7];
            end
        end
        else
        begin
            intermediate2 = iData_a;
            oData = intermediate2;
            oData_C = intermediate2[8];
        end
    end
endmodule
