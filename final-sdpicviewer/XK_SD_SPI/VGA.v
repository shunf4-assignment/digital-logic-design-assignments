`timescale 1ns / 1ps

module VGA(
    input CLK,
    input [11:0] douta,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output [16:0]addra
    );
    reg [10:0] x;
    reg [10:0] y;
    wire isRect;
    parameter H_pos = 56;
    parameter H_neg = 64;
    parameter H_vri = 800;
    parameter H_syn = 120;
    parameter V_pos = 37;
    parameter V_neg = 23;
    parameter V_vri = 600;
    parameter V_syn = 6;
    initial begin
        x = 0;
        y = 0;
    end
    wire _CLK;
    Divider #(2) Divider(
    .I_CLK(CLK),
    .Rst(0),
    .O_CLK(_CLK)
    );
    always@(posedge _CLK)begin
        if(x == H_pos + H_neg + H_vri + H_syn)begin
            x = 1;
            if(y == V_pos + V_neg + V_vri + V_syn)begin
                y = 1;
            end
            else y = y + 1;
        end
        else x = x + 1;
    end
    assign isRect = (x>H_pos+H_syn&&x<=H_pos+H_syn+H_vri&&y>V_pos+V_syn&&y<=V_pos+V_syn+V_vri);
    assign addra = isRect?((x-H_pos-H_syn)/2 + (y-V_pos-V_syn)/2*400 + 1):0;
    assign VGA_R = isRect?douta[11:8]:0;
    assign VGA_G = isRect?douta[7:4]:0;
    assign VGA_B = isRect?douta[3:0]:0;
    assign VGA_HS = (x <= H_syn)?1'b1:1'b0;
    assign VGA_VS = (y <= V_syn)?1'b1:1'b0;
endmodule
