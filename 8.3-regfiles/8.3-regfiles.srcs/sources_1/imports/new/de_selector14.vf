`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/11 21:16:50
// Design Name: 
// Module Name: de_selector14
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


module de_selector14(
    input iC,
    input iS1,
    input iS0,
    output oZ0,
    output oZ1,
    output oZ2,
    output oZ3
    );
    /*or or0 (oZ0, iS1, iS0, iC);
    or or1 (oZ1, iS1, ~iS0, iC);
    or or2 (oZ2, ~iS1, iS0, iC);
    or or3 (oZ3, ~iS1, ~iS0, iC);*/
    assign oZ0 = (iS1| iS0| iC);
    assign oZ1 = (iS1| ~ iS0| iC);
    assign oZ2 = (~ iS1| iS0| iC);
    assign oZ3 = (~ iS1| ~ iS0| iC);
endmodule
