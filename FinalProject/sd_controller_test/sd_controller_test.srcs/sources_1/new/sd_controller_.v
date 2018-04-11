`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/17 19:28:28
// Design Name: 
// Module Name: sd_controller
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

/* -------- SD ����������ɳ�ʼ������ -------- */

module sd_controller(
        input clk,  //system clk - 100MHz
        input rst,

/* ---- EN & DONE SIGNALS FOR SD_CONTROLLER ---- */
        input en_start,  //this EN is for SD, no SPI
        output done_start,

        input en_read,
        output done_read,
        output [7:0] data_read,
        output reg data_read_valid,

        input done_clk74, //From SPI
        output en_clk74,  //To SPI

        input done_tx,    //From SPI, Transmission to SD Finished.
        output en_tx,     //To SPI
        output [7:0] data_tx,   //Ҫ���з��͵��ֽ�

        input done_rx,
        output en_rx,
        input [7:0] data_rx,

        input done_clk8,
        output en_clk8,

        output cmd0_r_ok,
        output cmd1_r_ok,

        output wire sd_idle
    );

    //S for state
    parameter S_RESET = 5'b11111;
    parameter S_DELAY = 5'd0;
    parameter S_CLK74 = 5'd1;
    parameter S_TXCMD0 = 5'd2;
    parameter S_TXCMD0R = 5'd3;
    parameter S_TXCMD0R_VALID = 5'd4;
    parameter S_TXCMD1 = 5'd5;
    parameter S_TXCMD1R = 5'd6;
    parameter S_TXCMD1R_VALID = 5'd7;
    parameter S_IDLE = 5'd20;
    parameter S_8CLK = 5'd21;
    parameter S_TXCMD = 5'd22;
    parameter S_RXIFIS = 5'd23;
    parameter S_READ_CMD = 5'd8;
    parameter S_READ_WAIT = 5'd9;


    parameter CMD0 = {2'b01, 6'h0, 32'h0, 8'h95}; 
    parameter CMD1 = {2'b01, 6'h1, 32'h0, 8'hFF}; 
    parameter CMD0_R = 8'h01;
    parameter CMD1_R = 8'h00;
    
    parameter T_DELAYTICKS = 12'd4000;        //40us
    parameter T_RESPMAXCNT = 8'd100;

    reg [4:0] state = 5'h0;
    reg [4:0] nextstate = 5'h0;
    reg [4:0] retrystate = 5'h0;
    reg [47:0] command_buffer = 48'h0;      //�洢�����6�ֽ�
    reg [2:0] command_bytecnt = 3'h0;       //��ʾ��ǰ����������ĵڼ����ֽ�(MSBΪ��)
    reg [7:0] resp_expected = 8'd0;

    //�ϵ��ӳټ�����
    
    reg [11:0] rDelayCnt = 0;
    always @(posedge clk or posedge rst)
    begin
        if(rst || rDelayCnt == T_DELAYTICKS - 1)
        begin
            rDelayCnt <= 0;
        end else if (en_start) begin
            rDelayCnt <= rDelayCnt + 1;
        end else begin
            rDelayCnt <= 0;
        end
    end

    reg ren_clk74 = 0;
    reg ren_tx = 0;
    reg ren_clk8 = 0;
    reg rcmd0_r_ok = 0;
    reg rcmd1_r_ok = 0;
    reg rdone_start = 0;
    reg [7:0] rdata_tx = 8'b11111111;
    reg [7:0] rRespCnt = 8'd0;


    //״̬�������� �ϵ��ӳ� - 74ʱ�ӵδ� - ��CMD0 - ��CMD0R - ��CMD1 - ��CMD1R �����£�
    //�˺󣬸�������������ת��״̬������ʵ�ֶ�ȡ��д�빦��
    always @(posedge clk or posedge rst)
    begin
        if(rst || (en_start && state == S_RESET)) begin
            state <= S_DELAY;
            rDelayCnt <= 0;
            ren_clk74 <= 1'b0;
            command_buffer <= 0;
            command_bytecnt <= 0;
            rcmd0_r_ok <= 0;
            rcmd1_r_ok <= 0;
            resp_expected <= 8'hf0;
            nextstate <= 0;
            retrystate <= 0;
            ren_clk8 <= 1'b0;
            ren_rx <= 0;
            ren_tx <= 0;
            rRespCnt <= 8'd0;
            rdone_start <= 0;
        end
        else if (en_start) begin
            case (state)
                S_DELAY:
                    if(rDelayCnt >= T_DELAYTICKS - 1)   //�ϵ��ӳٽ���
                        state <= state + 1;
                
                S_CLK74:
                    if(done_clk74) begin
                        ren_clk74 <= 1'b0;
                        state <= state + 1;
                    end
                    else ren_clk74 <= 1'b1;

                S_TXCMD0:
                    begin
                        command_buffer <= CMD0;
                        command_bytecnt <= 0;
                        nextstate <= S_TXCMD0R;
                        state <= S_TXCMD;
                    end

                S_TXCMD0R:
                begin
                    rcmd0_r_ok <= 1'b0;
                    resp_expected <= CMD0_R;
                    nextstate <= S_TXCMD0R_VALID;
                    retrystate <= S_TXCMD0;
                end

                S_TXCMD0R_VALID:
                begin
                    rcmd0_r_ok <= 1'b1;
                    nextstate <= TXCMD1;
                    state <= S_8CLK;
                end

                S_8CLK:
                    if(done_clk8) begin
                        ren_clk8 <= 1'b0;
                        state <= nextstate;
                    end else begin
                        ren_clk8 <= 1'b1;
                    end

                S_TXCMD1:
                    begin
                        command_buffer <= CMD1;
                        command_bytecnt <= 0;
                        nextstate <= S_TXCMD1R;
                        state <= S_TXCMD;
                    end

                S_TXCMD1R:
                begin
                    rcmd1_r_ok <= 1'b0;
                    resp_expected <= CMD1_R;
                    nextstate <= S_TXCMD1R_VALID;
                    retrystate <= S_TXCMD1;
                end

                S_TXCMD1R_VALID:
                begin
                    rcmd1_r_ok <= 1'b1;
                    nextstate <= S_IDLE;
                    state <= S_8CLK;
                end

                S_IDLE:
                begin
                    rdone_start = 1'd1;
                    state <= S_IDLE;
                end
                    
                S_RXIFIS:
                    if(done_rx) begin
                        //��ȡ��ɣ�������ȡ�����ֽ��ǲ���resp_expected
                        ren_rx <= 0;
                        if(data_rx == resp_expected) begin
                            rRespCnt <= 8'd0;
                            state <= nextstate;
                        end else begin
                            if(rRespCnt == T_RESPMAXCNT) begin
                                //��ʱ��
                                rRespCnt <= 0;
                                state <= retrystate;
                            end else begin
                                rRespCnt <= rRespCnt + 1'b1;
                            end
                        end
                    end else begin
                        ren_rx <= 1;
                    end

                S_TXCMD:
                    if(done_tx) begin
                        if(command_bytecnt == 'd5) begin
                            //command �������
                            command_bytecnt <= 0;
                            ren_tx <= 1'b0;
                            state <= nextstate;
                        else begin
                            //command ����һ���ֽ�
                            ren_tx <= 1'b1;
                            command_bytecnt <= command_bytecnt + 1;
                        end
                    else begin
                        //command_buffer <= CMD0;
                        rdata_tx <= command_buffer[(5 - command_bytecnt) * 8 +: 8];
                        ren_tx <= 1'b1;
                    end

                S_READ_CMD:
                    begin
                        command_buffer <= CMD17;
                        command_bytecnt <= 0;
                        nextstate <= S_READ_WAIT;
                        state <= S_TXCMD;
                    end
                default:
                begin
                    state <= S_RESET;
                end
                    
            endcase
        end

    end

    assign done_start = rdone_start;
    assign en_clk74 = ren_clk74;
    assign en_tx = ren_tx;
    assign data_tx = rdata_tx;
    assign en_rx = ren_rx;
    assign en_clk8 = ren_clk8;
    assign cmd0_r_ok = rcmd0_r_ok;
    assign cmd1_r_ok = rcmd1_r_ok;
    
    assign sd_idle = (state == S_IDLE);

endmodule


module spi_controller(
        input clk,  //system clk - 100MHz
        input rst,

        input en_clk74,
        output reg done_clk74,

        input en_tx,
        output reg done_tx,
        input [7:0] data_tx,

        output reg done_rx,
        input en_rx,
        output reg [7:0] data_rx,

        output reg done_clk8,
        input en_clk8,

        output reg SPI_CLK,
        output reg SPI_MOSI,
        input SPI_MISO,
        output reg SPI_CSn
);
        parameter T_HALFSPICLK_TICKS = 8'd200;   //250kHz
        parameter T_74CLK_TICKS = 7'd100;
        parameter T_8CLK_TICKS = 7'd10;

        parameter S_INIT = 5'd0;
        parameter S_CLK74_RISE = 5'd1;
        parameter S_CLK74_FALL = 5'd2;
        parameter S_CLK74_DONE = 5'd3;
        parameter S_CLK74_RESET = 5'd4;

        parameter S_TX_LOAD = 5'd2; //������һ��bit��ͬʱʱ���½�
        parameter S_TX_RISE = 5'd3; //ʱ��������������д��
        parameter S_TX_DONE = 5'd4;
        parameter S_TX_RESET = 5'd5;

        parameter S_RX_LOAD = 5'd2; //ʱ����������������
        parameter S_RX_FALL = 5'd3; //ʱ���½��������ֽ��Ƿ����ļ��
        parameter S_RX_DONE = 5'd4;
        parameter S_RX_RESET = 5'd5;
        

        //��Ҫ�������ʱ�ӵĳ�����
        //      clk74, tx, rx, clk8

        reg [7:0] clk_cnt = 0;
        reg [7:0] spiclk_cnt = 0;
        reg [2:0] bit_cnt = 0;
        reg [7:0] read_byte = 0;

        //���ڲ���SPIʱ�ӵļ�����
        reg spiclk_ena = 0;
        always @(posedge clk or posedge rst) begin
            if(rst) begin
                clk_cnt <= 0;
            end else begin
                if(clk_cnt == T_HALFSPICLK_TICKS - 1)
                    clk_cnt <= 8'd0;
                else if(spiclk_ena)
                    clk_cnt <= clk_cnt + 1;
                else
                    clk_cnt <= 0;
            end
        end

        reg [4:0] state = 5'd0;

        always @(posedge clk or posedge rst) begin
            if(rst) begin
                SPI_CLK <= 1'b0;    //SPI MODE 0
                SPI_CSn <= 1'b1;
                state <= 0;
                SPI_MOSI <= 1'b1;
            end
            else if(en_clk74) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                        SPI_CSn <= 1'b1;
                        SPI_MOSI <= 1'b1;
                        state <= state + 1;
                    end

                    S_CLK74_RISE:
                    begin
                        if(spiclk_cnt == T_74CLK_TICKS)
                        begin
                            spiclk_cnt <= 8'd0;
                            state <= S_CLK74_DONE;
                        end else if (clk_cnt == T_HALFSPICLK_TICKS - 1) begin
                            SPI_CLK <= 1'b1;
                            spiclk_cnt <= spiclk_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_CLK74_FALL:
                    begin
                        if(clk_cnt == T_HALFSPICLK_TICKS - 1)begin
                            SPI_CLK <= 1'b0;
                            state <= state - 1;
                        end
                    end

                    S_CLK74_DONE:
                    begin
                        done_clk74 <= 1'b1;
                        state <= state + 1;
                        spiclk_ena <= 0;
                    end

                    default:
                    begin
                        done_clk74 <= 1'b0;
                        SPI_CSn <= 1'b1;
                        state <= S_INIT;
                    end

                endcase
            end
            else if(en_clk8) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                        SPI_CSn <= 1'b1;
                        SPI_MOSI <= 1'b1;
                        state <= state + 1;
                    end

                    S_CLK74_RISE:
                    begin
                        if(spiclk_cnt == T_8CLK_TICKS)
                        begin
                            spiclk_cnt <= 8'd0;
                            state <= S_CLK74DONE;
                        end else if (clk_cnt == T_HALFSPICLK_TICKS - 1) begin
                            SPI_CLK <= 1'b1;
                            spiclk_cnt <= spiclk_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_CLK74_FALL:
                    begin
                        if(clk_cnt == T_HALFSPICLK_TICKS - 1)begin
                            SPI_CLK <= 1'b0;
                            state <= state - 1;
                        end
                    end

                    S_CLK74_DONE:
                    begin
                        done_clk8 <= 1'b1;
                        state <= state + 1;
                    end

                    default:        //RESET
                    begin
                        done_clk8 <= 1'b0;
                        SPI_CSn <= 1'b1;
                        state <= S_INIT;
                    end

                endcase
            end else if(en_tx) begin
                case (state)
                    S_INIT:
                    begin
                        state <=state + 1;
                        bit_cnt <= 'd7;
                        SPI_CLK <= 1'b0;
                        SPI_CSn <= 1'b0;
                    end
                    S_TX_LOAD:
                    begin
                        //�Ӹ�λ����λ��
                        if(clk_cnt == T_HALFSPICLK_TICKS) begin
                            SPI_MOSI <= data_tx[bit_cnt];
                            bit_cnt <= bit_cnt - 1;
                            state <= state + 1;
                            SPI_CLK <= 0;
                        end
                    end
                    S_TX_RISE:
                    begin
                        SPI_CLK <= 1;
                        if(bit_cnt == 0)begin
                            //������
                            state <= state + 1;
                        end else begin
                            state <= state - 1;
                        end
                    end
                    S_TX_DONE:
                    begin
                        SPI_CLK <= 1'b0;
                        SPI_CSn <= 1'b1;
                        done_tx <= 1'b1;
                        state <= state + 1;
                    end
                    default:
                    begin
                        SPI_CLK <= 1'b0;
                        SPI_CSn <= 1'b1;
                        done_tx <= 1'b0;
                        state <= S_INIT;
                    end
                endcase
            end else if(en_rx) begin
                case (state)
                    S_INIT:
                    begin
                      state <= state + 1;
                      bit_cnt <= 'd0;
                      SPI_CLK <= 1'b0;
                      SPI_CSn <= 1'b0;
                    end

                    S_RX_LOAD:
                    begin
                        if(clk_cnt == T_HALFSPICLK_TICKS) begin
                            SPI_CLK <= 1;
                            data_rx <= {data_rx[6:0], SPI_MISO};
                            bit_cnt <= bit_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_RX_FALL:
                    begin
                        if(clk_cnt == T_HALFSPICLK_TICKS) begin
                            SPI_CLK <= 0;
                            if(bit_cnt == 8)
                                state <= state + 1;
                            else
                                state <= state - 1;
                        end
                    end

                    S_RX_DONE:
                    begin
                      SPI_CLK <= 1'b0;
                      SPI_CSn <= 1'b1;
                      done_rx <= 1'b1;
                      state <= state + 1;
                    end

                    default:
                    begin
                      SPI_CLK <= 1'b0;
                      SPI_CSn <= 1'b1;
                      done_rx <= 1'b0;
                      state <= S_INIT;
                    end
                endcase
            end


        end

endmodule

        
