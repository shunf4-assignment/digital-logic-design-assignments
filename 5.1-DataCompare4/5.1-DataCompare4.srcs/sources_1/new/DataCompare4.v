`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/06 08:12:26
// Design Name: 
// Module Name: DataCompare4
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


module DataCompare4(
    input [3:0] iData_a,
    input [3:0] iData_b,
    input [2:0] iData,
    output reg [2:0] oData
    );
    always @(iData_a or iData_b or iData) begin
        if (iData_a[3] && ~iData_b[3])
            oData = 3'b100;
        else if (~iData_a[3] && iData_b[3])
            oData = 3'b010;
        else begin
            if (iData_a[2] && ~iData_b[2])
                    oData = 3'b100;
            else if (~iData_a[2] && iData_b[2])
                oData = 3'b010;
            else begin
                if (iData_a[1] && ~iData_b[1])
                        oData = 3'b100;
                else if (~iData_a[1] && iData_b[1])
                    oData = 3'b010;
                else begin
                    if (iData_a[0] && ~iData_b[0])
                            oData = 3'b100;
                    else if (~iData_a[0] && iData_b[0])
                        oData = 3'b010;
                    else
                        oData = iData;
                end
            end
        end
    end
endmodule
