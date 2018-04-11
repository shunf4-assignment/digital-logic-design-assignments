`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/13 17:55:29
// Design Name: 
// Module Name: pcreg_board
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


module pcreg_board(
    input clk,
    input rst,
    input ena,
    input [15:0] data_in,
    output [15:0] data_out
    );
    reg freqdiv_clock;
    localparam DELAY_TOP = 32'd100000000;
    reg [31:0] cnt;
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
            cnt <= 32'b0;
        else if(cnt < DELAY_TOP-1'b1)
            cnt <= cnt + 1'b1;
        else
            cnt <= 32'd0;
    end
    
    always @ (clk)
    begin
        if(cnt == DELAY_TOP / 2)
            freqdiv_clock = 0;
        if(cnt == DELAY_TOP-1'b1)
            freqdiv_clock = 1;
    end
    
    pcreg #(.DATA_WIDTH(16)) pcreg_init (
        .clk(freqdiv_clock),
        .rst(rst),
        .ena(ena),
        .data_in(data_in),
        .data_out(data_out)
    );
endmodule
