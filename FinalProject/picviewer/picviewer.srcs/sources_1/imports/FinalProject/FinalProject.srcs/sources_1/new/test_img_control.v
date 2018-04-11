`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/11 17:15:17
// Design Name: 
// Module Name: test_img_control
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

module shift_clockdelay #(
    parameter DELAYBITS = 10
) (
    input clk_original,
    output clk_delayed
);
    //if(DELAYBITS >= 2) begin
        reg [DELAYBITS-2:0] delaystore;
        wire clk_buf;
        assign clk_buf = clk_original;
        always @(clk_original) begin
            delaystore[0] = clk_buf;
            if(DELAYBITS > 2)
                delaystore[DELAYBITS-2 : 1] = delaystore[DELAYBITS-3 : 0];
        end
        assign clk_delayed = delaystore[DELAYBITS-2];
//    end else if (DELAYBITS == 1) begin
//        reg delaystore1;
//        wire clk_buf;
//        assign clk_buf = clk_original;
//        always @(clk_original) begin
//            delaystore1 = clk_buf;
//        end
//        assign clk_delayed = delaystore1;
//    end
endmodule

module test_img_control #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480,
    parameter PICWIDTH = 512,
    parameter PICHEIGHT = 384
)(
    input clk,
    input [10:0] h_cnt,
    input [9:0] v_cnt,
    input vsync,
    input inplace,
    input display_ena,
    input movement_ena,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b
    );
    
    wire signed [10:0] x_onpic;
    wire signed [9:0] y_onpic;
    wire [17:0] addr;
    wire signed [10:0] x;
    wire signed [9:0] y;
    
    reg [10:0] offset_x = 0;
    reg [9:0] offset_y = 0;
    wire [31:0] calculate0;
    wire [31:0] calculate1;
    reg [31:0] k = 100;      //k=100: original pic, k=0: zoomed pic
    
    assign x = (h_cnt + offset_x) % WIDTH;
    assign y = (v_cnt + offset_y) % HEIGHT;
    
    assign calculate0 = (100 - k) * PICWIDTH / 200 + (k * PICWIDTH * x) / 100 / WIDTH;
    assign calculate1 = (100 - k) * PICHEIGHT / 200 + (k * PICHEIGHT * y) / 100 / HEIGHT;
    
//    assign calculate0 = (PICWIDTH * x) / WIDTH;
//    assign calculate1 = (PICHEIGHT * y) / HEIGHT;
    
    assign x_onpic = calculate0[10:0];
    assign y_onpic = calculate1[9:0];

    assign addr = (y_onpic * PICWIDTH + x_onpic - 1);
    
    wire [23:0] pixel_rgb;
    wire clk_delayed_5, clk_delayed_10;
    
    shift_clockdelay #(5) clkdelay5
    (
        clk,
        clk_delayed_5
    );
        
    shift_clockdelay #(10) clkdelay10
    (
        clk,
        clk_delayed_10
    );
    
    pic_blk_mem_testcard picrom (
      .clka(clk_delayed_5),    // input wire clka
      .addra(addr),  // input wire [17 : 0] addra
      .douta(pixel_rgb)  // output wire [15 : 0] douta
    );
    
    reg [3:0] r_r;
    reg [3:0] g_r;
    reg [3:0] b_r;
    
    always @(posedge clk) begin
        if(inplace)
            if(display_ena) begin
                r_r <= pixel_rgb[23:20];
                g_r <= pixel_rgb[15:12];
                b_r <= pixel_rgb[7:4];
            end else begin
                r_r <= 4'h0;
                g_r <= 4'hf;
                b_r <= 4'h0;
            end
        else begin
            r_r <= 4'hZ;
            g_r <= 4'hZ;
            b_r <= 4'hZ;
        end
    end
    
    reg [1:0] state = 0;

    
    always @(negedge vsync) begin
        if(movement_ena)
        if(state == 0) begin
            //X-OFFSET
            if(offset_x >= 0 && offset_x < WIDTH) begin
                offset_x <= offset_x + 1;
            end else offset_x <= 0;
            
            if(offset_x == WIDTH) begin
                state <= 1;
                offset_x <= 0;
            end
        end
        else if(state == 1) begin
            //Y-OFFSET
            if(offset_y >= 0 && offset_y < HEIGHT) begin
                offset_y <= offset_y + 1;
            end else offset_y <= 0;
            
            if(offset_y == HEIGHT) begin
                state <= 2;
                offset_y <= 0;
            end
        end
        else if(state == 2) begin
            //ZOOM-IN
            if(k <= 100 && k > 50) begin
                k <= k - 1;
            end else begin
                k <= 50;
                state <= 3;
            end
        end
        else if(state == 3) begin
            //ZOOM-OUT
            if(k < 100 && k >= 50) begin
                k <= k + 1;
            end else begin
                k <= 100;
                state <= 0;
            end
        end
    end

    assign r = r_r;
    assign g = g_r;
    assign b = b_r;
    
endmodule
