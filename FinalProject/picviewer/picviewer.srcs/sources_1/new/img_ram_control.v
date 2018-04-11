`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/26 11:02:33
// Design Name: 
// Module Name: img_ram_control
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


module img_ram_control #(
    parameter WIDTH = 720,
    parameter HEIGHT = 400
)(
    input clk,
    input vga_clk,
    input [10:0] h_cnt,
    input [9:0] v_cnt,
    input vsync,
    input inplace,
    input display_ena,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b,

    input [10:0] in_x,
    input [10:0] in_y,
    input [3:0] in_r,
    input [3:0] in_g,
    input [3:0] in_b,
    input in_latch,
    input in_finished

    );

    reg [11:0] img_ram [0:WIDTH * HEIGHT - 1];

    wire vga_clk_d1, vga_clk_d2;

    shift_clockdelay #(5) clkdelay1
    (
        vga_clk,
        vga_clk_d1
    );

    shift_clockdelay #(10) clkdelay2
    (
        vga_clk,
        vga_clk_d2
    );

    reg [4:0] ram_state;
    reg [31:0] ram_index;
    parameter S_CLR = 4;
    parameter S_STR = 5;
    always @(posedge clk)
    begin
        if(in_finished) begin
            ram_index <= 0;
            ram_state <= S_CLR;
        end else case(ram_state)
            S_CLR:
            begin
                img_ram[ram_index] <= 12'h000;
                if(ram_index == WIDTH * HEIGHT - 1) begin
                    ram_index <= 0;
                    ram_state <= S_STR;
                end else begin
                    ram_index <= ram_index + 1;
                end
            end

            S_STR:
            begin
                if(in_latch) begin
                    img_ram[in_y * WIDTH + in_x] <= {in_r, in_g, in_b};
                end
            end

            default:
            begin
                ram_state <= S_STR;
            end
        endcase
    end

    wire [10:0] x;
    wire [9:0] y;

    assign x = h_cnt;
    assign y = v_cnt;

    always @(posedge vga_clk) begin
        if(inplace)
            if(display_ena) begin
                r <= img_ram[y * WIDTH + x][11:8];
                g <= img_ram[y * WIDTH + x][7:4];
                b <= img_ram[y * WIDTH + x][3:0];
            end else begin
                r <= 4'h0;
                g <= 4'h0;
                b <= 4'h0;
            end
        else begin
            r <= 4'hz;
            g <= 4'hz;
            b <= 4'hz;
        end
    end
endmodule
