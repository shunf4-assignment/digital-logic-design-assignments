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

/* -------- SD 控制器，完成初始化操作 -------- */

module sd_controller(
        input clk,  //system clk - 100MHz
        input rst,

/* ---- EN & DONE SIGNALS FOR SD_CONTROLLER ---- */
        input en_start,  //this EN is for SD, no SPI
        output start_ok,

/* ---- EN & DONE SIGNALS FOR SD_CONTROLLER ---- */
        input en_read,
        output reg done_read,

        input [31:0] addr_read,
        input [31:0] sectorcnt_read,
        output reg [7:0] data_read,
        output reg data_read_valid,
        output reg data_read_sectordone,

/* ---- EN & DONE SIGNALS FOR SPI_CONTROLLER ---- */
        output reg en_spi,
        input done_clk74, //From SPI
        output en_clk74,  //To SPI

        input done_tx,    //From SPI, Transmission to SD Finished.
        output en_tx,     //To SPI
        output [7:0] data_tx,   //要串行发送的字节

        input done_rx,
        output en_rx,
        input [7:0] data_rx,

        input done_clk8,
        output en_clk8,

        output cmd0_r_ok,
        output cmd1_r_ok,
        output reg cmd8_r_ok,
        output reg cmd55_r_ok,
        output reg acmd41_r_ok,
        output reg err,

        output wire sd_idle,
        
        output reg [7:0] state,
        output reg [63:0] debug_info,
        output reg debug_info_en,

        output reg acmd41_bypassed,
        output reg cmd58_prepared,
        output reg cmd58_ccs,
        output reg cmd6_r_ok
    );

    //S for state
    parameter S_RESET = 8'b11111111;
    parameter S_WAITSTART = 8'h00;
    parameter S_DELAY = 8'h79;
    parameter S_CLK74 = 8'h1;
    parameter S_TXCMD0 = 8'h2;
    parameter S_TXCMD0R = 8'h3;
    parameter S_TXCMD0R_VALID = 8'h4;
    parameter S_TXCMD0R_INVALID = 8'h5;
    parameter S_TXCMD8 = 8'h6;
    parameter S_TXCMD8R = 8'h7;
    parameter S_TXCMD8RIF = 8'h8;
    parameter S_TXCMD55 = 8'h9;
    parameter S_TXCMD55R = 8'hA;
    parameter S_TXCMD55R_VALID = 8'hB;
    parameter S_TXCMD55R_ILLEGAL = 8'hC;
    parameter S_TXACMD41 = 8'hD;
    parameter S_TXACMD41R = 8'hE;
    parameter S_TXACMD41R_VALID = 8'hF;
    parameter S_TXACMD41R_RETRY = 8'h10;
    parameter S_TXCMD1 = 8'h11;
    parameter S_TXCMD1R = 8'h12;
    parameter S_TXCMD1R_VALID = 8'h13;
    parameter S_TXCMD1R_RETRY = 8'h14;
    parameter S_TXCMD58 = 8'h15;
    parameter S_TXCMD58R = 8'h16;
    parameter S_TXCMD58R_DO = 8'h17;
    parameter S_TXCMD6_HS = 8'h1A;
    parameter S_TXCMD6_HS_R = 8'h1B;
    parameter S_TXCMD6_HS_R_DO = 8'h1C;
    parameter S_TXCMD6_HS_R_VALID = 8'h1D;
    
    parameter S_IDLE = 8'h20;
    parameter S_8CLK = 8'h80;
    parameter S_ERR = 8'hCF;
    parameter S_TXCMD = 8'h81;
    parameter S_TXCMD_DO = 8'h82;
    parameter S_RXIFIS_ADV = 8'h84;
    parameter S_RXIFIS_ADV_DO = 8'h85;
    parameter S_READ_CMD = 8'h21;
    parameter S_READ_WAIT = 8'h22;
    parameter S_READ_WAIT_DO = 8'h23;
    parameter S_TXCMD12 = 8'h25;
    parameter S_TXCMD12_DISCARD_STUFF = 8'h26;
    parameter S_TXCMD12R = 8'h27;
    parameter S_TXCMD12R_ZERO = 8'h28;
    parameter S_TXCMD12R_DONE = 8'h29;
    parameter S_AFTERREAD = 8'h2A;
    parameter S_TXCMD0R_DO = 8'hB0;


    parameter CMD0 = {8'hff, 2'b01, 6'h0, 32'h0, 8'h95}; 
    parameter LEN_CMD0 = 7; 
    parameter CMD1 = {8'hff, 2'b01, 6'h1, 32'h0, 8'hF1}; 
    parameter LEN_CMD1 = 7; 
    parameter CMD6 = {8'hff, 2'b01, 6'h6, 1'b1, 7'h00, 16'h0, 4'h0, 4'h1, 8'hf6};
    parameter LEN_CMD6 = 7;
    parameter CMD8 = {8'hff, 2'b01, 6'h8, 16'h0, 8'h1, 8'hAA, 8'h87};
    parameter LEN_CMD8 = 7;
    parameter CMD55 = {8'hff, 2'b01, 6'd55, 32'h0, 8'h65};
    parameter LEN_CMD55 = 7;
    parameter ACMD41 = {8'hff, 2'b01, 6'd41, 32'h40000000, 8'h41};
    parameter LEN_ACMD41 = 7;
    
    //parameter ACMD41 = {8'hff, 2'b01, 6'd41, 32'h40000000, 8'h95};

    parameter CMD58 = {8'hff, 2'b01, 6'd58, 32'h0, 8'h58};
    parameter LEN_CMD58 = 7;
    parameter CMD0_R = 8'h01;
    parameter CMD_R_ILLEGAL = 8'h05;
    parameter CMD1_R = 8'h00;
    parameter CMD17_H = 16'hFF51;
    parameter CMD17_T = 8'hFF;
    parameter CMD18_H = 16'hFF52;
    parameter CMD18_T = 8'hFE;
    parameter CMD12 = {8'hff, 2'b01, 6'd12, 32'h0, 8'hFD};
    parameter LEN_CMD12 = 7;
    
    parameter T_DELAYTICKS = 12'd4000;        //40us
    parameter T_RESPMAXCNT = 10'd1023;


    
    reg [7:0] nextstate;         //调用某个状态，希望其执行完毕后跳转到某个指定状态时用
    reg [7:0] nextstate2;         //调用某个状态，希望其执行完毕后跳转到某个指定状态时用
    reg [7:0] nextstate3;         //调用某个状态，希望其执行完毕后跳转到某个指定状态时用
    reg [7:0] nextstate_invalid; //在判断读数有效性时，若发现无效（非法/错误/需要重新发送），跳转到的状态。通常需要8个滴答（调用S_8CLK），因为正常接受了从机传来的信息。
    reg [7:0] retrystate;        //若迟迟读不到数据，返回的状态。一般不需要8个滴答。
    reg [63:0] command_buffer;      //存储命令的6字节，这里扩展到8字节
    reg [5:0] command_bytecnt;       //标示当前传的是命令的第几个字节(MSB为先)
    reg [7:0] resp_expected;
    reg [10:0] resp_bytecnt;
    reg [7:0] resp_invalid;
    reg [7:0] resp_startvalid;          //输出检测到以0开始的字节，表示输出开始有效
    reg [31:0] sectorcnt_read_r;
    reg just_after_read;

    reg ren_clk74;
    reg ren_rx;
    reg ren_tx;
    reg ren_clk8;
    reg rcmd0_r_ok;
    reg rcmd1_r_ok;
    reg rstart_ok;
    reg [7:0] rdata_tx;
    reg [9:0] rRespCnt;

    reg [9:0] acmd41fail_cnt;

    reg [7:0] tmp;

    //上电延迟计数器
    
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

    //状态机，按照 上电延迟 - 74时钟滴答 - 送CMD0 - 读CMD0R - 送CMD8 - 读CMD8R - 送ACMD41 - 读ACMD41R（大致）
    //此后，根据输入的情况来转换状态，可能实现读取、写入功能
    always @(posedge clk or posedge rst)
    begin
        if(rst || (en_start && state == S_RESET)) begin
            state <= S_WAITSTART;
            data_read_valid <= 0;
            ren_clk74 <= 1'b0;
            command_buffer <= 0;
            command_bytecnt <= 0;
            rcmd0_r_ok <= 0;
            rcmd1_r_ok <= 0;
            cmd8_r_ok <= 0;
            cmd55_r_ok <= 0;
            acmd41_r_ok <= 0;
            resp_expected <= 8'hf0;
            resp_bytecnt <= 0;
            resp_invalid <= 0;
            resp_startvalid <= 0;
            nextstate <= S_RESET;
            nextstate2 <= S_RESET;
            nextstate3 <= S_RESET;
            nextstate_invalid <= S_RESET;
            retrystate <= S_RESET;
            ren_clk8 <= 1'b0;
            ren_rx <= 0;
            ren_tx <= 0;
            rdata_tx <= 0;
            rRespCnt <= 8'd0;
            rstart_ok <= 0;
            cmd8_r_ok <= 0;
            err <= 0;
            debug_info <= 64'h0;
            debug_info_en <= 0;
            data_read_sectordone <= 0;
            sectorcnt_read_r <= 0;
            just_after_read <= 0;
            acmd41fail_cnt <= 0;
            acmd41_bypassed <= 0;
            cmd58_ccs <= 0;
            cmd58_prepared <= 0;
            cmd6_r_ok <= 0;
            en_spi <= 0;
            tmp <= 0;
        end
        else begin
            if(debug_info_en == 1)
                debug_info_en <= 0;

            if(done_read == 1)
                done_read <= 0;

            if(data_read_valid == 1)
                data_read_valid <= 0;

            if(data_read_sectordone == 1)
                data_read_sectordone <= 0;
            case (state)
                S_WAITSTART:
                    if(en_start) begin
                        state <= S_DELAY;
                        en_spi <= 1;
                    end else begin
                        en_spi <= 0;
                    end

                S_DELAY:
                    if(rDelayCnt >= T_DELAYTICKS - 1)   //上电延迟结束
                        state <= S_CLK74;
                
                S_CLK74:
                    if(done_clk74) begin
                        ren_clk74 <= 1'b0;
                        state <= S_TXCMD0;
                    end
                    else ren_clk74 <= 1'b1;

                S_TXCMD0:
                    begin
                        command_buffer <= CMD0;
                        command_bytecnt <= LEN_CMD0;
                        nextstate <= S_TXCMD0R;
                        state <= S_TXCMD;
                    end

                S_TXCMD0R:
                begin
                    rcmd0_r_ok <= 1'b0;
                    resp_expected <= CMD0_R;
                    resp_invalid <= 8'h00;      //有的时候，CMD0返回00也算对

                    nextstate <= S_TXCMD0R_VALID;
                    nextstate_invalid <= S_TXCMD0R_VALID;
                    retrystate <= S_TXCMD0;
                    //state <= S_RXIFIS_ADV;
                    rRespCnt <= 0;
                    state <= S_TXCMD0R_DO;
                end

                S_TXCMD0R_DO:
                if(done_rx) begin
                    ren_rx <= 0;
                    if(data_rx != 8'hff) begin
                        rRespCnt <= 0;
                        state <= nextstate;
                    end else if(rRespCnt == T_RESPMAXCNT) begin
                        //超时了
                        rRespCnt <= 0;
                        state <= retrystate;
                    end else begin
                        rRespCnt <= rRespCnt + 1'b1;
                    end
                end else begin
                    ren_rx <= 1;
                end

                S_TXCMD0R_VALID:
                begin
                    rcmd0_r_ok <= 1'b1;
                    //nextstate <= S_TXCMD1;          
                    nextstate <= S_TXCMD8;
                    state <= S_8CLK;
                end

                S_TXCMD0R_INVALID:
                begin
                    nextstate <= S_TXCMD0;
                    state <= S_8CLK;
                end

                S_TXCMD1:
                    begin
                        command_buffer <= CMD1;
                        command_bytecnt <= LEN_CMD1;
                        nextstate <= S_TXCMD1R;
                        state <= S_TXCMD;
                    end

                S_TXCMD1R:
                begin
                    rcmd1_r_ok <= 1'b0;
                    resp_expected <= CMD1_R;
                    resp_invalid <= CMD0_R;
                    
                    nextstate <= S_TXCMD1R_VALID;
                    nextstate_invalid <= S_TXCMD1R_RETRY;
                    retrystate <= S_TXCMD1;
                    state <= S_RXIFIS_ADV;
                end

                S_TXCMD1R_VALID:
                begin
                    rcmd1_r_ok <= 1'b1;
                    nextstate <= S_IDLE;
                    state <= S_8CLK;
                end

                S_TXCMD1R_RETRY:
                begin
                    nextstate <= S_TXCMD1;
                    state <= S_8CLK;
                end

                S_TXCMD8:
                    begin
                        command_buffer <= CMD8;
                        command_bytecnt <= LEN_CMD8;
                        nextstate <= S_TXCMD8R;
                        state <= S_TXCMD;
                    end

                S_TXCMD8R:
                begin
                    cmd8_r_ok <= 1'b0;
                    // resp_expected <= CMD1_R;
                    // nextstate <= S_TXCMD1R_VALID;
                    // retrystate <= S_TXCMD1;
                    resp_bytecnt <= 'd5;
                    resp_startvalid <= 'h0;
                    rRespCnt <= 8'd0;
                    state <= S_TXCMD8RIF;
                end

                S_TXCMD8RIF:
                if(done_rx) begin
                    //读取完成，看看读取到的字节是否有效
                    ren_rx <= 0;
                    //if(data_rx[7] == 1'b0  || resp_startvalid == 1) begin
                    if(data_rx != 8'hFF  || resp_startvalid == 1) begin
                        //输出开始有效
                        resp_bytecnt <= resp_bytecnt - 1;
                        resp_startvalid <= 1;
                        if(data_rx == 8'b00000001 || resp_startvalid == 1) begin
                            //CMD8命令合法，开始继续接收
                            if(resp_bytecnt == 1)begin
                                //接收完毕，前往下一状态
                                rRespCnt <= 8'd0;
                                resp_bytecnt <= 0;
                                resp_startvalid <= 0;
                                nextstate <= nextstate;
                                state <= S_8CLK;
                            end else begin
                                //检测电压是否有效
                                if(resp_bytecnt == 2)
                                    if((data_rx & 8'h0f) ==  8'h01) begin
                                        //低4位为0x01，电压正常。
                                        cmd8_r_ok <= 1'b1; 
                                        nextstate <= S_TXCMD55;
                                    end else begin
                                        debug_info[7:0] <= data_rx;
                                        debug_info[63:8] <= 56'hFE;
                                        debug_info_en <= 1;
                                        nextstate <= S_ERR;
                                    end
                                else if(resp_bytecnt == 1)
                                    //检测校验位
                                    if(data_rx == 8'hAA) begin
                                        cmd8_r_ok <= cmd8_r_ok;
                                        nextstate <= nextstate;
                                    end else begin
                                        cmd8_r_ok <= 1'b0;
                                        debug_info[7:0] <= data_rx;
                                        debug_info[63:8] <= 56'hFD;
                                        debug_info_en <= 1;
                                        nextstate <= S_ERR;
                                    end
                            end
                        end else if(data_rx == 8'b00000101) begin
                            //CMD8命令非法(新卡)，说明要用CMD58
                            resp_bytecnt <= 0;
                            resp_startvalid <= 0;
                            cmd8_r_ok <= 0;
                            //nextstate <= S_TXCMD58;
                            //不搞CMD58了， 让它错误吧
                            nextstate <= S_ERR;
                            debug_info[7:0] <= data_rx;
                            debug_info[63:8] <= 56'h58;
                            debug_info_en <= 1;
                            state <= S_8CLK;
                        end else begin
                            //其他回复，错误，循环发送CMD8。
                            debug_info_en <= 1;
                            debug_info[7:0] <= data_rx;
                            debug_info[63:8] <= 56'h68;
                            nextstate <= S_TXCMD8;
                            state <= S_8CLK;
                        end
                    end else if(rRespCnt == T_RESPMAXCNT) begin
                        //超时了
                        rRespCnt <= 0;
                        state <= S_TXCMD8;
                    end else begin
                        rRespCnt <= rRespCnt + 1'b1;
                    end
                end else begin
                    ren_rx <= 1;
                end

                S_TXCMD55:
                    begin
                        cmd55_r_ok <= 0;
                        command_buffer <= CMD55;
                        command_bytecnt <= LEN_CMD55;
                        nextstate <= S_TXCMD55R;
                        state <= S_TXCMD;
                    end

                S_TXCMD55R:
                begin
                    rRespCnt <= 8'd0;
                    nextstate <= S_TXCMD55R_VALID;
                    nextstate_invalid <= S_TXCMD55R_ILLEGAL;
                    retrystate <= S_TXCMD55;
                    resp_expected <= CMD0_R;
                    resp_invalid <= CMD_R_ILLEGAL;
                    state <= S_RXIFIS_ADV;
                end

                S_TXCMD55R_ILLEGAL:
                begin
                    nextstate <= S_TXCMD1;
                    state <= S_8CLK;
                end

                

                S_TXCMD55R_VALID:
                begin
                    cmd55_r_ok <= 1'b1;
                    nextstate <= S_TXACMD41;
                    state <= S_8CLK;
                    
                end

                S_TXACMD41:
                begin
                    acmd41_r_ok <= 1'b0;
                    command_buffer <= ACMD41;
                    command_bytecnt <= LEN_ACMD41;
                    nextstate <= S_TXACMD41R;
                    state <= S_TXCMD;
                end

                S_TXACMD41R:
                begin
                    rRespCnt <= 0;
                    nextstate <= S_TXACMD41R_VALID;
                    nextstate_invalid <= S_TXACMD41R_RETRY;
                    retrystate <= S_TXCMD55;
                    resp_expected <= CMD1_R;
                    resp_invalid <= CMD0_R;
                    state <= S_RXIFIS_ADV;
                end

                S_TXACMD41R_VALID:
                begin
                    acmd41fail_cnt <= 0;
                    acmd41_r_ok <= 1'b1;
                    nextstate <= S_TXCMD58;
                    state <= S_8CLK;
                end

                S_TXACMD41R_RETRY:
                begin
                    //TXACMD41 失败，SD没有完成初始化，再次发送CMD55, ACMD41
                    if(acmd41fail_cnt == 1023)begin
                        acmd41_bypassed <= 1'b1;
                        nextstate <= S_IDLE;
                        acmd41fail_cnt <= 0;
                    end else begin
                        nextstate <= S_TXCMD55;
                        //nextstate <= S_TXCMD8;
                        acmd41fail_cnt <= acmd41fail_cnt + 1;
                    end
                    state <= S_8CLK;
                end

                S_TXCMD58:
                begin
                    command_buffer <= CMD58;
                    command_bytecnt <= LEN_CMD58;
                    nextstate <= S_TXCMD58R;
                    state <= S_TXCMD;
                end

                S_TXCMD58R:
                begin
                    resp_bytecnt <= 'd5;
                    resp_startvalid <= 'h0;
                    rRespCnt <= 8'd0;
                    state <= S_TXCMD58R_DO;
                end

                S_TXCMD58R_DO:
                begin
                    if(done_rx) begin
                        ren_rx <= 0;
                        if(resp_startvalid == 1'b1) begin
                            resp_bytecnt <= resp_bytecnt - 1;
                            if(resp_bytecnt == 1) begin
                                rRespCnt <= 0;
                                resp_bytecnt <= 0;
                                resp_startvalid <= 0;
                                state <= S_8CLK;
                            end else if(resp_bytecnt == 4) begin
                                debug_info <= {56'h0, 3'h0, data_rx[7], 3'h0, data_rx[6]};
                                debug_info_en <= 1;
                                cmd58_prepared <= data_rx[7];
                                cmd58_ccs <= data_rx[6];
                                //nextstate <= S_TXCMD6_HS;
                                //不搞CMD6了，直接提速
                                nextstate <= S_TXCMD6_HS_R_VALID;
                            end
                        end else if(data_rx != 8'hff) begin
                            resp_startvalid <= 1;
                            resp_bytecnt <= resp_bytecnt - 1;
                            if(data_rx != 8'h00) begin
                                debug_info_en <= 1;
                                debug_info <= {56'hAA, data_rx};
                                nextstate <= S_ERR;
                                state <= S_8CLK;
                            end
                        end else if(rRespCnt == T_RESPMAXCNT) begin
                            rRespCnt <= 0;
                            state <= S_TXCMD58;
                        end else begin
                            rRespCnt <= rRespCnt + 1;
                        end
                    end else begin
                        ren_rx <= 1;
                    end
                end

                S_TXCMD6_HS:
                begin
                    command_buffer <= CMD6;
                    command_bytecnt <= LEN_CMD6;
                    nextstate <= S_TXCMD6_HS_R;
                    state <= S_TXCMD;
                end

                S_TXCMD6_HS_R:
                begin
                    rRespCnt <= 8'd0;
                    nextstate <= S_TXCMD6_HS_R_VALID;
                    nextstate_invalid <= S_RESET;
                    retrystate <= S_TXCMD6_HS;
                    resp_expected <= 8'h00;
                    resp_invalid <= 8'hAA;
                    // state <= S_RXIFIS_ADV;
                    state <= S_TXCMD6_HS_R_DO;
                end

                S_TXCMD6_HS_R_DO:
                    if(done_rx) begin
                        ren_rx <= 0;
                        if(data_rx != 8'hff) begin
                            if(data_rx == 8'h00) begin
                                debug_info[7:0] <= data_rx;
                                debug_info[63:8] <= {48'hE6, 8'h01};
                                debug_info_en <= 1;
                            end else if(data_rx == 8'h01) begin
                                rRespCnt <= 0;
                                debug_info[7:0] <= data_rx;
                                debug_info[63:8] <= {48'hE6, 8'h02};
                                debug_info_en <= 1;
                                state <= S_TXCMD6_HS_R_VALID;
                            end
                            // else if(data_rx != 8'h00) begin
                                
                            //end
                        end else if(rRespCnt == T_RESPMAXCNT) begin
                            rRespCnt <= 0;
                            state <= S_TXCMD6_HS;
                        end else begin
                            rRespCnt <= rRespCnt + 1;
                        end
                    end else begin
                        ren_rx <= 1;
                    end

                S_TXCMD6_HS_R_VALID:
                begin
                    cmd6_r_ok <= 1;
                    nextstate <= S_IDLE;
                    state <= S_8CLK;
                end

                S_IDLE:
                begin
                    if(just_after_read == 1'b1) begin
                        just_after_read <= 0;
                    end else begin
                        if(en_read == 1'b1) begin
                            sectorcnt_read_r <= sectorcnt_read;
                            state <= S_READ_CMD;
                        end
                    end
                    rstart_ok <= 1'd1;
                end

                S_ERR:
                    begin
                        err <= 1'b1;
                    end
 
                S_8CLK:
                    if(done_clk8) begin
                        ren_clk8 <= 1'b0;
                        state <= nextstate;
                    end else begin
                        ren_clk8 <= 1'b1;
                    end
                    
                S_RXIFIS_ADV:
                    begin
                        debug_info_en <= 0;
                        rRespCnt <= 0;
                        state <= S_RXIFIS_ADV_DO;
                    end

                S_RXIFIS_ADV_DO:
                //参数：nextstate_next，nextstate_invalid，nextstate_retry
                //       resp_expected     resp_invalid
                if(done_rx) begin
                    //读取完成，看看读取到的字节的最高位是不是0（输出有效）
                    ren_rx <= 0;
                    if(data_rx != 8'hff) begin
                        if(data_rx == resp_expected) begin
                            //接收状态正确，前往下一状态
                            rRespCnt <= 0;
                            state <= nextstate;
                        end else if(data_rx == resp_invalid) begin
                            state <= nextstate_invalid;
                        end else begin
                            //其他回复，触发错误。
                            debug_info_en <= 1;
                            debug_info[7:0] <= data_rx;
                            //错误信息中的nextstate可以标识哪一步出错了
                            debug_info[63:8] <= {40'h0, 8'hAB, nextstate};
                            nextstate <= S_ERR;
                            state <= S_8CLK;
                        end
                    end else if(rRespCnt == T_RESPMAXCNT) begin
                        //超时了
                        rRespCnt <= 0;
                        state <= retrystate;
                    end else begin
                        rRespCnt <= rRespCnt + 1'b1;
                    end
                end else begin
                    ren_rx <= 1;
                end

                S_TXCMD:
                begin
                    nextstate2 <= nextstate;
                    nextstate <= S_TXCMD_DO;
                    state <= S_8CLK;    //传输前给8个时钟
                    //state <= S_TXCMD_DO;
                end

                S_TXCMD_DO:
                    if(done_tx) begin
                        if(command_bytecnt <= 'd1) begin
                            //command 传输完成
                            command_bytecnt <= 0;
                            ren_tx <= 1'b0;
                            nextstate <= nextstate2;
                            //state <= S_8CLK;    //传输后给8个时钟
                            state <= nextstate2;
                        end else begin
                            //command 的下一个字节
                            ren_tx <= 1'b1;
                            command_bytecnt <= command_bytecnt - 1;
                        end
                    end else begin
                        //command_buffer <= CMD0;
                        rdata_tx <= command_buffer[command_bytecnt * 8 - 1 -: 8];
                        ren_tx <= 1'b1;
                    end

                S_READ_CMD:
                    begin
                        if(sectorcnt_read_r <= 1) begin
                            //读一个扇区
                            command_buffer <= {CMD17_H, cmd58_ccs ? addr_read : (addr_read << 9), CMD17_T};
                        end else begin
                            command_buffer <= {CMD18_H, cmd58_ccs ? addr_read : (addr_read << 9), CMD18_T};
                        end
                        command_bytecnt <= 7;
                        nextstate <= S_READ_WAIT;
                        state <= S_TXCMD;
                    end

                S_READ_WAIT:
                    begin
                        resp_bytecnt <= 'd512 + 'd2; //2个CRC校验
                        resp_startvalid <= 0;
                        rRespCnt <= 0;
                        tmp <= 0;
                        state <= S_READ_WAIT_DO;
                    end

                S_READ_WAIT_DO:
                    begin
                        if(done_rx) begin
                            ren_rx <= 0;
                            if(data_rx != 8'hff || resp_startvalid == 1) begin
                                //接收到有效输出，要么是开头的FE，要么是数据字节
                                if(resp_startvalid == 1) begin
                                    //是数据
                                    resp_bytecnt <= resp_bytecnt - 1;
                                    if(resp_bytecnt > 2) begin
                                        //不是校验byte
                                        
                                        data_read <= data_rx;
                                        data_read_valid <= 1;
                                    end else if(resp_bytecnt == 1) begin
                                        //传完
                                        resp_startvalid <= 0;
                                        rRespCnt <= 0;
                                        data_read_sectordone <= 1;
                                        //判断是不是所需扇区都已经读完
                                        if(command_buffer[7:0] == CMD18_T) begin
                                            sectorcnt_read_r <= sectorcnt_read_r - 1;
                                            if(sectorcnt_read_r <= 1) begin
                                                //已经读完，要送CMD12
                                                state <= S_TXCMD12;
                                            end else begin
                                                state <= S_READ_WAIT;
                                            end
                                        end else begin
                                            nextstate <= S_AFTERREAD;
                                            state <= S_8CLK;
                                        end
                                    end
                                end else if(data_rx == 8'hfe) begin
                                    //开头FE
                                    resp_startvalid <= 1;
                                    tmp <= tmp + 10;
                                end else if(data_rx == 8'h00) begin
                                    resp_startvalid <= 0;
                                    tmp <= tmp + 1;
                                end else begin
                                    //其他回复，错误
                                    debug_info_en <= 1;
                                    debug_info[7:0] <= data_rx;
                                    debug_info[63:8] <= {40'h0,tmp,8'h17};
                                    nextstate <= S_ERR;
                                    state <= S_8CLK;
                                end
                            end else if (rRespCnt == T_RESPMAXCNT) begin
                                //超时了
                                tmp <= tmp + 1;
                                rRespCnt <= 0;
                                debug_info_en <= 1;
                                debug_info <= {48'hAA, tmp, data_rx};
                                //nextstate <= S_ERR;
                                //state <= S_READ_CMD;
                                //state <= S_ERR;
                            end else begin
                                rRespCnt <= rRespCnt + 1;
                            end
                        end
                        else begin
                            ren_rx <= 1;
                        end
                        

                    end
                    
                S_TXCMD12:
                    begin
                        command_buffer <= CMD12;
                        command_bytecnt <= LEN_CMD12;
                        nextstate <= S_TXCMD12_DISCARD_STUFF;
                        state <= S_TXCMD;
                    end

                S_TXCMD12_DISCARD_STUFF:
                    //抛弃CMD12后立刻出现的一个填充字节
                    begin
                        if(done_rx)begin
                            ren_rx <= 0;
                            state <= S_TXCMD12R;
                        end else begin
                            ren_rx <= 1;
                        end
                    end

                S_TXCMD12R:
                    //CMD12 的回应是 R1B，在正常接收 R1 后，SD 卡在还没准备好时，一直返回低电平。当接收到高电平时，才表示执行结束。

                    begin
                        rRespCnt <= 0;
                        nextstate <= S_TXCMD12R_ZERO;
                        nextstate_invalid <= S_RESET;
                        retrystate <= S_TXCMD12R_DONE;      //长时间没有回应00，回复FF，也默认成功执行了
                        resp_expected <= 8'h00;
                        resp_invalid <= 8'hAA;   //无invalid分支
                        state <= S_RXIFIS_ADV;
                    end

                S_TXCMD12R_ZERO:
                    begin
                        if(done_rx)begin
                            ren_rx <= 0;
                            if(data_rx == 8'hff) begin
                                state <= S_TXCMD12R_DONE;
                            end else begin
                                if(rRespCnt == T_RESPMAXCNT)begin
                                    rRespCnt <= 0;
                                    debug_info_en <= 1;
                                    debug_info[7:0] <= data_rx;
                                    debug_info[63:8] <= {48'h0, 8'hAC};
                                    state <= S_ERR;
                                end else begin
                                    rRespCnt <= rRespCnt + 1;
                                end
                            end
                        end else begin
                            ren_rx <= 1;
                        end
                    end

                S_TXCMD12R_DONE:
                    begin
                        just_after_read <= 1;
                        nextstate <= S_IDLE;
                        state <= S_8CLK;
                    end
                    
                S_AFTERREAD:
                begin
                    just_after_read <= 1;
                    if(done_read == 0)
                        done_read <= 1;
                    state <= S_IDLE;
                end

                default:
                begin
                    state <= S_RESET;
                end
                    
            endcase
        end

    end

    assign start_ok = rstart_ok;
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
        input en,

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

        output SPI_CLK,
        output SPI_MOSI,
        input SPI_MISO,
        output SPI_CSn,
        output reg [4:0] state,

        input cmd6_r_ok,
        output wire SD_RESET
);
        parameter T_HALFSPICLK_TICKS = 9'd175;   //285kHz
        parameter T_HALFSPICLK_TICKS_HS = 9'd2;   //25MHz

        wire[8:0] t_halfspiclk;
        assign t_halfspiclk = cmd6_r_ok ? T_HALFSPICLK_TICKS_HS : T_HALFSPICLK_TICKS;
        //assign t_halfspiclk = T_HALFSPICLK_TICKS;

        parameter T_74CLK_TICKS = 9'd80;
        parameter T_8CLK_TICKS = 7'h10;

        parameter S_INIT = 5'd0;
        parameter S_CLK74_RISE = 5'd1;
        parameter S_CLK74_FALL = 5'd2;
        parameter S_CLK74_DONE = 5'd3;
        parameter S_CLK74_RESET = 5'd4;

        parameter S_TX_LOAD = 5'd1; //加载下一个bit，同时时钟下降
        parameter S_TX_RISE = 5'd2; //时钟上升，该数据写入
        parameter S_TX_DONE = 5'd3;
        parameter S_TX_RESET = 5'd4;

        parameter S_RX_LOAD = 5'd1; //时钟上升，读入数据
        parameter S_RX_FALL = 5'd2; //时钟下降，进行字节是否读完的检测
        parameter S_RX_DONE = 5'd3;
        parameter S_RX_RESET = 5'd4;
        

        reg SPI_CLK_r;
        reg SPI_CSn_r;
        reg SPI_MOSI_r;
        reg SD_RESET_r;

        assign SPI_CLK = en ? SPI_CLK_r : 1'bz;
        assign SPI_CSn = en ? SPI_CSn_r : 1'bz;
        assign SPI_MOSI = en ? SPI_MOSI_r : 1'bz;
        assign SD_RESET = en ? SD_RESET_r : 1'b1;

        //需要计数输出时钟的场景：
        //      clk74, tx, rx, clk8

        reg [8:0] clk_cnt = 0;
        reg [8:0] spiclk_cnt = 0;
        reg [3:0] bit_cnt = 0;
        reg [7:0] read_byte = 0;

        //用于产生SPI时钟的计数器
        reg spiclk_ena = 0;
        always @(posedge clk or posedge rst) begin
            if(rst) begin
                clk_cnt <= 0;
            end else begin
                if(clk_cnt == t_halfspiclk - 1)
                    clk_cnt <= 8'd0;
                else if(spiclk_ena)
                    clk_cnt <= clk_cnt + 1;
                else
                    clk_cnt <= 0;
            end
        end

        

        always @(posedge clk or posedge rst) begin
            if(rst) begin
                SPI_CLK_r <= 1'b0;    //SPI MODE 0
                SPI_CSn_r <= 1'b1;
                state <= 0;
                SPI_MOSI_r <= 1'b1;
                done_clk74 <= 0;
                done_tx <= 0;
                done_rx <= 0;
                data_rx <= 0;
                done_clk8 <= 0;
                spiclk_cnt <= 0;
                bit_cnt <= 0;
                read_byte <= 0;
                spiclk_ena <= 0;
                SD_RESET_r <= 1'b0;
            end
            else if(en_clk74) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                        //SPI_CSn_r <= 1'b1;
                        SPI_CSn_r <= 1'b0;
                        SPI_MOSI_r <= 1'b1;
                        state <= state + 1;
                    end

                    S_CLK74_RISE:
                    begin
                        if(spiclk_cnt == T_74CLK_TICKS)
                        begin
                            spiclk_cnt <= 8'd0;
                            state <= S_CLK74_DONE;
                        end else if (clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 1'b1;
                            spiclk_cnt <= spiclk_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_CLK74_FALL:
                    begin
                        if(clk_cnt == t_halfspiclk - 1)begin
                            SPI_CLK_r <= 1'b0;
                            state <= state - 1;
                        end
                    end

                    S_CLK74_DONE:
                    begin
                        done_clk74 <= 1'b1;
                        SPI_CSn_r <= 1'b1;                        
                        state <= state + 1;
                    end

                    default:
                    begin
                        done_clk74 <= 1'b0;
                        SPI_CSn_r <= 1'b1;
                        state <= S_INIT;
                        spiclk_ena <= 1'b0;
                    end

                endcase
            end
            else if(en_clk8) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                        SPI_CSn_r <= 1'b1;
                        SPI_MOSI_r <= 1'b1;
                        state <= state + 1;
                    end

                    S_CLK74_RISE:
                    begin
                        if(spiclk_cnt == T_8CLK_TICKS)
                        begin
                            spiclk_cnt <= 8'd0;
                            state <= S_CLK74_DONE;
                        end else if (clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 1'b1;
                            spiclk_cnt <= spiclk_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_CLK74_FALL:
                    begin
                        if(clk_cnt == t_halfspiclk - 1)begin
                            SPI_CLK_r <= 1'b0;
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
                        SPI_CSn_r <= 1'b1;
                        state <= S_INIT;
                        spiclk_ena <= 1'b0;
                    end

                endcase
            end else if(en_tx) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                        state <=state + 1;
                        bit_cnt <= 'd8;
                        SPI_CLK_r <= 1'b0;
                        SPI_CSn_r <= 1'b0;
                    end
                    S_TX_LOAD:
                    begin
                        //从高位到低位传
                        if(clk_cnt == t_halfspiclk - 1) begin
                            SPI_MOSI_r <= data_tx[bit_cnt - 1];
                            bit_cnt <= bit_cnt - 1;
                            state <= state + 1;
                            SPI_CLK_r <= 0;
                        end
                    end
                    S_TX_RISE:
                    begin
                        if(clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 1;
                            if(bit_cnt == 0)begin
                                //传完了
                                state <= state + 1;
                            end else begin
                                state <= state - 1;
                            end
                        end
                    end
                    S_TX_DONE:
                    begin
                        //在最后一次置上升沿后，再停留半个时钟周期
                        if(clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 1'b0;
                            SPI_CSn_r <= 1'b1;
                            done_tx <= 1'b1;
                            state <= state + 1;
                        end
                    end
                    default:
                    begin
                        SPI_CLK_r <= 1'b0;
                        SPI_CSn_r <= 1'b1;
                        SPI_MOSI_r <= 1'b1;
                        done_tx <= 1'b0;
                        spiclk_ena <= 1'b0;
                        state <= S_INIT;
                    end
                endcase
            end else if(en_rx) begin
                spiclk_ena <= 1'b1;
                case (state)
                    S_INIT:
                    begin
                      state <= state + 1;
                      bit_cnt <= 'd0;
                      SPI_CLK_r <= 1'b0;
                      SPI_CSn_r <= 1'b0;
                      SPI_MOSI_r <= 1'b1;
                    end

                    S_RX_LOAD:
                    begin
                        if(clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 1;
                            data_rx <= {data_rx[6:0], SPI_MISO};
                            bit_cnt <= bit_cnt + 1;
                            state <= state + 1;
                        end
                    end

                    S_RX_FALL:
                    begin
                        if(clk_cnt == t_halfspiclk - 1) begin
                            SPI_CLK_r <= 0;
                            if(bit_cnt == 8)
                                state <= state + 1;
                            else
                                state <= state - 1;
                        end
                    end

                    S_RX_DONE:
                    begin
                      SPI_CLK_r <= 1'b0;
                      SPI_CSn_r <= 1'b1;
                      done_rx <= 1'b1;
                      state <= state + 1;
                    end

                    default:
                    begin
                      SPI_CLK_r <= 1'b0;
                      SPI_CSn_r <= 1'b1;
                      done_rx <= 1'b0;
                      spiclk_ena <= 1'b0;
                      state <= S_INIT;
                    end
                endcase
            end
            else begin
                spiclk_ena <= 1'b0;
            end
        end

endmodule

        
