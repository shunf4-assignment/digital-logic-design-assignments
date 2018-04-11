`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 14:02:23
// Design Name: 
// Module Name: ram
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


module ram(
    input clk,
    input ena,
    input wena,
    input [4:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
    );


    reg [31:0] data_reg [0:31];
    initial begin
        $readmemh("testfile.mem", data_reg);
    end

    
    assign data_out = ena ? (wena ? 32'bz : data_reg[addr]) : 32'bz;

    always @(posedge clk) begin
        if(wena) begin
            data_reg[addr] = data_in;
        end
    end
endmodule
