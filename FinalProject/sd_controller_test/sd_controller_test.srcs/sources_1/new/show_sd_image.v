`timescale 1ns / 1ps

module show_sd_image(
        input CLK100MHZ,
        input BTNU,     //rst
        input BTNC,
        input [15:0] SW,
        input BTNR,     //start read
        output [15:0] LED,
        output SD_SCK,
        output SD_CMD,
        input SD_DAT0,
        output SD_DAT3,
        output [7:0] AN,
        output [7:0] C,
        output wire SD_RESET
    );
    
    reg en_start;
    wire start_ok;
    wire en_spi;
    wire done_clk74;
    wire en_clk74;
    wire done_tx;
    wire en_tx;
    wire [7:0] data_tx;
    wire done_rx;
    wire en_rx;
    wire [7:0] data_rx;
    wire done_clk8;
    wire en_clk8;

    reg en_read;
    reg [31:0] addr_read;
    wire done_read;
    wire data_read_valid;
    wire [7:0] data_read;
    reg [31:0] sectorcnt_read;
    wire data_read_sectordone;

    wire cmd0_r_ok;
    wire cmd1_r_ok;
    wire cmd8_r_ok;
    wire cmd55_r_ok;
    wire acmd41_r_ok;
    wire sd_err;
    wire sd_idle;

    
    wire [7:0] sd_state;
    wire [4:0] spi_state;
    
    wire [63:0] sd_debug_info;
    wire sd_debug_info_en;
    reg [63:0] main_debug_info;
    reg main_debug_info_en;
    reg [63:0] debug_info;
    reg debug_info_en;

    wire acmd41_bypassed;
    wire cmd58_prepared;
    wire cmd58_ccs;
    wire cmd6_r_ok;     //弃用

    wire [4:0] debug_info_pageselect;
    wire [7:0] history_info_pageselect;
    
    //reg [7:0] memory [0:511];
    reg [10:0] memory_cnt;

    reg [7:0] main_state;
    reg main_err;
    //wire err;
    //assign err = sd_err & main_err;


/* ------------ SD AND SPI CONTROLLER INSTANTIATION SECTION ------------ */
    wire rst;
    assign rst = BTNC;
    reg [2:0] soft_rst;
    wire btn_start;
    assign btn_start = BTNU;


    sd_controller sdcon(
        .clk(CLK100MHZ),
        .rst(soft_rst[2]),
        .en_start(en_start),
        .start_ok(start_ok),
        .en_spi(en_spi),
        .done_clk74(done_clk74),
        .en_clk74(en_clk74),
        .done_tx(done_tx),
        .en_tx(en_tx),
        .data_tx(data_tx),
        .done_rx(done_rx),
        .en_rx(en_rx),
        .data_rx(data_rx),
        .done_clk8(done_clk8),
        .en_clk8(en_clk8),
        .en_read(en_read),
        .addr_read(addr_read),
        .sectorcnt_read(sectorcnt_read),
        .done_read(done_read),
        .data_read(data_read),
        .data_read_valid(data_read_valid),
        .data_read_sectordone(data_read_sectordone),
        .cmd0_r_ok(cmd0_r_ok),
        .cmd1_r_ok(cmd1_r_ok),
        .cmd8_r_ok(cmd8_r_ok),
        .cmd55_r_ok(cmd55_r_ok),
        .acmd41_r_ok(acmd41_r_ok),
        .err(sd_err),
        .sd_idle(sd_idle),
        .state(sd_state),
        .debug_info(sd_debug_info),
        .debug_info_en(sd_debug_info_en),
        .acmd41_bypassed(acmd41_bypassed),
        .cmd58_prepared(cmd58_prepared),
        .cmd58_ccs(cmd58_ccs),
        .cmd6_r_ok(cmd6_r_ok)       //弃用
    );
    
    spi_controller spicon(
        .clk(CLK100MHZ),
        .rst(soft_rst[2]),
        .en(en_spi),
        .en_clk74(en_clk74),
        .done_clk74(done_clk74),
        .en_tx(en_tx),
        .done_tx(done_tx),
        .data_tx(data_tx),
        .en_rx(en_rx),
        .done_rx(done_rx),
        .data_rx(data_rx),
        .done_clk8(done_clk8),
        .en_clk8(en_clk8),
        .SPI_CLK(SD_SCK),
        .SPI_MOSI(SD_CMD),
        .SPI_MISO(SD_DAT0),
        .SPI_CSn(SD_DAT3),
        .state(spi_state),
        .SD_RESET(SD_RESET),
        //.cmd6_r_ok(cmd6_r_ok)
        .cmd6_r_ok(SW[6])
    );
    

/* ------------ INFO DISPLAY SECTION ------------ */

    assign LED[0] = en_start;
    assign LED[1] = cmd0_r_ok;
    assign LED[2] = cmd8_r_ok;
    assign LED[3] = cmd1_r_ok || cmd55_r_ok;
    assign LED[4] = cmd1_r_ok || acmd41_r_ok;
    assign LED[5] = cmd58_prepared;
    assign LED[6] = cmd58_ccs;
    assign LED[7] = cmd6_r_ok;
    assign LED[8] = start_ok;
    assign LED[15] = main_err;
    assign LED[14] = sd_idle;
    assign LED[13] = en_rx;
    assign LED[12] = en_tx;
    assign LED[11] = acmd41_bypassed;

    wire [15:0] memory_word;
    //assign memory_word = {memory[history_info_pageselect * 2 + 1], memory[history_info_pageselect * 2]};
    assign memory_word = 16'hABCD;

    //更新sd或顶层模块的debug info
    always @(posedge CLK100MHZ)begin
        if(soft_rst[2]) begin
            debug_info_en <= 0;
        end else if(sd_debug_info_en == 1'b1) begin
            //优先吸取 SD 控制器上的 debug info
            debug_info_en <= 1;
            debug_info <= sd_debug_info;
        end else if(main_debug_info_en == 1'b1) begin
            debug_info_en <= 1;
            debug_info <= main_debug_info;
        end else if(debug_info_en == 1'b1)
            debug_info_en <= 0;
    end

    sd_controller_disp sdctrldisp(
        .CLK100MHZ(CLK100MHZ),
        .rst(rst),
        .done_rx(done_rx),
        .data_rx(data_rx),
        .en_tx(en_tx),
        .done_tx(done_tx),
        .data_tx(data_tx),
        .sd_state(sd_state),
        .spi_state(spi_state),
        .main_state(main_state),
        .memory_word(memory_word),
        .debug_info(debug_info),
        .debug_info_en(debug_info_en),

        .SW(SW),
        .AN(AN),
        .C(C),
        .debug_info_pageselect(debug_info_pageselect),
        .history_info_pageselect(history_info_pageselect)
    );

/* ------------ SEQUENCE TIMING CONTROLLER SECTION ------------ */

    parameter S_RESET = 8'h0;
    parameter S_WAITSTART = 8'h01;
    parameter S_START = 8'h02;
    parameter S_WAITREAD = 8'h03;
    parameter S_READ0SEC = 8'h04;
    parameter S_READ0SEC_0 = 8'hC4;
    parameter S_READDBR = 8'h05;
    parameter S_STABLE = 8'hfd;
    parameter S_READFAT = 8'h06;
    parameter S_ERR = 8'hFE;

    reg [10:0] read_bytecnt;
    reg [31:0] read_seccnt;
    reg [7:0] nextstate;

    reg [31:0] target_sec;

    reg is_fdd_not_hddmbr;  //为1-FDD格式，文件系统直接从第一扇区开始；否则有MBR表
    reg [23:0] mbr_header;
    reg [7:0] BPB_SecPerClus;
    reg [15:0] BPB_RsvdSecCnt;
    reg [7:0] BPB_NumFATs;
    reg [31:0] BPB_FATSz32;

    wire [31:0] fat_sec;
    assign fat_sec = target_sec + BPB_RsvdSecCnt;
    wire [31:0] firstclus_sec;
    assign firstclus_sec = fat_sec + BPB_NumFATs * BPB_FATSz32;

    reg [31:0] curr_fat_sec;
    reg [31:0] curr_clus_sec;
    

    always @ (posedge CLK100MHZ) begin
        
        if(!rst && main_state != 0) begin
            soft_rst <= {soft_rst[1:0], 1'b0};
        end
        if(main_debug_info_en == 1) begin
            main_debug_info_en <= 0;
        end
        if(rst) begin
            main_state <= 0;
            read_bytecnt <= 0;
            read_seccnt <= 0;
            main_err <= 0;
            is_fdd_not_hddmbr <= 0;
        end else begin
            if(sd_err && main_state != 0 && main_state != S_ERR)
                main_state <= S_ERR;
            case(main_state)
                0:  //S_RESET
                begin
                    soft_rst <= 3'b111;
                    en_start <= 0;
                    main_state <= S_WAITSTART;
                end

                S_WAITSTART:
                begin
                    if(soft_rst[2] != 1'b1 && btn_start) begin
                        //按下了“开始”按钮
                        main_state <= S_START;
                    end
                end

                S_START:
                begin
                    if(start_ok) begin
                        main_state <= S_WAITREAD;
                    end else begin
                        en_start <= 1;
                    end
                end

                S_WAITREAD:
                begin
                    if(start_ok && sd_idle)
                    begin
                        //if(btn_read)
                        read_bytecnt <= 0;
                        read_seccnt <= 0;
                        sectorcnt_read <= 1;
                        addr_read <= ('d0);           //直接传扇区号
                        en_read <= 1;
                        main_state <= S_READ0SEC;
                        nextstate <= S_READDBR;
                    end else if (~start_ok) begin
                        main_state <= S_RESET;
                    end
                end

                S_READ0SEC_0:
                begin
                    //读硬盘的 0 扇区 MBR ，了解分区信息
                    if(done_read) begin
                        //读完，可以继续进行
                        main_state <= nextstate;
                        en_read <= 0;
                        if(nextstate != S_ERR) begin
                            //未发生错误
                            //接下来读DBR
                            read_bytecnt <= 0;
                            read_seccnt <= 0;
                            sectorcnt_read <= 1;
                            addr_read <= (target_sec);
                            is_fdd_not_hddmbr <= 0;
                            //en_read <= 1;
                            nextstate <= S_READFAT;
                        end
                        main_state <= nextstate;
                    end else begin
                        //data_read_valid 和 data_read_sectordone 可能同时有效
                        if(data_read_valid) begin
                            read_bytecnt <= read_bytecnt + 1;
                            if(read_bytecnt == 'd511) begin
                                //读满了
                                read_bytecnt <= 0;
                                
                                if(read_seccnt == sectorcnt_read - 1) begin
                                    //所需扇区都已经读完（本例程仅1）
                                    read_seccnt <= 0;
                                    //之后会触发done_read，由它所对应的分支决定如何跳转
                                end else
                                    read_seccnt <= read_seccnt + 1;
                            end
                            if(nextstate != S_ERR) begin
                                ;
                            end
                        end
                    end
                end

                S_READ0SEC:
                begin
                    //读硬盘的 0 扇区 MBR ，了解分区信息
                    if(done_read) begin
                        //读完，可以继续进行
                        main_state <= nextstate;
                        en_read <= 0;
                        if(nextstate != S_ERR) begin
                            //未发生错误
                            //接下来读DBR
                            read_bytecnt <= 0;
                            read_seccnt <= 0;
                            sectorcnt_read <= 1;
                            addr_read <= (target_sec);
                            //en_read <= 1;
                            nextstate <= S_READFAT;
                        end
                        main_state <= nextstate;
                    end else begin
                        //data_read_valid 和 data_read_sectordone 可能同时有效
                        if(data_read_valid) begin
                            read_bytecnt <= read_bytecnt + 1;
                            if(read_bytecnt == 'd511) begin
                                //读满了
                                read_bytecnt <= 0;
                                read_seccnt <= read_seccnt + 1;
                                if(read_seccnt == sectorcnt_read - 1) begin
                                    //所需扇区都已经读完（本例程仅1）
                                    read_seccnt <= 0;
                                    //之后会触发done_read，由它所对应的分支决定如何跳转
                                end
                            end
                            if(nextstate != S_ERR) begin
                                if(read_bytecnt == 'h0 || read_bytecnt == 'h1 || read_bytecnt == 'h2) begin
                                    mbr_header[read_bytecnt * 8 +: 8] <= data_read;
                                    if(read_bytecnt == 'h2)begin
                                        if(mbr_header[7:0] == 8'hEB && data_read == 8'h90 || mbr_header[7:0] == 8'hE9)begin
                                            //这是一个fat起始分区（FDD，无MBR）
                                            is_fdd_not_hddmbr <= 1;
                                            //直接跳转到DBR，就读0扇区
                                            target_sec <= 32'h00;
                                            nextstate <= S_STABLE;
                                        end
                                    end
                                end else if(is_fdd_not_hddmbr == 1'b0 && read_bytecnt == 'h1c2)begin
                                    //判断第一个分区的类型
                                    if(data_read == 'h0B || data_read == 'h0C) begin
                                        //是fat32，正确
                                        nextstate <= S_STABLE;
                                    end else begin
                                        main_debug_info_en <= 1;
                                        main_debug_info <= 
                                            {48'h0, 8'hC0, data_read};
                                        nextstate <= S_ERR;
                                    end
                                end else if(is_fdd_not_hddmbr == 1'b0 && read_bytecnt >= 'h1C6 && read_bytecnt <= 'h1C9) begin
                                    //读该分区的第一个扇区（DBR）的位置
                                    target_sec[(read_bytecnt - 'h1c6) * 8 +: 8] <= data_read;
                                end
                            end
                        end
                    end
                end

                S_STABLE:
                begin
                    main_debug_info_en <= 1;
                    main_debug_info <= {32'hCF, target_sec};
                    nextstate <= S_RESET;
                end

                S_READDBR:
                begin
                    //读 FAT 分区的第一扇区 DBR，了解更多信息
                    if(done_read) begin
                        //读完，可以继续进行
                        main_state <= nextstate;
                        en_read <= 0;
                        if(nextstate != S_ERR) begin
                            //未发生错误
                            //接下来读DBR
                            read_bytecnt <= 0;
                            read_seccnt <= 0;
                            sectorcnt_read <= 1;
                            addr_read <= (target_sec);
                            en_read <= 1;
                            nextstate <= S_READFAT;
                        end
                        main_state <= nextstate;
                    end else begin
                        //data_read_valid 和 data_read_sectordone 可能同时有效
                        if(data_read_valid) begin
                            read_bytecnt <= read_bytecnt + 1;
                            if(read_bytecnt == 'd511) begin
                                //读满了
                                read_bytecnt <= 0;
                                read_seccnt <= read_seccnt + 1;
                                if(read_seccnt == sectorcnt_read - 1) begin
                                    //所需扇区都已经读完（本例程仅1）
                                    read_seccnt <= 0;
                                    //之后会触发done_read，由它所对应的分支决定如何跳转
                                end
                            end
                            if(nextstate != S_ERR) begin
                                if(read_bytecnt == 'd13)begin
                                    BPB_SecPerClus <= data_rx;
                                end else if(read_bytecnt == 'd14 || read_bytecnt == 'd15) begin
                                    BPB_RsvdSecCnt[(read_bytecnt - 'd14) * 8 +: 8] <= data_rx;
                                end else if(read_bytecnt == 'd16) begin
                                    BPB_NumFATs <= data_rx;
                                end else if(read_bytecnt >= 'd36 && read_bytecnt < 'd36 + 'd4) begin
                                    BPB_FATSz32[(read_bytecnt - 'd36) * 8 +: 8] <= data_rx;
                                end
                            end
                        end
                    end
                end

                S_ERR:
                begin
                    main_err <= 1;
                end

                default:
                begin
                    main_state <= 0;
                end
            endcase
        end
    end

endmodule
