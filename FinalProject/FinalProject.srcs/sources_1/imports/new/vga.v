`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/08 21:45:35
// Design Name: 
// Module Name: vga
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


module vga #(
    parameter H_VISI = 640,
    parameter H_FRPO = 16,
    parameter H_SYNP = 96,
    parameter H_BKPO = 48,
    parameter V_VISI = 480,
    parameter V_FRPO = 10,
    parameter V_SYNP = 2,
    parameter V_BKPO = 33
)
(
    input clk_100MHz,
    input rst,
    output clk,
    output hsync,
    output vsync,
    output [10:0] h_cnt,
    output [9:0] v_cnt,
    output inplace
    );
    localparam H_ALL = H_VISI + H_FRPO + H_SYNP + H_BKPO;
    localparam V_ALL = V_VISI + V_FRPO + V_SYNP + V_BKPO;
    localparam H_VISI_END = H_VISI;
    localparam H_FRPO_END = H_VISI + H_FRPO;
    localparam H_SYNP_END = H_VISI + H_FRPO + H_SYNP;
    localparam H_BKPO_END = H_VISI + H_FRPO + H_SYNP + H_BKPO;
    localparam V_VISI_END = V_VISI;
    localparam V_FRPO_END = V_VISI + V_FRPO;
    localparam V_SYNP_END = V_VISI + V_FRPO + V_SYNP;
    localparam V_BKPO_END = V_VISI + V_FRPO + V_SYNP + V_BKPO;

    vga_clkgen vgaclk1(
        clk_100MHz,
        ~rst,
        clk
    );
    
    reg [10:0] h_cnt_r = 0;
    reg [9:0] v_cnt_r = 0;
    reg hsync_r = 1;
    reg vsync_r = 1;
    reg h_inplace = 0;
    reg v_inplace = 0;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            h_cnt_r <= 0;
            v_cnt_r <= 0;
        end
        else begin
            if(h_cnt_r < H_VISI_END)begin
                h_cnt_r <= h_cnt_r + 1;
                h_inplace <= 1;
            end
            else if (h_cnt_r >= H_VISI_END && h_cnt_r < H_FRPO_END) begin
                h_cnt_r <= h_cnt_r + 1;
                h_inplace <= 0;
            end
            else if (h_cnt_r >= H_FRPO_END && h_cnt_r < H_SYNP_END) begin
                h_cnt_r <= h_cnt_r + 1;
                hsync_r <= 0;
            end
            else if (h_cnt_r >= H_SYNP_END && h_cnt_r < H_BKPO_END) begin
                h_cnt_r <= h_cnt_r + 1;
                hsync_r <= 1;
            end
            else if(h_cnt_r == H_BKPO_END)
            begin
                h_cnt_r <= 0;
                if(v_cnt_r < V_VISI_END)begin
                    v_cnt_r <= v_cnt_r + 1;
                    v_inplace <= 1;
                end
                else if (v_cnt_r >= V_VISI_END && v_cnt_r < V_FRPO_END) begin
                    v_cnt_r <= v_cnt_r + 1;
                    v_inplace <= 0;
                end
                else if (v_cnt_r >= V_FRPO_END && v_cnt_r < V_SYNP_END) begin
                    v_cnt_r <= v_cnt_r + 1;
                    vsync_r <= 0;
                end
                else if (v_cnt_r >= V_SYNP_END && v_cnt_r < V_BKPO_END) begin
                    v_cnt_r <= v_cnt_r + 1;
                    vsync_r <= 1;
                end
                else if(v_cnt_r == V_BKPO_END) begin
                    v_cnt_r <= 0;
                    v_inplace <= 1;
                end
                else begin
                    v_cnt_r <= 0;
                    v_inplace <= 0;
                    vsync_r <= 1;
                end
            end
            else begin
                h_cnt_r <= 0;
                h_inplace <= 1;
                hsync_r <= 1;
            end
        end
    end
    
    assign hsync = hsync_r;
    assign vsync = vsync_r;
    assign h_cnt = h_cnt_r;
    assign v_cnt = v_cnt_r;
    assign inplace = h_inplace && v_inplace;
endmodule
    