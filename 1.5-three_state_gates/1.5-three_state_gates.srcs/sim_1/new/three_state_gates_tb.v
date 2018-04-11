`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/26 21:26:22
// Design Name: 
// Module Name: three_state_gates_tb
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


module three_state_gates_tb(

    );
    reg iA_tb, iEna_tb;
    wire oTri_tb;
    
    three_state_gates tsg_1 (
        .iA(iA_tb),
        .iEna(iEna_tb),
        .oTri(oTri_tb)
    );
    
    initial begin
        iA_tb = 0;
        #40 iA_tb = 1;
        #40 iA_tb = 0;
        #40 iA_tb = 1;
    end
    
    initial begin
        iEna_tb = 1;
        #20 iEna_tb = 0;
        #40 iEna_tb = 1;
        #20 iEna_tb = 0;
    end
endmodule
