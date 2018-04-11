`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 14:23:50
// Design Name: 
// Module Name: ram2
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


module ram2(
    input clk,
    input ena,
    input wena,
    input [4:0] addr,
    input [31:0] data
    );


    reg [31:0] data_reg [0:31];
    initial begin
        $readmemh("testfile.mem", data_reg);
    end

    
    assign data = ena ? (wena ? 32'bz : data_reg[addr]) : 32'bz;

    always @(posedge clk) begin
        if(wena) begin
            data_reg[addr] = data;
        end
    end
endmodule