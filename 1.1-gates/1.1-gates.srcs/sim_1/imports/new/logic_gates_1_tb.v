`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/25 09:34:11
// Design Name: 
// Module Name: logic_gates_1_tb
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

module logic_gates_1_tb(
    );
    reg iA;
    reg iB;
    wire oAnd;
    wire oOr;
    wire oNot;
    
    logic_gates_1 logic_gates_1_inst(
        .iA(iA),
        .iB(iB),
        .oAnd(oAnd),
        .oOr(oOr),
        .oNot(oNot)
    );
    
    initial begin
        iA = 0;
        #40 iA = 1;
        #40 iA = 0;
        #40 iA = 1;
        #40 iA = 0;
    end
        
    initial begin
        iB = 0;
        #40 iB = 0;
        #40 iB = 1;
        #40 iB = 1;
        #40 iB = 0;
    end
    

endmodule
