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
    input [10:0] x,
    input [9:0] y,
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
    input in_clear,
    input in_err,
    input in_finished,

    output out_canwrite

    );

    //reg [11:0] img_ram [0:WIDTH * HEIGHT - 1];

    reg [4:0] ram_state;
    reg [18:0] ram_addra;
    reg [18:0] ram_addrb;
    reg ram_wea;
    reg [13:0] ram_dina;
    wire [13:0] ram_doutb;
    
    localparam S_CLR = 4;
    localparam S_STR = 5;
    localparam S_ERR = 6;

    //assign x = (h_cnt + 2) % WIDTH;
    //assign y = (h_cnt >= WIDTH - 2) ? ((v_cnt + 1) % HEIGHT) : (v_cnt);

    wire [3:0] err_color;
    assign err_color = ((ram_addra % WIDTH) << 4) / WIDTH;
    wire [3:0] clr_color;
    assign clr_color = ((ram_addra / WIDTH) << 4) / HEIGHT;


    
    always @(posedge clk)
    begin
        //ram_addrb <= (((x == 0) ? ((y + HEIGHT - 1) % HEIGHT) : (y)) * WIDTH + ((x + WIDTH - 1) % WIDTH));
        //ram_addrb <= (((h_cnt >= WIDTH - 1) ? ((v_cnt + 1) % HEIGHT) : (v_cnt)) * WIDTH + ((h_cnt + 1) % WIDTH));
        ram_addrb <= y * WIDTH + x;
        if(in_clear) begin
            ram_addra <= 0;
            ram_dina <= 0;
            ram_wea <= 0;
            ram_addrb <= 0;
            ram_state <= S_CLR;
        end else if(in_err)begin
            ram_addra <= 0;
            ram_dina <= 0;
            ram_wea <= 0;
            ram_addrb <= 0;
            ram_state <= S_ERR;
        end else case(ram_state)
            S_CLR:
            begin
                if(ram_addra == WIDTH * HEIGHT - 1) begin
                    ram_addra <= 0;
                    ram_state <= S_STR;
                    ram_wea <= 0;
                end else begin
                    ram_dina <= {2'h0, 4'h0,4'h0,clr_color};
                    ram_wea <= 1;
                    ram_addra <= ram_addra + 1;
                end
            end

            S_STR:
            begin
                ram_addra <= in_y * WIDTH + in_x;
                ram_dina <= {2'h0, in_r, in_g, in_b};                
                if(in_latch) begin
                    ram_wea <= 1;
                end else begin
                    ram_wea <= 0;
                end
            end

            S_ERR:
            begin
                
                if(ram_addra == WIDTH * HEIGHT - 1) begin
                    ram_addra <= 0;
                    ram_state <= S_STR;
                    ram_wea <= 0;
                end else begin
                    ram_dina <= {2'h0, err_color, 8'h0};
                    ram_wea <= 1;
                    ram_addra <= ram_addra + 1;
                end
            end

            default:
            begin
                ram_state <= S_STR;
            end
        endcase
    end

    always @(vga_clk) begin
        if(inplace)
            if(display_ena) begin
                r <= ram_doutb[11:8];
                g <= ram_doutb[7:4];
                b <= ram_doutb[3:0];
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
    
    vga_mem vga_mem_1 (
        .clka(clk),    // input wire clka
        .wea(ram_wea),      // input wire [0 : 0] wea
        .addra(ram_addra),  // input wire [18 : 0] addra
        .dina(ram_dina),    // input wire [13 : 0] dina
        .clkb(~clk),    // input wire clkb
        .addrb(ram_addrb),  // input wire [18 : 0] addrb
        .doutb(ram_doutb)  // output wire [13 : 0] doutb
    );

    assign out_canwrite = (ram_state == S_STR);
endmodule
