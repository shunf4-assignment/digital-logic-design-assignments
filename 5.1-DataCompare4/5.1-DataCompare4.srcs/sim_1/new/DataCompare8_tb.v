`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/06 08:59:02
// Design Name: 
// Module Name: DataCompare8_tb
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


module DataCompare8_tb(

    );
    reg [7:0] iData_a;
    reg [7:0] iData_b;
    wire [2:0] oData;
    integer i;
    DataCompare8 uut(
        .iData_a(iData_a),
        .iData_b(iData_b),
        .oData(oData)
    );
    initial begin
        i = 6;
        #20 iData_a = 8'b10000000;
        iData_b = 4'b01111111;
        #20 iData_a[7] <= 0;
        iData_b[7] <= 1;
        #20 iData_b[7] = 0;
        
        while(i >= 0) begin
            #20 iData_a[i] <= 1;
            iData_b[i] <= 0;
            #20
            iData_a[i] = 0;
            i = i - 1;
        end
        
    end
endmodule
