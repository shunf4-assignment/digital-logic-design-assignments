`timescale 1ns / 1ns
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


module de_selector #(
        parameter adsWidth = 3,
        parameter bitWidth = 2 ** adsWidth
    ) (
        input iC,
        input [adsWidth - 1:0] iS,
        output reg [bitWidth - 1:0] oZ
    );
        always @(iC or iS) begin
            oZ = {(bitWidth){1'b1}};
            oZ[iS] = iC;
       end

endmodule
