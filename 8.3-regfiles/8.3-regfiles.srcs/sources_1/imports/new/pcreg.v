`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/13 17:40:26
// Design Name: 
// Module Name: pcreg
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


module pcreg
#(
parameter DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input ena,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
    );
    
    wire [DATA_WIDTH-1:0] data_inter;
    generate
        genvar i;
        for(i=0;i<DATA_WIDTH;i=i+1)
        begin : loop_setadf
            Asynchronous_D_FF adf(
                .CLK(clk),
                .RST_n(~rst),
                .D(ena ? data_in[i] : data_out[i]),
                .Q1(data_out[i]),
                .Q2(null)
            );
        end
    endgenerate
    
endmodule
