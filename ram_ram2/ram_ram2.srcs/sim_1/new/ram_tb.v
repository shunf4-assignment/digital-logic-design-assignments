`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/03 14:27:50
// Design Name: 
// Module Name: ram_tb
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


module ram_tb(

    );
    reg clk;
    
    reg ena;
    reg wena;
    
    reg [4:0] addr;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire [31:0] data;
    
    assign data_out = wena ? 'bz : data;
    assign data = wena ? data_in : 'bz;
    /*if uut is ram:
        data is always z, so data_out is assign to be z.
        thus we can directly connect data_in and data_out to the ram and see their results.
      if uut is ram2:
        data is assigned data_in when writing enabled;
        data is assigned by ram2 when reading enabled.
        thus we read result from data.
    */
    
    
    ram uut(clk, ena, wena, addr, data_in, data_out);
    //ram2 uut(clk, ena, wena, addr, data);
    
    initial begin
        clk = 0;
        ena = 0;
        wena = 0;
        addr = 5'd3;
        forever #10 clk = ~clk;
    end
    
    initial begin
        #25 ena = 1;
        //test reading
        #20
        $display("[5'd3] 0x%h == 0xfffffff3 ?", data_out);
        #20 //now you can check if [5'd3]==0xfffffff3
        addr = 5'h0f;
        #20
        $display("[5'h0f] 0x%h == 0xeeeeeee7 ?", data_out);
        
        
        //test writing
        #20
        data_in = 32'hddddddd4;
        addr = 5'd4;
        
        #20 
        $display("[5'd4] 0x%h == 0xfffffff4 ?", data_out);
        wena = 1;
        #20
        $display("read out [5'd4] 0x%h == 0xzzzzzzzz ?", data_out);
        wena = 0;
        #20
        $display("[5'd4] 0x%h == 0xddddddd4 ?", data_out);
        
    end
    
    
endmodule
