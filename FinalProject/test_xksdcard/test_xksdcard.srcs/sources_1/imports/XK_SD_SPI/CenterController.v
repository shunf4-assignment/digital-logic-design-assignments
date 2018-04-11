`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/07 13:11:39
// Design Name: 
// Module Name: CenterController
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


module CenterController(
input CLK,
input BTNC,
input BTNU,
input BTNL,
input BTND,
input BTNR,
output [3:0] VGA_R,
output [3:0] VGA_G,
output [3:0] VGA_B,
output VGA_HS,
output VGA_VS,
output [15:0] LED,

output [7:0] AN,
output CA,
output CB,
output CC,
output CD,
output CE,
output CF,
output CG,

output SD_CS,
output SD_SCK,
output SD_DI,
input SD_DO,

output xCS,
output xDCS,
output xRSET,
input DREQ,
output SCLK,
output MOSI,
input MISO
    );
    reg RST = 0;
    wire[3:0] VOL;
    reg [15:0] DECODE_TIME = 75;
    LED_VOL LED_VOL(.VOL(VOL), .LED(LED));
    CMD_HAND CMD_HAND(
    .CLK(CLK),
    .RST(RST),
    .BTNC(BTNC),
    .BTNL(BTNL),
    .BTNR(BTNR),
    .BTNU(BTNU),
    .BTND(BTND),
    .VOL(VOL)
    );
    TIME_DIS TD(
    .CLK(CLK),
    .DECODE_TIME(DECODE_TIME),
    .AN(AN),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG)
    );
    
    //PIC
    reg [16:0]addra_in;
    wire[16:0]addra_out;
    reg wea = 0;
    reg rd;
    reg [23:0] dina;
    wire [11:0] douta;
    wire [7:0] data;
    wire byte_available;
    wire _CLK2;
    wire _CLK4;
    wire _CLK8;
    wire ready;
    Divider #(2) DV2(
    .I_CLK(CLK),
    .Rst(0),
    .O_CLK(_CLK2)
    );
    Divider #(2) DV4(
        .I_CLK(CLK),
        .Rst(0),
        .O_CLK(_CLK4)
    );
    Divider #(4) DV8(
        .I_CLK(CLK),
        .Rst(0),
        .O_CLK(_CLK8)
    );
    PIC_ROM PIC_ROM(
    .addra(wea?addra_in:addra_out),
    .clka(_CLK2),
    .wea(wea),
    .dina(dina),
    .douta(douta)
    );
    VGA VGA(
        .CLK(CLK), 
        .VGA_R(VGA_R), 
        .VGA_G(VGA_G), 
        .VGA_B(VGA_B), 
        .VGA_HS(VGA_HS), 
        .VGA_VS(VGA_VS),
        .douta(douta),
        .addra(addra_out)
        );
        reg[31:0]address;
        reg reset=0;
    SpiController SC(
    .SD_CS(SD_CS),
    .SD_DI(SD_DI),
    .SD_DO(SD_DO),
    .SD_SCK(SD_SCK),
    .rd(rd),
    .dout(data),
    .byte_available(byte_available),
    .reset(reset),
    .ready(ready),
    .address(address),
    .CLK(_CLK4)
    );
    /*sd_controller SC(
    .cs(SD_CS),
    .mosi(SD_DI),
    .miso(SD_DO),
    .sclk(SD_SCK),
    .rd(rd),
    .dout(data),
    .byte_available(byte_available),
    .reset(reset),
    .ready(ready),
    .address(address),
    .clk(_CLK4)
    );*/
    //status
    reg signed [31:0] byte_counter;
    reg[3:0]byte_three_counter;
    reg[9:0]block_size_counter;
    reg [4:0] state = 0;
    reg [4:0] return_state = 0;
    parameter INIT = 0;
    parameter READ_BYTE = 1;
    parameter READ_THREE_BYTE = 2;
    parameter CHANGE_BLOCK = 3;
    always@(posedge _CLK4)begin
        case(state)
            INIT:begin
                if(ready)begin
                    rd<=1;
                    wea<=0;
                    byte_counter<=180000;
                    block_size_counter<=511;
                    address<=32'h878000>>9;
                    addra_in<=-2;
                    byte_three_counter<=2;
                    state<=READ_THREE_BYTE;
                end
                else state<=INIT;
            end
            READ_BYTE:begin
                if(byte_counter<=0)begin
                    rd <= 0;
                    wea <= 0;
                end
                else begin
                    wea<=1;
                    rd<=1;
                    addra_in<=addra_in+2;
                    byte_counter<=byte_counter-3;
                    byte_three_counter<=2;
                    state <= READ_THREE_BYTE;
                end
            end
            READ_THREE_BYTE:begin
                wea<=0;
            if(byte_available)begin
                dina <= {data,dina[23:8]};
                if(byte_three_counter==0)begin
                    state<=READ_BYTE;
                    return_state<=READ_BYTE;
                end
                else begin
                    return_state<=READ_THREE_BYTE;
                    byte_three_counter<=byte_three_counter-1;
                end
                if(block_size_counter==0)begin
                    rd<=0;
                    state <=CHANGE_BLOCK;
                end
                else begin
                    rd<=1;
                    block_size_counter<=block_size_counter-1;
                end
            end
            end
            CHANGE_BLOCK:begin
                if(ready)begin
                    rd<=1;
                    address<=address+1;
                    block_size_counter<=511;
                    state<=return_state;
                end
                else state<=CHANGE_BLOCK;
            end
        endcase
    end
endmodule
