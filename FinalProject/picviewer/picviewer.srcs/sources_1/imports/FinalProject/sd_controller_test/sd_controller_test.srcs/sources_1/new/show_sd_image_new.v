`timescale 1ns / 1ps

module show_sd_image(
        input CLK100MHZ,
        input BTNU,
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
        output wire SD_RESET,
        output [3:0] VGA_R,
        output [3:0] VGA_G,
        output [3:0] VGA_B,
        output VGA_HS,
        output VGA_VS
        
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
    
        wire [10:0] curr_vga_x;
    wire [10:0] curr_vga_y;
    //720x400

    parameter VGA_W = 720;
    parameter VGA_H = 400;
    reg [3:0] curr_vga_r;
    reg [3:0] curr_vga_g;
    reg [3:0] curr_vga_b;
    reg curr_vga_latch;
    reg curr_vga_finished;
    
    
    wire [10:0] h_cnt;
    wire [9:0] v_cnt;
    wire inplace;
    wire vga_clk;

    vga vga_ctrl(
        CLK100MHZ,
        BTNC,
        vga_clk,
        VGA_HS,
        VGA_VS,
        h_cnt,
        v_cnt,
        inplace
    );

    img_ram_control imgctrl(
        .clk(CLK100MHZ),
        .vga_clk(vga_clk),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .vsync(VGA_VS),
        .inplace(inplace),
        .display_ena(1),
        .r(VGA_R),
        .g(VGA_G),
        .b(VGA_B),
        .in_x(curr_vga_x),
        .in_y(curr_vga_y),
        .in_r(curr_vga_r),
        .in_g(curr_vga_g),
        .in_b(curr_vga_b),
        .in_latch(curr_vga_latch),
        .in_finished(curr_vga_finished)
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
    parameter S_LOADFAT_FORROOT = 8'he0;
    parameter S_LOADFAT_FORBMP = 8'he1;
    parameter S_READROOTCLUS = 8'h10;
    parameter S_READROOTCLUS_DO = 8'h11;
    parameter S_SCANROOT_INIT = 8'h12;
    parameter S_SCANROOT_INC = 8'h13;
    parameter S_SCANROOT_DO = 8'h14;
    parameter S_READBMPCLUS = 8'h30;
    parameter S_READBMPCLUS_DO = 8'h31;
    parameter S_READBMPHEADER = 8'h32;
    parameter S_READBMPPALETTE = 8'h33;
    parameter S_READBMPPALETTE_DO = 8'h34;
    parameter S_READBMP = 8'h35;
    parameter S_AFTERREADBMP = 8'h3A;
    
    parameter S_WAITFORBUTTON = 8'h3F;
    parameter S_ERR = 8'hFE;

    parameter S_GETNEXTROOTCLUSTER = 8'hA0;
    parameter S_GETPREVROOTCLUSTER = 8'hA1;
    parameter S_AFTERGETTINGROOTCLUSTERNUM = 8'hA2;
    parameter S_GETNEXTBMPCLUSTER = 8'hA7;
    parameter S_AFTERGETTINGBMPCLUSTERNUM = 8'hA8;

    parameter S_GETROOTCLUSTERNUM = 8'hB0;
    parameter S_GETROOTCLUSTERNUM_THEN = 8'hB1;

    parameter S_READSEC = 8'hB2;
    parameter S_READSEC_DO = 8'hB3;


    reg [10:0] read_bytecnt;
    reg [31:0] read_seccnt;
    reg [7:0] nextstate;
    reg [7:0] nextstate2;

    reg [31:0] target_sec;

    reg is_fdd_not_hddmbr;  //为1-FDD格式，文件系统直接从第一扇区开始；否则有MBR表
    reg [23:0] mbr_header;
    reg [7:0] BPB_SecPerClus;
    reg [15:0] BPB_RsvdSecCnt;
    reg [7:0] BPB_NumFATs;
    reg [31:0] BPB_FATSz32;
    reg [31:0] BPB_RootClus;

    wire [31:0] fat_sec;
    assign fat_sec = target_sec + BPB_RsvdSecCnt;
    wire [31:0] firstclus_sec;
    assign firstclus_sec = fat_sec + BPB_NumFATs * BPB_FATSz32;
    wire [15:0] clus_size;
    assign clus_size = BPB_SecPerClus << 9;
    wire [10:0] diritems_per_clus;
    assign diritems_per_clus = clus_size >> 5;

    reg [7:0] root_cluster [0:32767];   //存根目录当前读出来的簇。簇大小最多32KB
    reg [31:0] cluster_index_history [0:63];   //根目录簇号的历史，方便向前翻图片，以栈的形式存
    reg [5:0] cih_top;  //该栈的指针

    reg [7:0] bmp_cluster [0:32767];   //存当前簇。簇大小最多32KB
    reg [31:0] curr_bmp_clus;   //当前簇号
    
    //请求要读的簇的编号。为FFFFFFFF时，出栈回退。
    reg [31:0] query_clustertoread;

    reg just_backward;

    reg [7:0] root_fat_sector [0:511];
    reg [31:0] curr_root_fat_sec;
    reg [7:0] bmp_fat_sector [0:511];
    reg [31:0] curr_bmp_fat_sec;
    
    reg [7:0] curr_bmp_offset;
    reg signed [16:0] curr_bmp_width;
    reg signed [16:0] curr_bmp_height;
    reg [16:0] curr_bmp_x;
    reg [16:0] curr_bmp_y;
    //reg curr_bmp_positive;
    wire [16:0] curr_bmp_height_abs;
    reg [7:0] curr_bmp_bitcount;
    
    wire [16:0] curr_bmp_real_x;
    wire [16:0] curr_bmp_real_y;

    assign curr_bmp_height_abs = (curr_bmp_height >= 0) ? curr_bmp_height : -curr_bmp_height;
    assign curr_bmp_real_x = curr_bmp_x;
    assign curr_bmp_real_y = (curr_bmp_height >= 0) ? (curr_bmp_height_abs - curr_bmp_y - 1) : curr_bmp_y;

    assign curr_vga_x = (VGA_H * curr_bmp_width >= VGA_W * curr_bmp_height) ? (curr_bmp_real_x * VGA_W / curr_bmp_width) : ((VGA_W - VGA_H * curr_bmp_width / curr_bmp_height_abs) / 2 + curr_bmp_real_x * VGA_H / curr_bmp_height_abs);
    assign curr_vga_y = (VGA_H * curr_bmp_width >= VGA_W * curr_bmp_height) ? ((VGA_H - VGA_W * curr_bmp_height_abs / curr_bmp_width) / 2 + curr_bmp_real_y * VGA_W / curr_bmp_width) : (curr_bmp_real_y * VGA_H / curr_bmp_height_abs);



    reg [31:0] result_fat_nextclus;
    reg [31:0] query_fat_clus;
    reg [31:0] addr_fat_clus;

    reg [31:0] bmp_filepos;
    reg bmp_need_next_clus;

    reg [10:0] diritem_index;

    reg [1:0] align_4bytes;

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

            if(curr_vga_finished)
                curr_vga_finished <= 0;
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
                            en_read <= 1;
                            nextstate <= S_READROOTCLUS;
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
                                            nextstate <= S_READDBR;
                                        end
                                    end
                                end else if(is_fdd_not_hddmbr == 1'b0 && read_bytecnt == 'h1c2)begin
                                    //判断第一个分区的类型
                                    if(data_read == 'h0B || data_read == 'h0C) begin
                                        //是fat32，正确
                                        nextstate <= S_READDBR;
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
                    ;
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
                            curr_root_fat_sec <= 32'hFFFFFFFF;
                            curr_bmp_fat_sec <= 32'hFFFFFFFF;
                            query_clustertoread <= BPB_RootClus;
                            main_debug_info_en <= 1;
                            main_debug_info <= {BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_FATSz32};
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
                                end else if(read_bytecnt >= 'd44 && read_bytecnt < 'd44 + 'd4) begin
                                    BPB_RootClus[(read_bytecnt - 'd44) * 8 +: 8] <= data_rx;
                                end
                            end
                        end
                    end
                end

                S_READROOTCLUS:
                begin
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= BPB_SecPerClus;

                    if(query_clustertoread == 32'hFFFFFFFF) begin
                        //出栈回退
                        if(cih_top == 0) begin
                            addr_read <= (cluster_index_history[cih_top - 1] - 2) * BPB_SecPerClus + firstclus_sec;
                            cih_top <= cih_top - 1;
                            just_backward <= 1;
                        end else begin
                            addr_read <= (BPB_RootClus - 2) * BPB_SecPerClus + firstclus_sec;
                            just_backward <= 0;
                        end
                    end else begin
                        cluster_index_history[cih_top] <= query_clustertoread;
                        cih_top <= cih_top + 1;
                        addr_read <= (query_clustertoread - 2) * BPB_SecPerClus + firstclus_sec;
                        just_backward <= 0;                        
                    end

                    main_state <= S_READROOTCLUS_DO;
                    
                end

                S_READROOTCLUS_DO:
                begin
                    if(done_read) begin
                        en_read <= 0;
                        read_bytecnt <= 0;
                        read_seccnt <= 0;
                        main_state <= S_SCANROOT_INIT;
                    end else begin
                        if(data_read_valid) begin
                            read_bytecnt <= read_bytecnt + 1;
                            if(read_bytecnt == 'd511) begin
                                read_bytecnt <= 0;
                                read_seccnt <= read_seccnt + 1;
                                if(read_seccnt == sectorcnt_read - 1) begin
                                    read_seccnt <= 0;
                                end
                            end
                            root_cluster[(read_seccnt << 9) | read_bytecnt] <= data_read;
                        end
                    end
                end

                S_SCANROOT_INIT:
                begin
                    if(just_backward)begin
                        diritem_index <= diritems_per_clus - 1;
                    end else begin
                        diritem_index <= 0;
                    end

                    main_state <= S_SCANROOT_DO;
                end

                S_SCANROOT_INC:
                begin
                    if(just_backward) begin
                        if(diritem_index == 0) begin
                            main_state <= S_GETPREVROOTCLUSTER;
                        end else begin
                            diritem_index <= diritem_index - 1;
                            main_state <= S_SCANROOT_DO;
                        end
                    end
                    else
                    begin
                        if(diritem_index == diritems_per_clus - 1) begin
                            main_state <= S_GETNEXTROOTCLUSTER;
                        end else begin
                            diritem_index <= diritem_index + 1;
                            main_state <= S_SCANROOT_DO;
                        end
                    end
                end

                S_SCANROOT_DO:
                begin
                    //判断这个目录项是否符合要求
                    
                    if({root_cluster[diritem_index << 5 + 'd20] , root_cluster[diritem_index << 5 + 'd21], root_cluster[diritem_index << 5 + 'd26], root_cluster[diritem_index << 5 + 'd27]} != 32'h0 && //簇号不为0
                        
                        {root_cluster[diritem_index << 5 + 'd28],root_cluster[diritem_index << 5 + 'd29],root_cluster[diritem_index << 5 + 'd30],root_cluster[diritem_index << 5 + 'd31]} > 0 && {root_cluster[diritem_index << 5 + 'd28],root_cluster[diritem_index << 5 + 'd29],root_cluster[diritem_index << 5 + 'd30],root_cluster[diritem_index << 5 + 'd31]} < (1 << 20) && //文件大小在1M以内

                        (root_cluster[diritem_index << 5 + 11] & 8'b00001111) != 8'b00001111 && //不具有 LONG_NAME 属性

                        {root_cluster[diritem_index << 5 + 8],root_cluster[diritem_index << 5 + 9],root_cluster[diritem_index << 5 + 10]} == 24'h424d50) begin
                            curr_bmp_clus <= {root_cluster[diritem_index << 5 + 'd20] , root_cluster[diritem_index << 5 + 'd21], root_cluster[diritem_index << 5 + 'd26], root_cluster[diritem_index << 5 + 'd27]};
                            main_state <= S_READBMPCLUS;
                        end else begin
                            main_state <= S_SCANROOT_INC;
                        end
                end

                S_GETNEXTROOTCLUSTER:
                //获取根目录文件的下一簇
                begin
                    if(cih_top == 0) begin
                        query_fat_clus <= BPB_RootClus;                        
                    end else begin
                        //取当前的Cluster数
                        query_fat_clus <= cluster_index_history[cih_top - 1];
                    end
                    //查FAT表，获取下一个cluster编号
                    nextstate <= S_AFTERGETTINGROOTCLUSTERNUM;
                    main_state <= S_GETROOTCLUSTERNUM;
                end

                S_AFTERGETTINGROOTCLUSTERNUM:
                begin
                    query_clustertoread <= result_fat_nextclus;
                    main_state <= S_READROOTCLUS;
                end

                S_GETPREVROOTCLUSTER:
                begin
                    result_fat_nextclus <= 32'hFFFFFFFF;
                    main_state <= S_AFTERGETTINGROOTCLUSTERNUM;
                end

                S_GETROOTCLUSTERNUM:
                //查FAT表，获取下一个cluster编号                
                begin
                    nextstate2 <= nextstate;
                    if((query_fat_clus << 2) >> 9 + fat_sec == curr_root_fat_sec)
                    begin
                        main_state <= S_GETROOTCLUSTERNUM_THEN;
                        //刚刚读的FAT扇区就是现在需要读的，不需要再读
                    end
                    else begin
                        //需要读取对应位置FAT扇区
                        addr_fat_clus <= (query_fat_clus << 2) >> 9 + fat_sec;
                        nextstate <= S_GETROOTCLUSTERNUM_THEN;
                        main_state <= S_READSEC;
                    end
                end

                S_GETROOTCLUSTERNUM_THEN:
                begin
                    result_fat_nextclus <= {root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 3], root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 2], root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 1], root_fat_sector[(query_fat_clus << 2) & 9'b111111111]};
                    main_state <= nextstate2;
                end

                S_READSEC:
                begin
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= 1;
                    addr_read <= addr_fat_clus;
                    main_state <= S_READSEC_DO;
                end

                S_READSEC_DO:
                begin
                    if(done_read) begin
                        //读完，可以继续进行
                        main_state <= nextstate;
                        read_bytecnt <= 0;
                        read_seccnt <= 0;
                        en_read <= 0;
                        curr_root_fat_sec <= addr_read;                        
                    end else begin
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
                            root_fat_sector[read_bytecnt] <= data_read;
                        end
                    end
                end

                S_READBMPCLUS:
                begin
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= BPB_SecPerClus;
                    addr_read <= (curr_bmp_clus - 2) * BPB_SecPerClus + firstclus_sec;
                    nextstate <= S_READBMPHEADER;
                    main_state <= S_READBMPCLUS_DO;
                end

                S_READBMPCLUS_DO:
                begin
                    if(done_read) begin
                        en_read <= 0;
                        read_bytecnt <= 0;
                        read_seccnt <= 0;
                        main_state <= nextstate;
                    end else begin
                        if(data_read_valid) begin
                            read_bytecnt <= read_bytecnt + 1;
                            if(read_bytecnt == 'd511) begin
                                read_bytecnt <= 0;
                                read_seccnt <= read_seccnt + 1;
                                if(read_seccnt == sectorcnt_read - 1)begin
                                    read_seccnt <= 0;
                                end
                            end
                            bmp_cluster[(read_seccnt << 9)|read_bytecnt] <= data_read;
                        end 
                    end
                end

                S_READBMPHEADER:
                begin
                    if({bmp_cluster[0], bmp_cluster[1]} != 16'h424D)begin
                        //头不是 BM 
                        
                    end else if(bmp_cluster[8'h19][7] == 1'b1) begin
                        //正向位图
                    end else if({bmp_cluster[8'h21],bmp_cluster[8'h20],bmp_cluster[8'h1f],bmp_cluster[8'h1e]} != 0) begin
                        //压缩位图
                    end else if({bmp_cluster[8'h31],bmp_cluster[8'h30],bmp_cluster[8'h2f],bmp_cluster[8'h2e]} != 0) begin
                        //有不同于默认值调色板的位图
                    end else if({bmp_cluster[8'h1d],bmp_cluster[8'h1c]} != 24) begin
                        //不支持的位深
                    end
                    else begin
                        //curr_bmp_positive <= {bmp_cluster['h19],bmp_cluster['h18],bmp_cluster['h17],bmp_cluster['h16]}[31] == 1'b0;
                        curr_bmp_offset <= {bmp_cluster['hd],bmp_cluster['hc],bmp_cluster['hc],bmp_cluster['ha]};
                        curr_bmp_width <= {bmp_cluster['h15],bmp_cluster['h14],bmp_cluster['h13],bmp_cluster['h12]};
                        curr_bmp_height <= {bmp_cluster['h19],bmp_cluster['h18],bmp_cluster['h17],bmp_cluster['h16]};
                        curr_bmp_bitcount <= {bmp_cluster['h1d],bmp_cluster['h1c]};
                        bmp_filepos <= curr_bmp_offset;
                        curr_bmp_x <= 0;
                        curr_bmp_y <= 0;
                        bmp_need_next_clus <= 0;
                        align_4bytes <= 0;
                        curr_vga_latch <= 0;
                        curr_vga_finished <= 1;
                        //curr_bmp_palettecnt <= ({bmp_cluster['h1d],bmp_cluster['h1c]} < 16) ? (1 << {bmp_cluster['h1d],bmp_cluster['h1c]}) : 0;
                        main_state <= S_READBMPPALETTE;
                    end
                end

                S_READBMPPALETTE:
                begin
                    main_state <= S_READBMP;
                end

                S_READBMP:
                begin
                    if(bmp_need_next_clus)begin
                        bmp_need_next_clus <= 0;
                        main_state <= S_GETNEXTBMPCLUSTER;
                    end else begin
                        if(curr_vga_latch)
                            curr_vga_latch <= 0;
                        if(curr_bmp_x == curr_bmp_width - 1) begin
                            curr_bmp_x <= 0;
                            //4位对齐
                            bmp_filepos <= bmp_filepos + 3 + ((~(align_4bytes + 3) + 1) & 2'b11);
                            if((bmp_filepos + 3 + ((~(align_4bytes + 3) + 1) & 2'b11)) / clus_size != bmp_filepos / clus_size) begin
                                bmp_need_next_clus <= 1;
                            end
                            align_4bytes <= 0;
                            curr_bmp_y <= curr_bmp_y + 1;
                            if(curr_bmp_y == curr_bmp_height_abs -1) begin
                                //读完了
                                main_state <= S_AFTERREADBMP;
                            end
                        end else begin
                            curr_bmp_x <= curr_bmp_x + 1;
                            bmp_filepos <= bmp_filepos + 3;
                            if((bmp_filepos + 3) / clus_size != bmp_filepos / clus_size)
                                bmp_need_next_clus <= 1;
                            align_4bytes <= align_4bytes + 3;
                        end

                        //读该像素
                        curr_vga_r <= bmp_cluster[bmp_filepos % clus_size + 2][7:4];
                        curr_vga_g <= bmp_cluster[bmp_filepos % clus_size + 1][7:4];
                        curr_vga_b <= bmp_cluster[bmp_filepos % clus_size + 0][7:4];
                        curr_vga_latch <= 1; 
                    end
                end

                S_AFTERREADBMP:
                begin
                    curr_vga_latch <= 0;
                    curr_vga_finished <= 1;
                    main_state <= S_STABLE;
                end

                S_GETNEXTBMPCLUSTER:
                begin
                    query_fat_clus <= curr_bmp_clus;
                    nextstate <= S_AFTERGETTINGBMPCLUSTERNUM;
                    main_state <= S_GETROOTCLUSTERNUM;
                end

                S_AFTERGETTINGBMPCLUSTERNUM:
                begin
                    curr_bmp_clus <= result_fat_nextclus;
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= BPB_SecPerClus;
                    addr_read <= (curr_bmp_clus - 2) * BPB_SecPerClus + firstclus_sec;
                    nextstate <= S_READBMP;
                    main_state <= S_READBMPCLUS_DO;
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
