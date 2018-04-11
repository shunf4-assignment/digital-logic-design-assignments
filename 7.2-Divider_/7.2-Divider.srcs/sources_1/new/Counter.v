`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/20 10:05:41
// Design Name: 
// Module Name: Counter
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

function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
endfunction

module Counter #(
    parameter max_Num = 20
)(CLK, ld_n, oCLK);
    input CLK;
    input ld_n;
    localparam digits = clogb2(max_Num);
    
    wire [digits:0] productOfBefore;
    wire [digits - 1:0] preset = 2**digits - max_Num;
    wire [digits:0] oQ;
    
    output oCLK;
    assign oCLK = oQ[digits];

    wire needPreset = ~ld_n | productOfBefore[digits];
    
    generate
        genvar i;
        for (i = 0; i < digits; i = i+1)
        begin : jks
            assign productOfBefore[i] = (i == 0)?1:(productOfBefore[i-1] & oQ[i-1]);
            Sync_JK_FF u_jk(
                .CLK(CLK),
                .J((needPreset)?preset[i]:productOfBefore[i]),
                .K((needPreset)?~preset[i]:productOfBefore[i]),
                .RST(0),
                .Q(oQ[i])
            );
        end
    endgenerate
    assign productOfBefore[digits] = productOfBefore[digits-1] & oQ[digits-1];
    Sync_JK_FF last_jk(
        .CLK(CLK),
        .J(productOfBefore[digits]),
        .K(productOfBefore[digits]),
        .RST(0),
        .Q(oQ[digits])
    );
endmodule

module Counter_odd #(
    parameter max_Num = 20
)(CLK, ld_n, oCLK);
    input CLK;
    input ld_n;
    localparam digits = cblog2(max_Num);
    
    wire [digits:0] productOfBefore;
    wire [digits - 1:0] preset = 2**digits - max_Num;
    wire [digits:0] oQ;
    reg allEnable = 1;
    
    output oCLK;
    assign oCLK = oQ[digits];

    wire needPreset = ~ld_n | productOfBefore[digits];
    
    
    Sync_JK_FF sleepJK(
        .CLK(~CLK),
        .J(productOfBefore[digits] & allEnable & (oQ[digits]==0)),
        .K(~(productOfBefore[digits] & allEnable & (oQ[digits]==0))),
        .RST(0),
        .Q(allEnable)
    );
    
    generate
        genvar i;
        for (i = 0; i < digits; i = i+1)
        begin : jks
            assign productOfBefore[i] = (i == 0)?1:(productOfBefore[i-1] & oQ[i-1]);
            Sync_JK_FF u_jk(
                .CLK(CLK),
                .J(allEnable & ((needPreset)?preset[i]:productOfBefore[i])),
                .K(allEnable & ((needPreset)?~preset[i]:productOfBefore[i])),
                .RST(0),
                .Q(oQ[i])
            );
        end
    endgenerate
    assign productOfBefore[digits] = productOfBefore[digits-1] & oQ[digits-1];
    Sync_JK_FF last_jk(
        .CLK(CLK),
        .J(allEnable & (productOfBefore[digits])),
        .K(allEnable & (productOfBefore[digits])),
        .RST(0),
        .Q(oQ[digits])
    );
endmodule

