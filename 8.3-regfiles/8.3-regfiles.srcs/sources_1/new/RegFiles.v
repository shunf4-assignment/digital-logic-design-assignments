`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 20:07:46
// Design Name: 
// Module Name: RegFiles
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


module Regfiles(
    input clk,
    input rst,
    input we,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
    );
    wire [1023:0] pcreg_out;
    wire [31:0] pcreg_selected;
    wire [31:0] rdata1_temp;
    wire [31:0] rdata2_temp;
    
    decoder #(5) addr_decode(
        .iData(waddr),
        .iEna({we,1'b0}),
        .oData(pcreg_selected)
    );
    
    generate
        genvar i;
        genvar j;
        
        for(i=0;i<32;i=i+1)
        begin : wordgen
            pcreg #(32) word
            (
                .clk(~clk),
                .rst(rst),
                .ena(pcreg_selected[i]),
                .data_in(wdata),
                .data_out(pcreg_out[32 * i +: 32])
            );
        end
    endgenerate
    
    selector #(32, 32, 5) addr_sel1
    (
        .iC(pcreg_out),
        .iS(raddr1),
        .oZ(rdata1_temp)
    );
    
    selector #(32, 32, 5) addr_sel2
    (
        .iC(pcreg_out),
        .iS(raddr2),
        .oZ(rdata2_temp)
    );
    
    assign rdata1 = we ? 'bz : rdata1_temp;
    assign rdata2 = we ? 'bz : rdata2_temp;
        
endmodule
