`timescale 1ns / 1ps

module SpiController(
    output reg SD_CS, 
    output SD_DI, 
    input SD_DO,
    output SD_SCK, 
    input rd,
    output reg [7:0] dout,
    output reg byte_available,
    input reset,
    output ready,
    input [31:0] address, 
    input CLK
    );
    
//status
    parameter RST=0;//复位
    parameter INIT=1;//初始化
    parameter CMD0=2;//发送CMD0
    parameter CMD55=3;//发送CMD55
    parameter CMD41=4;//发送CMD41
    parameter POLL_CMD=5;
    parameter IDLE=6;
    parameter READ_BLOCK=7;
    parameter READ_BLOCK_WAIT=8;
    parameter READ_BLOCK_DATA=9;
    parameter READ_BLOCK_CRC=10;
    parameter SEND_CMD=11;
    parameter RECEIVE_BYTE_WAIT=12;
    parameter RECEIVE_BYTE=13;  
    parameter FREE_CLOCK=14;  
    
        reg [4:0] state = RST;
        reg [4:0] return_state;
        reg sclk_sig = 0;
        reg [55:0] cmd_out;
        reg [7:0] recv_data;
        reg cmd_mode = 1;
        reg [7:0] data_sig = 8'hFF;
        
        reg [9:0] byte_counter;
        reg [9:0] bit_counter;
        reg [4:0]freeclocks=8;
        reg [26:0] boot_counter = 27'd100_000_000;
    always@(posedge CLK)begin
        if(reset)begin
            state <= RST;
            sclk_sig <= 0;
            boot_counter <= 27'd100_000_000;
        end
        else case(state)
            RST: begin
                if(boot_counter == 0) begin
                    sclk_sig <= 0;
                    cmd_out <= {56{1'b1}};
                    byte_counter <= 0;
                    byte_available <= 0;
                    cmd_mode <= 1;
                    bit_counter <= 160;
                    SD_CS <= 1;
                    state <= INIT;
                end
                else begin
                    boot_counter <= boot_counter - 1;
                end
            end
            
            INIT: begin
                if(bit_counter == 0) begin
                    SD_CS <= 0;
                    state <= CMD0;
                end
                else begin
                    bit_counter <= bit_counter - 1;
                    sclk_sig <= ~sclk_sig;
                end
            end
            
            CMD0:begin
                cmd_out <= 56'hFF_40_00_00_00_00_95;
                bit_counter <= 55;
                return_state <= CMD55;
                state <= SEND_CMD;
            end
            
            CMD55:begin
                cmd_out <= 56'hFF_77_00_00_00_00_01;
                bit_counter <= 55;
                return_state <= CMD41;
                state <= SEND_CMD;
            end
            
            CMD41:begin
                cmd_out <= 56'hFF_69_00_00_00_00_01;
                bit_counter <= 55;
                return_state <= POLL_CMD;
                state <= SEND_CMD;
            end
            
            POLL_CMD:begin
                if(recv_data[0] == 0) begin
                    state <= IDLE;
                end
                else begin
                    state <= CMD55;
                end 
            end
            
            IDLE:begin
                if(rd)begin
                     SD_CS <= 0;
                    state <= READ_BLOCK;
                end
                else begin
                     SD_CS <= 1;
                    state <= IDLE;
                end
            end
            
            READ_BLOCK: begin
                SD_CS <= 0;
                cmd_out <= {16'hFF_51, address, 8'hFF};
                bit_counter <= 55;
                return_state <= READ_BLOCK_WAIT;
                state <= SEND_CMD;
            end
            
            READ_BLOCK_WAIT: begin
                if(sclk_sig == 1 && SD_DO == 0) begin
                    byte_counter <= 511;
                    bit_counter <= 7;
                    return_state <= READ_BLOCK_DATA;
                    state <= RECEIVE_BYTE;
                end
                sclk_sig <= ~sclk_sig;
            end
            READ_BLOCK_DATA: begin
                dout <= recv_data;
                byte_available <= 1;
                if (byte_counter == 0) begin
                    bit_counter <= 7;
                    return_state <= READ_BLOCK_CRC;
                    state <= RECEIVE_BYTE;
                end
                else begin
                    byte_counter <= byte_counter - 1;
                    return_state <= READ_BLOCK_DATA;
                    bit_counter <= 7;
                    state <= RECEIVE_BYTE;
                end
            end
            READ_BLOCK_CRC: begin
                bit_counter <= 15;
                freeclocks<=7;
                return_state <= FREE_CLOCK;
                state <= RECEIVE_BYTE;
            end
            FREE_CLOCK:begin
                if(sclk_sig==1)begin
                    if(freeclocks==0)begin
                        state<=IDLE;
                    end
                    else begin
                        freeclocks<=freeclocks-1;
                    end
                end
                sclk_sig<=~sclk_sig;
            end
            SEND_CMD: begin
                if (sclk_sig == 1) begin
                    if (bit_counter == 0) begin
                        state <= RECEIVE_BYTE_WAIT;
                    end
                    else begin
                        bit_counter <= bit_counter - 1;
                        cmd_out <= {cmd_out[54:0], 1'b1};
                    end
                end
                sclk_sig <= ~sclk_sig;
            end
            RECEIVE_BYTE_WAIT: begin
                if (sclk_sig == 1) begin
                    if (SD_DO == 0) begin
                        recv_data <= 0;
                        bit_counter <= 6;
                        state <= RECEIVE_BYTE;
                    end
                end
                sclk_sig <= ~sclk_sig;
            end
            RECEIVE_BYTE: begin
                byte_available <= 0;
                if (sclk_sig == 1) begin
                    recv_data <= {recv_data[6:0], SD_DO};
                    if (bit_counter == 0) begin
                        state <= return_state;
                    end
                    else begin
                        bit_counter <= bit_counter - 1;
                    end
                end
                sclk_sig <= ~sclk_sig;
            end
        endcase
    end
    assign SD_SCK = sclk_sig;
    assign SD_DI = cmd_out[55];
    assign ready = (state==IDLE);
endmodule
