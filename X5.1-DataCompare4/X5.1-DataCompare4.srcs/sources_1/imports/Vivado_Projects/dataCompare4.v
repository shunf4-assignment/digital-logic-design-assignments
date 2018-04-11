`timescale 1ns/1ns
module DataCompare4(
    input [3:0] iData_a,
    input [3:0] iData_b,
    input [2:0] iData,
    output reg [2:0] oData
);

always @(iData or iData_a or iData_b)
begin 
if(iData_a>iData_b)
    oData=3'b100;
else if(iData_a<iData_b)
    oData=3'b010;
else if(iData[2])
    oData=3'b100;
else if(iData[1])
    oData=3'b010;
else if(iData[0])
    oData=3'b001;
else 
    oData=3'bxxx;
end

endmodule