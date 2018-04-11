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
    output reg [DATA_WIDTH-1:0] data_out
    );
    
    wire [DATA_WIDTH-1:0] data_inter;
    generate
        genvar i;
        for(i=0;i<DATA_WIDTH;i=i+1)
        begin : loop_setadf
            Asynchronous_D_FF adf(
                .CLK(clk),
                .RST_n(~rst),
                .D(data_in[i]),
                .Q1(data_inter[i])
            );
        end
    endgenerate
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
            data_out = {(DATA_WIDTH){1'b0}};
        else if(ena)
            data_out = data_inter;
    end
endmodule
