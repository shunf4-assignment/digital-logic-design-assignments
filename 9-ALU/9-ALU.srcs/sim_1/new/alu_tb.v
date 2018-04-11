`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 21:11:17
// Design Name: 
// Module Name: alu_tb
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


module alu_tb(

    );
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] aluc;
    wire signed [31:0] r;
    wire [31:0] ru;
    wire zero;
    wire carry;
    wire negative;
    wire overflow;
    wire [3:0] flags;
    
    assign ru = r;
    assign flags = {zero, carry, negative, overflow};
    
    alu uut(
        a, b, aluc, r, zero, carry, negative, overflow
    );
    
    initial begin
        
        #10
        //Test Add
        aluc = 4'b0010;

        a = 32'd9;
        b = 32'd8;
        #3
        $display("r==%d==17, flags==%b==0000", r, flags);
        #10
        a = 32'd32777788;
        b = 32'd2114705860;
        #3
        $display("r==%d==-2147483648, flags==%b==0011", r, flags);
        #10
        a = -32'd10000;
        b = 32'd10000;
        #3
        $display("r==%d==0, flags==%b==1000", r, flags);
        #10
        a = -32'd32777788;
        b = -32'd2114705860;
        #3
        $display("r==%d==-2147483648, flags==%b==0010", r, flags);
        #20
        
        //Test Addu
        aluc = 4'b0000;

        a = 32'd9;
        b = 32'd8;
        #3
        $display("r==%d==17, flags==%b==0000", ru, flags);
        a = -1;         //2**32 - 1
        b = 2;
        #3
        $display("r==%d==1, flags==%b==0100", ru, flags);
        a = -32'd10000;
        b = 32'd10000;
        #3
        $display("r==%d==0, flags==%b==1100", ru, flags);
        a = -32'd32777788;    //positive
        b = -32'd2114705860;    //positive
        #3
        $display("r==%d==2147483648, flags==%b==0110", ru, flags);
        
        //Test Sub
        aluc = 4'b0011;

        a = 32'd9;
        b = 32'd8;
        #3
        $display("r==%d==1, flags==%b==0100", r, flags);
        a = -1;
        b = 2;
        #3
        $display("r==%d==-3, flags==%b==0110", r, flags);
        a = -2147483648;
        b = 1;
        #3
        $display("r==%d==2147483647, flags==%b==0101", r, flags);
        a = -32'd10000;
        b = -32'd10000;
        #3
        $display("r==%d==0, flags==%b==1100", r, flags);
        a = 32'd32777788;
        b = -32'd2114705860;
        #3
        $display("r==%d==-2147483648, flags==%b==0111", r, flags);
        
        //Test Subu
        aluc = 4'b0001;

        a = 32'd9;
        b = 32'd8;
        #3
        $display("r==%d==1, flags==%b==0001", ru, flags);
        a = 0;
        b = 1;
        #3
        $display("r==%d==4294967295, flags==%b==0111", ru, flags);
        a = -32'd10000;
        b = -32'd10000;
        #3
        $display("r==%d==0, flags==%b==1001", r, flags);
        
        //Test And
        aluc = 4'b0100;

        a = 32'b01111001010111100001110000100001;
        b = 32'b11110000011101111100000110111101;
        //      01110000010101100000000000100001
        #3
        $display("r==%b==01110000010101100000000000100001, flags==%b==0001", ru, flags);

        //Test Or
        aluc = 4'b0101;

        a = 32'b01111001010111100001110000100001;
        b = 32'b11110000011101111100000110111101;
        //      11111001011111111101110110111101
        #3
        $display("r==%b==11111001011111111101110110111101, flags==%b==0011", ru, flags);
        
        //Test Xor
        aluc = 4'b0110;

        a = 32'b01111001010111100001110000100001;
        b = 32'b11110000011101111100000110111101;
        //      10001001001010011101110110011100
        #3
        $display("r==%b==10001001001010011101110110011100, flags==%b==0011", ru, flags);
        
        //Test Nor
        aluc = 4'b0111;

        a = 32'b01111001010111100001110000100001;
        b = 32'b11110000011101111100000110111101;
        //      00000110100000000010001001000010
        #3
        $display("r==%b==00000110100000000010001001000010, flags==%b==0001", ru, flags);
        
        //Test Lui
        aluc = 4'b1001;

        a = 32'b01111001010111100001110000100001;
        b = 32'b11110000011101111100000110111101;
        //      00000110100000000010001001000010
        #3
        $display("r==%b==11000001101111010000000000000000, flags==%b==0011", ru, flags);

        //Test Slt
        aluc = 4'b1011;

        a = -32'd1;
        b = 5;

        #3
        $display("r==%d==1, flags==%b==0011", ru, flags);
        
        a = 5;
        b = 5;

        #3
        $display("r==%d==0, flags==%b==1001", ru, flags);
        
        //Test Sltu
        aluc = 4'b1010;

        a = -32'd1;
        b = 5;

        #3
        $display("r==%d==0, flags==%b==1001", ru, flags);
        
        a = 5;
        b = 5;

        #3
        $display("r==%d==0, flags==%b==1001", ru, flags);

        //Test Shift
        aluc = 4'b1100;

        a = 32'd5;
        b = 32'b11110000011101111100000110111101;
        //      00000110100000000010001001000010
        #3
        $display("r==%b==11111111100000111011111000001101, flags==%b==0111", ru, flags);
        
        aluc = 4'b1101;
        
        a = 32'd5;
        b = 32'b11110000011101111100000110101101;
        //      00000110100000000010001001000010
        #3
        $display("r==%b==00000111100000111011111000001101, flags==%b==0001", ru, flags);

        aluc = 4'b1110;
        
        a = 32'd5;
        b = 32'b11111000011101111100000110101101;
        //      00000110100000000010001001000010
        #3
        $display("r==%b==00001110111110000011010110100000, flags==%b==0101", ru, flags);

end
endmodule
