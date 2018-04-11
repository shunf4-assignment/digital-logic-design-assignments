`timescale 1ns / 1ns
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 08:14:15
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output [31:0] r,
    output reg zero = 0,
    output reg carry = 0,
    output reg negative = 0,
    output reg overflow = 0
    );
    wire [127:0] selList1;
    wire [63:0] selList2;
    wire [127:0] selList3;
    
    wire [7:0] zero_set, carry_set, negative_set, overflow_set;
    
    addsub32 u1(.a(a), .b(b), .aluc(aluc[1:0]), .r(selList3[31:0]), .carry(carry_set[0]), .zero(zero_set[0]), .negative(negative_set[0]), .overflow(overflow_set[0]));
    and_ u2(.a(a), .b(b), .r(selList1[31:0]), .zero(zero_set[1]), .negative(negative_set[1]));
    or_ u3(.a(a), .b(b), .r(selList1[63:32]), .zero(zero_set[2]), .negative(negative_set[2]));
    xor_ u4(.a(a), .b(b), .r(selList1[95:64]), .zero(zero_set[3]), .negative(negative_set[3]));
    nor_ u5(.a(a), .b(b), .r(selList1[127:96]), .zero(zero_set[4]), .negative(negative_set[4]));
    lui u6(.b(b), .r(selList2[31:0]), .zero(zero_set[5]), .negative(negative_set[5]));
    slt u7(.a(a), .b(b), .r(selList2[63:32]), .aluc(aluc[0]), .zero(zero_set[6]), .negative(negative_set[6]), .carry(carry_set[6]));
    bshifter32_carry u8(.a(a[4:0]), .b(b), .r(selList3[127:96]), .aluc(aluc[1:0]), .zero(zero_set[7]), .negative(negative_set[7]), .carry(carry_set[7]));
    
    selector #(32,4,2) selector1(selList1, aluc[1:0], selList3[63:32]);
    selector #(32,2,1) selector2(selList2, aluc[1], selList3[95:64]);
    selector #(32,4,2) selector3(selList3, aluc[3:2], r);

    wire [2:0] currMode;
    assign currMode = (aluc[3:2]==2'b00)?0:(aluc[3:2]==2'b11)?7:(aluc[3:1]==3'b100)?5:(aluc[3:1]==3'b101)?6:(aluc[2:0]-3);

    always @(zero_set or carry_set or negative_set or overflow_set)
    begin
        if(zero_set[currMode] !== 1'bz) begin
            zero = zero_set[currMode];
        end
        
        if(carry_set[currMode] !== 1'bz) begin
            carry = carry_set[currMode];
        end
        
        if(negative_set[currMode] !== 1'bz) begin
            negative = negative_set[currMode];
        end
            
        if(overflow_set[currMode] !== 1'bz) begin
            overflow = overflow_set[currMode];

        end
    end
endmodule
