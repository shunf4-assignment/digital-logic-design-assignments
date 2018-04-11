`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/06 08:19:44
// Design Name: 
// Module Name: DataCompare4_tb
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


module DataCompare4_tb(

    );
    reg [3:0] iData_a;
    reg [3:0] iData_b;
    reg [2:0] iData;
    wire [2:0] oData;
    
    DataCompare4 uut(
        .iData_a(iData_a),
        .iData_b(iData_b),
        .iData(iData),
        .oData(oData)
    );
    initial begin
        #20 iData_a = 4'b1000;
        iData_b = 4'b0111;
        iData = 3'b001;
        #20 iData_a[3] <= 0;
        iData_b[3] <= 1;
        #20 iData_b[3] = 0;
        #20 iData_a[2] <= 1;
        iData_b[2] <= 0;
        #10 iData = 3'b100;  //To make sure oData won't change with iData when A != B
        #10 iData_a[2] = 0;
        #20 iData_a[1] <= 1;
        iData_b[1] <= 0;
        #20 iData_a[1] = 0;
        #10 iData = 3'b001;  //To make sure oData won't change with iData when A != B
        #10 iData_a[0] <= 1;
        iData_b[0] <= 0;
        #20 iData_a[0] = 0;
        #20 iData = 3'b010;  //To make sure oData WILL change with iData when A == B
        #20 iData = 3'b100;
    end
endmodule
