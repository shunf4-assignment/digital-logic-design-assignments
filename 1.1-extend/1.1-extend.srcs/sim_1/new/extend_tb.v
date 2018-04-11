`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 22:47:53
// Design Name: 
// Module Name: extend_tb
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


module extend_tb(

    );
    reg [15:0] a_tb;
    reg sext_tb;
    wire [31:0] b_tb;
    
    //Instantiate the Unit_Under_Test
    extend uut (
        .a(a_tb),
        .sext(sext_tb),
        .b(b_tb)
    );
    
    initial begin
    //Initialize Inputs
        a_tb = 0;
        sext_tb = 0;
    //wait 100 ns for global reset to finish
        #100;
    //add stimulus
        sext_tb = 1;
        a_tb = 16'h0;
        #100;
        sext_tb = 0;
        a_tb = 16'h82a0;
        #100;
        sext_tb = 0;
        a_tb = 16'hffff;
        #100;
        sext_tb = 1;
        a_tb = 16'hffff;
        #100;
    end
endmodule
