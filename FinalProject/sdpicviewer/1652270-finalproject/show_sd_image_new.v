`timescale 1ns / 1ps

module show_sd_image(
        input CLK100MHZ,
        input BTNU,
        input BTNC,
        input BTNL,
        input BTND,
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

    wire resp_startvalid_long;
    wire [10:0] resp_bytecnt;
/* ------------ SD AND SPI CONTROLLER INSTANTIATION SECTION ------------ */
    wire rst;
    //assign rst = BTNC;
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
        .cmd6_r_ok(cmd6_r_ok),       //弃用
        .resp_startvalid_long(resp_startvalid_long),
        .resp_bytecnt(resp_bytecnt)
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
        .cmd6_r_ok(cmd6_r_ok),
        .speed_choose(SW[15:14])
    );
    
    reg [31:0] curr_vga_x;
    reg [31:0] curr_vga_y;
    //720x400

    parameter VGA_W = 720;
    parameter VGA_H = 400;
    reg [7:0] curr_r;
    reg [7:0] curr_g;
    reg [7:0] curr_b;
    wire [3:0] curr_vga_r;
    wire [3:0] curr_vga_g;
    wire [3:0] curr_vga_b;
    assign curr_vga_r = curr_r[7:4];
    assign curr_vga_g = curr_g[7:4];
    assign curr_vga_b = curr_b[7:4];
    reg curr_vga_latch;
    reg curr_vga_finished;
    reg curr_vga_clear;
    reg curr_vga_err;
    
    
    wire [10:0] x;
    wire [9:0] y;
    wire inplace;
    wire vga_clk;
    
    wire curr_imgram_canwrite;

    vga vga_ctrl(
        CLK100MHZ,
        BTNC,
        vga_clk,
        VGA_HS,
        VGA_VS,
        x,
        y,
        inplace
    );

    img_ram_control imgctrl(
        .clk(CLK100MHZ),
        .vga_clk(vga_clk),
        .x(x),
        .y(y),
        .vsync(VGA_VS),
        .inplace(inplace),
        .display_ena(1),
        .r(VGA_R),
        .g(VGA_G),
        .b(VGA_B),
        .in_x(curr_vga_x[10:0]),
        .in_y(curr_vga_y[10:0]),
        .in_r(curr_vga_r),
        .in_g(curr_vga_g),
        .in_b(curr_vga_b),
        .in_latch(curr_vga_latch),
        .in_clear(curr_vga_clear),
        .in_err(curr_vga_err),
        .in_finished(curr_vga_finished),
        .out_canwrite(curr_imgram_canwrite)
    );

    
    reg bmp_cluster_we;
    
    reg [7:0] bmp_cluster_dina;
    wire [7:0] bmp_cluster_doutb;
    
    reg [14:0] bmp_cluster_addra;
    reg [14:0] bmp_cluster_addrb;

    bmp_cluster_blkmem bmp_cluster (
        .clka(CLK100MHZ),    // input wire clka
        .wea(bmp_cluster_we),      // input wire [0 : 0] wea
        .addra(bmp_cluster_addra),  // input wire [14 : 0] addra
        .dina(bmp_cluster_dina),    // input wire [7 : 0] dina
        .clkb(CLK100MHZ),    // input wire clkb
        .addrb(bmp_cluster_addrb),  // input wire [14 : 0] addrb
        .doutb(bmp_cluster_doutb)  // output wire [7 : 0] doutb
        );

    reg root_cluster_we;
    reg [7:0] root_cluster_dina;
    reg [14:0] root_cluster_addra;
    wire [7:0] root_cluster_doutb;
    reg [14:0] root_cluster_addrb;

    root_cluster root_cluster (
        .clka(CLK100MHZ),
        .wea(root_cluster_we),
        .addra(root_cluster_addra),
        .dina(root_cluster_dina),
        .clkb(CLK100MHZ),
        .addrb(root_cluster_addrb),
        .doutb(root_cluster_doutb)
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
    reg [7:0] root_fat_sector [0:511];
    reg [31:0] curr_root_fat_sec;
    reg [7:0] bmp_fat_sector [0:511];
    reg [31:0] curr_bmp_fat_sec;
    
    reg [31:0] cluster_index_history [0:63];   //根目录簇号的历史，方便向前翻图片，以栈的形式存
    reg [5:0] cih_top;  //该栈的指针
    reg [31:0] curr_bmp_clus;   //当前簇号
        
    assign memory_word = (SW[6:4] == 1)?{root_fat_sector[history_info_pageselect * 2 + 1], root_fat_sector[history_info_pageselect * 2]}:{bmp_fat_sector[history_info_pageselect * 2 + 1], bmp_fat_sector[history_info_pageselect * 2]};
    //assign memory_word = 16'hABCD;

    reg [31:0] img_cnt;    

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
        .resp_startvalid_long(resp_startvalid_long),
        .resp_bytecnt(resp_bytecnt),
        .curr_bmp_fat_sec(curr_bmp_fat_sec),
        .curr_root_fat_sec(curr_root_fat_sec),
        .curr_root_clus(cluster_index_history[cih_top - 1]),
        .curr_bmp_clus(curr_bmp_clus),
        .latch_n(BTND),
        .img_cnt(img_cnt),

        .SW(SW),
        .AN(AN),
        .C(C),
        //.debug_info_pageselect(debug_info_pageselect),
        .history_info_pageselect(history_info_pageselect)
    );



/* ------------ SEQUENCE TIMING CONTROLLER SECTION ------------ */

//BTNL, BTNR 捕获器
    reg [2:0] BTNL_down;
    reg [2:0] BTNR_down;
    reg [2:0] BTNC_down;

    always @ (posedge CLK100MHZ)
    begin
        BTNL_down <= {BTNL_down[1:0], BTNL};
        BTNR_down <= {BTNR_down[1:0], BTNR};
        BTNC_down <= {BTNC_down[1:0], BTNC};
    end

    wire autopage;
    assign autopage = SW[7];
    assign rst = BTNC_down;

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
    parameter S_READBMPHEADER_INIT = 8'h3E;
    parameter S_READBMPHEADER_TEST = 8'h3D;
    parameter S_READBMPHEADER = 8'h32;
    parameter S_READBMPPALETTE = 8'h33;
    parameter S_READBMPPALETTE_DO = 8'h34;
    parameter S_READBMP = 8'h36;
    parameter S_READBMP_UPDATE = 8'h37;
    parameter S_READBMP_INIT = 8'h35;
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

    parameter S_GETBMPCLUSTERNUM = 8'hC0;
    parameter S_GETBMPCLUSTERNUM_THEN = 8'hC1;

    parameter S_WAITFORSWITCH = 8'hC3;

    parameter S_READROOTFATSEC = 8'hB2;
    parameter S_READROOTFATSEC_DO = 8'hB3;

    parameter S_GETROOTCLUSTERNUM_CONFIRM = 8'hC8;
    parameter S_READBMP_CONFIRM = 8'hC9;

    parameter T_AUTOPAGE = 32'd550000000;        //5.5s
    parameter T_AUTOPAGE_BTNSHIELD = 32'd10000000;        //0.1s


    reg [10:0] read_bytecnt;
    reg [31:0] read_seccnt;
    reg [7:0] nextstate;
    reg [7:0] nextstate2;
    reg [7:0] nextstate3;

    reg [31:0] target_sec;

    reg is_fdd_not_hddmbr;  //为1：FDD格式，文件系统直接从第一扇区开始；否则有MBR表
    reg [23:0] mbr_header;
    reg [5:0] BPB_SecPerClus_log2;
    reg [15:0] BPB_RsvdSecCnt;
    reg [7:0] BPB_NumFATs;
    reg [31:0] BPB_FATSz32;
    reg [31:0] BPB_RootClus;

    wire [31:0] fat_sec;
    assign fat_sec = target_sec + BPB_RsvdSecCnt;
    wire [31:0] firstclus_sec;
    assign firstclus_sec = fat_sec + BPB_NumFATs * BPB_FATSz32;
    wire [5:0] clus_size_log2;
    assign clus_size_log2 = BPB_SecPerClus_log2 + 9;
    wire [5:0] diritems_per_clus_log2;
    assign diritems_per_clus_log2 = clus_size_log2 - 5;


    //reg [7:0] root_cluster [0:16383];   //存根目录当前读出来的簇。簇大小最多8KB
    

    //reg [7:0] bmp_cluster [0:32767];   //存当前簇。簇大小最多32KB

    
    //请求要读的簇的编号。为FFFFFFFD时，出栈回退，为FFFFFFFE时，清栈，回到根簇。
    reg [31:0] query_clustertoread;

    reg just_backward;
    reg [31:0] autopage_cnt;
    
    
    reg [7:0] curr_bmp_offset;
    reg [31:0] curr_bmp_width;
    reg [31:0] curr_bmp_height;
    reg [31:0] curr_bmp_x;
    reg [31:0] curr_bmp_y;
    //reg curr_bmp_positive;
    reg [31:0] curr_bmp_height_abs;
    reg [7:0] curr_bmp_bitcount;

    reg [19:0] whratio_p1;  //=VGA_H * curr_bmp_width;
    reg [19:0] whratio_p2;  //=VGA_W * curr_bmp_height;



    reg [31:0] result_fat_nextclus;
    reg [31:0] query_fat_clus;
    reg [31:0] addr_fat_clus;

    reg [31:0] bmp_filepos;
    reg bmp_need_next_clus;

    reg [10:0] diritem_index;

    reg [1:0] align_4bytes;
    
    //wire [14:0] root_cluster_addr;
    //assign root_cluster_addr = (read_seccnt << 9) | read_bytecnt;

    reg [5:0] scanroot_cnt;
    reg [31:0] scanroot_tmp;
    reg [31:0] bmpheader_tmp;
    reg [6:0] readheader_cnt;


    reg [4:0] readbmp_update_cnt;

    reg clusternum_is_for_bmp;
    reg readbmp_juststart;
    
    always @ (posedge CLK100MHZ) begin
        
        if(!rst && main_state != 0) begin
            //延时reset
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
            curr_r <= 0;
        end else if(sd_err && main_state != 0 && main_state != S_ERR && soft_rst == 0)
            main_state <= S_ERR;
        else begin
            if(curr_vga_finished)
                curr_vga_finished <= 0;

            if(curr_vga_clear)
                curr_vga_clear <= 0;

            if(curr_vga_err)
                curr_vga_err <= 0;

            if(bmp_cluster_we == 1'b1)
                bmp_cluster_we <= 1'b0;

            if(root_cluster_we == 1'b1)
                root_cluster_we <= 1'b0;
            case(main_state)
                0:  //S_RESET
                begin
                    soft_rst <= 3'b111;
                    en_start <= 0;
                    en_read <= 0;
                    curr_vga_clear <= 1;
                    curr_vga_err <= 0;
                    curr_vga_latch <= 0;
                    main_state <= S_WAITSTART;
                    clusternum_is_for_bmp <= 0;
                    curr_vga_x <= 0;
                    curr_vga_y <= 0;
                    whratio_p1 <= 0;
                    whratio_p2 <= 0;
                    curr_bmp_x <= 0;
                    curr_bmp_y <= 0;
                    curr_bmp_width <= 0;
                    curr_bmp_height <= 0;
                    readbmp_juststart <= 0;
                    img_cnt <= 0;
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
                            main_debug_info <= {2'b00, BPB_SecPerClus_log2, BPB_RsvdSecCnt, BPB_NumFATs, BPB_FATSz32};
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
                                    case (data_rx)
                                        1:BPB_SecPerClus_log2 <= 0;
                                        2:BPB_SecPerClus_log2 <= 1;
                                        4:BPB_SecPerClus_log2 <= 2;
                                        8:BPB_SecPerClus_log2 <= 3;
                                        16:BPB_SecPerClus_log2 <= 4;
                                        32:BPB_SecPerClus_log2 <= 5;
                                        64:BPB_SecPerClus_log2 <= 6;
                                        default:begin
                                            main_debug_info <= {48'h0, 8'hDC, data_rx};
                                            main_debug_info_en <= 1;
                                            main_state <= S_ERR;
                                        end
                                    endcase
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
                    sectorcnt_read <= (1 << BPB_SecPerClus_log2);

                    if(query_clustertoread == 32'hFFFFFFFD) begin
                        //出栈回退
                        if(cih_top == 1) begin
                            img_cnt <= 0;
                            addr_read <= ((cluster_index_history[cih_top - 1] - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                            just_backward <= 0;
                        end else if(cih_top != 0) begin
                            addr_read <= ((cluster_index_history[cih_top - 2] - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                            cih_top <= cih_top - 1;
                            just_backward <= 1;
                        end else begin
                            img_cnt <= 0;
                            addr_read <= ((BPB_RootClus - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                            cluster_index_history[0] <= BPB_RootClus;
                            cih_top <= 1;
                            just_backward <= 0;
                        end
                    end else if(query_clustertoread == 32'hFFFFFFFE)begin
                        //清栈，回到第一页
                        img_cnt <= 0;
                        cluster_index_history[0] <= BPB_RootClus;
                        cih_top <= 1;
                        addr_read <= ((BPB_RootClus - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                        just_backward <= 0;
                    end else begin
                        cluster_index_history[cih_top] <= query_clustertoread;
                        cih_top <= cih_top + 1;
                        addr_read <= ((query_clustertoread - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                        just_backward <= 0;                        
                    end

                    main_state <= S_READROOTCLUS_DO;
                    //main_state <= S_STABLE;
                    
                end

                S_READROOTCLUS_DO:
                begin
                    if(done_read) begin
                        root_cluster_we <= 0;
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
                            root_cluster_we <= 1;
                            root_cluster_addra <= (read_seccnt << 9) | read_bytecnt;
                            root_cluster_dina <= data_read;
                            //root_cluster[root_cluster_addr] <= data_read;
                        end
                    end
                end

                S_SCANROOT_INIT:
                begin
                    if(just_backward)begin
                        diritem_index <= (1 << diritems_per_clus_log2) - 1;
                    end else begin
                        diritem_index <= 0;
                    end
                    scanroot_cnt <= 0;
                    main_debug_info_en <= 1;
                    main_debug_info <= {32'hC4, addr_read};
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
                        if(diritem_index == (1 << diritems_per_clus_log2) - 1) begin
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
                    if(scanroot_cnt >= 0 && scanroot_cnt < 21)
                        scanroot_cnt <= scanroot_cnt + 1;
                
                    case (scanroot_cnt)
                        0:
                        begin
                            //root_cluster_addrb <= (diritem_index << 5) + 'd26;
                            root_cluster_addrb <= (diritem_index << 5) + 'd26;
                            //root_cluster_addrb <= (diritem_index << 5) + 8;
                        end

                        1,2,3,4,5:
                        begin
                            //输出有1个间隔期，所以cnt==1时输出无效。
                            curr_bmp_clus[((scanroot_cnt - 2) << 3) +: 8] <= root_cluster_doutb;
                            root_cluster_addrb <= root_cluster_addrb + ((scanroot_cnt == 2) ? -7 : 1);
                            
                        end

                        6:
                        begin
                            if(curr_bmp_clus == 0)begin
                                //main_debug_info <= {32'h0, {2{8'hA0}}};
                                //main_debug_info_en <= 1;
                                scanroot_cnt <= 0;
                                main_state <= S_SCANROOT_INC;
                            end else begin
                                root_cluster_addrb <= (diritem_index << 5) + 8;
                                
                            end
                        end

                        7,8,9,10:
                        begin
                            //ext
                            scanroot_tmp[((scanroot_cnt - 8) << 3) +: 8] <= root_cluster_doutb;
                            root_cluster_addrb <= root_cluster_addrb + 1;
                        end

                        11:
                        begin
                            if(scanroot_tmp[23:0] != 24'h504d42)begin
                                main_debug_info <= {curr_bmp_clus, scanroot_tmp[23:0], 8'hA3};
                                main_debug_info_en <= 1;
                                scanroot_cnt <= 0;
                                main_state <= S_SCANROOT_INC;
                            end else begin
                                //scanroot_cnt <= 0;
                                //main_state <= S_READBMPCLUS;
                                root_cluster_addrb <= (diritem_index << 5) + 'd28;
                            end
                        end
                        
                        12,13,14,15,16:
                        begin
                            //filesize
                            scanroot_tmp[((scanroot_cnt - 13) << 3) +: 8] <= root_cluster_doutb;
                            root_cluster_addrb <= root_cluster_addrb + 1;
                        end
                        
                        17:
                        begin
                            //if(scanroot_tmp >= (1 << 20))begin
                            //    main_debug_info <= {scanroot_tmp, {2{8'hA1}}};
                            //    main_debug_info_en <= 1;
                            //    scanroot_cnt <= 0;
                            //    main_state <= S_SCANROOT_INC;
                            //end else begin
                                root_cluster_addrb <= (diritem_index << 5) + 11;
                            //end
                        end
                        
                        18:
                        ;

                        19:
                        begin
                            if((root_cluster_doutb & 8'b00001111) == 8'b00001111)begin
                                main_debug_info <= {24'h0, root_cluster_doutb, {2{8'hA2}}};
                                main_debug_info_en <= 1;
                                scanroot_cnt <= 0;
                                main_state <= S_SCANROOT_INC;
                            end else begin
                                root_cluster_addrb <= (diritem_index << 5);
                            end
                        end

                        20:
                        ;

                        21:
                        begin
                            if((root_cluster_doutb) == 8'hE5)begin
                                main_debug_info <= {24'h0, root_cluster_doutb, {2{8'hA9}}};
                                main_debug_info_en <= 1;
                                scanroot_cnt <= 0;
                                main_state <= S_SCANROOT_INC;
                            end else begin
                                scanroot_cnt <= 0;
                                if(just_backward)
                                    img_cnt <= img_cnt - 1;
                                else
                                    img_cnt <= img_cnt + 1;
                                main_state <= S_READBMPCLUS;
                            end
                        end
                        
                        default:
                        begin
                            scanroot_cnt <= 0;
                        end
                    endcase
//                    if({root_cluster[(diritem_index << 5) + 'd20] , root_cluster[(diritem_index << 5) + 'd21], root_cluster[(diritem_index << 5) + 'd26], root_cluster[(diritem_index << 5) + 'd27]} != 32'h0 && //簇号不为0
                        
//                        {root_cluster[(diritem_index << 5) + 'd28],root_cluster[(diritem_index << 5) + 'd29],root_cluster[(diritem_index << 5) + 'd30],root_cluster[(diritem_index << 5) + 'd31]} > 0 && {root_cluster[(diritem_index << 5) + 'd28],root_cluster[(diritem_index << 5) + 'd29],root_cluster[(diritem_index << 5) + 'd30],root_cluster[(diritem_index << 5) + 'd31]} < (1 << 20) && //文件大小在1M以内

//                        (root_cluster[(diritem_index << 5) + 11] & 8'b00001111) != 8'b00001111 && //不具有 LONG_NAME 属性

//                        {root_cluster[(diritem_index << 5) + 8],root_cluster[(diritem_index << 5) + 9],root_cluster[(diritem_index << 5) + 10]} == 24'h424d50) begin
//                            curr_bmp_clus <= {root_cluster[(diritem_index << 5) + 'd20] , root_cluster[(diritem_index << 5) + 'd21], root_cluster[(diritem_index << 5) + 'd26], root_cluster[(diritem_index << 5) + 'd27]};
//                            main_state <= S_READBMPCLUS;
//                        end else begin
//                            main_state <= S_SCANROOT_INC;
//                        end
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
                    main_debug_info_en <= 1;
                    main_debug_info <= {32'hB6, result_fat_nextclus};
                    if(result_fat_nextclus[30:0] != 31'hfffffff)begin
                        //也包括了FFFFFFFD回退
                        query_clustertoread <= result_fat_nextclus;
                    end else begin
                        query_clustertoread <= 32'hFFFFFFFE;    //回到第一页，重置
                    end
                    main_state <= S_READROOTCLUS;                    
                end

                S_GETPREVROOTCLUSTER:
                begin
                    result_fat_nextclus <= 32'hFFFFFFFD;
                    main_state <= S_AFTERGETTINGROOTCLUSTERNUM;
                end

                S_GETROOTCLUSTERNUM:
                //查FAT表，获取下一个cluster编号                
                begin
                    nextstate2 <= nextstate;
                    if(((query_fat_clus << 2) >> 9) + fat_sec == (clusternum_is_for_bmp ? curr_bmp_fat_sec : curr_root_fat_sec))
                    begin
                        main_state <= S_GETROOTCLUSTERNUM_THEN;
                        //刚刚读的FAT扇区就是现在需要读的，不需要再读
                    end else begin
                        //需要读取对应位置FAT扇区
                        addr_fat_clus <= ((query_fat_clus << 2) >> 9) + fat_sec;
                        nextstate <= S_GETROOTCLUSTERNUM_THEN;
                        main_state <= S_READROOTFATSEC;
                    end
                end

                S_GETROOTCLUSTERNUM_THEN:
                begin
                    main_debug_info_en <= 1;
                    main_debug_info <= {32'hB5, addr_read};
                    if(clusternum_is_for_bmp) begin
                        result_fat_nextclus <= {bmp_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 3], bmp_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 2], bmp_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 1], bmp_fat_sector[(query_fat_clus << 2) & 9'b111111111]};
                    end else begin
                        result_fat_nextclus <= {root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 3], root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 2], root_fat_sector[((query_fat_clus << 2) & 9'b111111111) + 1], root_fat_sector[(query_fat_clus << 2) & 9'b111111111]};
                    end

                    main_state <= nextstate2;
                    if(clusternum_is_for_bmp)begin
                        curr_bmp_fat_sec <= addr_read;                        
                    end else begin
                        curr_root_fat_sec <= addr_read;
                    end
                end

                S_READROOTFATSEC:
                begin
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= 1;
                    addr_read <= addr_fat_clus;
                    main_state <= S_READROOTFATSEC_DO;
                end

                S_READROOTFATSEC_DO:
                begin
                    if(done_read) begin
                        //读完，可以继续进行
                        main_state <= nextstate;
                        read_bytecnt <= 0;
                        read_seccnt <= 0;
                        en_read <= 0;
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
                            if(clusternum_is_for_bmp)
                                bmp_fat_sector[read_bytecnt] <= data_read;
                            else
                                root_fat_sector[read_bytecnt] <= data_read;
                        end
                    end
                end

                S_READBMPCLUS:
                begin
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= (1 << BPB_SecPerClus_log2);
                    addr_read <= ((curr_bmp_clus - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                    readheader_cnt <= 0;
//                    nextstate <= S_READBMPHEADER_TEST;
                    nextstate <= S_READBMPHEADER_INIT;
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
                            bmp_cluster_we <= 1;
                            bmp_cluster_addra <= (read_seccnt << 9) | read_bytecnt;
                            bmp_cluster_dina <= data_read;
                        end 
                    end
                end

                S_READBMPHEADER_TEST:
                begin
                    readheader_cnt <= readheader_cnt + 1;
                    case(readheader_cnt)
                        0:
                        begin
                            bmp_cluster_addrb <= 1;
                            main_debug_info <= {48'h0, 8'h21, bmp_cluster_doutb};
                            main_debug_info_en <= 1;                            
                        end

                        1:
                        begin
                            main_debug_info <= {48'h0, 8'h22, bmp_cluster_doutb};
                            main_debug_info_en <= 1;                           
                        end

                        2:
                        begin
                            main_debug_info <= {48'h0, 8'h23, bmp_cluster_doutb};
                            main_debug_info_en <= 1;                            
                        end

                        3:
                        begin
                            main_debug_info <= {48'h0, 8'h24, bmp_cluster_doutb};
                            main_debug_info_en <= 1;
                            main_state <= S_STABLE;
                        end
                    endcase
                end

                S_READBMPHEADER_INIT:
                begin
                    if(readheader_cnt >= 0 && readheader_cnt < 44)
                        readheader_cnt <= readheader_cnt + 1;
                    else if (readheader_cnt == 44) begin
                        readheader_cnt <= 0;
                        main_state <= S_READBMPHEADER;
                    end
                    case (readheader_cnt)
                        0:
                        begin
                            curr_vga_latch <= 0;
                            curr_vga_finished <= 0;
                            curr_vga_clear <= 1;
                            bmp_cluster_addrb <= 0;
                        end
                        1,2,3:
                        begin
                            bmpheader_tmp[((readheader_cnt - 2) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        4:
                        begin
                            if(bmpheader_tmp[15:0] != 16'h4D42) begin
                                main_debug_info <= {16'h0, bmpheader_tmp[15:0], {2{8'h90}}};
                                main_debug_info_en <= 1;
                                curr_vga_err <= 1'b1;
                                readheader_cnt <= 0;
                                main_state <= S_AFTERREADBMP;
                            end
                            bmp_cluster_addrb <= 15'h16;
                        end

                        5,6,7,8,9:
                        begin
                            bmpheader_tmp[((readheader_cnt - 6) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        10:
                        begin
                            curr_bmp_height <= bmpheader_tmp;
                            main_debug_info <= {bmpheader_tmp, {2{8'h91}}};
                            main_debug_info_en <= 1;
                            // if(bmpheader_tmp[31] == 1'b1) begin
                            //     ////////
                            //     curr_vga_err <= 1'b1;
                            //     readheader_cnt <= 0;                          
                            //     main_state <= S_AFTERREADBMP;
                            // end
                            bmp_cluster_addrb <= 15'h1E;
                        end

                        11,12,13,14,15:
                        begin
                            bmpheader_tmp[((readheader_cnt - 12) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        16:
                        begin
                            if(bmpheader_tmp != 0) begin
                                main_debug_info <= {bmpheader_tmp, {2{8'h92}}};
                                main_debug_info_en <= 1;
                                curr_vga_err <= 1'b1;
                                readheader_cnt <= 0;                          
                                main_state <= S_AFTERREADBMP;
                            end
                            bmp_cluster_addrb <= 15'h2E;
                        end

                        17,18,19,20,21:
                        begin
                            bmpheader_tmp[((readheader_cnt - 18) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        22:
                        begin

                            if(bmpheader_tmp != 0) begin
                                main_debug_info <= {bmpheader_tmp, {2{8'h93}}};
                                main_debug_info_en <= 1;
                                curr_vga_err <= 1'b1;
                                readheader_cnt <= 0;
                                main_state <= S_AFTERREADBMP;
                            end
                            bmp_cluster_addrb <= 15'h1C;
                        end

                        23,24,25:
                        begin
                            bmpheader_tmp[((readheader_cnt - 24) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        26:
                        begin
                            curr_bmp_bitcount <= bmpheader_tmp[15:0];
                            if(bmpheader_tmp[15:0] != 24) begin
                                main_debug_info <= {16'h0,bmpheader_tmp[15:0], {2{8'h94}}};
                                main_debug_info_en <= 1;
                                curr_vga_err <= 1'b1;
                                readheader_cnt <= 0;
                                main_state <= S_AFTERREADBMP;
                            end
                            bmp_cluster_addrb <= 15'h0A;
                        end

                        27,28,29,30,31:
                        begin
                            bmpheader_tmp[((readheader_cnt - 28) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        32:
                        begin
                            curr_bmp_offset <= bmpheader_tmp;
                            bmp_cluster_addrb <= 15'h12;
                        end

                        33,34,35,36,37:
                        begin
                            bmpheader_tmp[((readheader_cnt - 34) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        38:
                        begin
                            curr_bmp_width <= bmpheader_tmp;
                            main_debug_info <= {bmpheader_tmp, 32'h97};
                            main_debug_info_en <= 1;
                            bmp_cluster_addrb <= 15'h16;
                        end

                        39,40,41,42,43:
                        begin
                            main_debug_info <= {curr_bmp_width, 32'h98};
                            main_debug_info_en <= 1;
                            bmpheader_tmp[((readheader_cnt - 40) << 3) +: 8] <= bmp_cluster_doutb;
                            bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                        end

                        44:
                        begin
                            bmp_filepos <= curr_bmp_offset;
                            curr_bmp_x <= 0;
                            curr_bmp_y <= 0;
                            bmp_need_next_clus <= 0;
                            align_4bytes <= 0;
                            
                            readheader_cnt <= 0;
                            main_debug_info <= {curr_bmp_width[15:0], curr_bmp_height[15:0], curr_bmp_x[15:0], curr_bmp_y[15:0]};
                            main_debug_info_en <= 1;
                        end

                        default: begin
                            readheader_cnt <= 0;
                        end
                    endcase
                end

                S_READBMPHEADER:
                begin
                    if(curr_imgram_canwrite == 1)
                        main_state <= S_READBMPPALETTE;
                end

                S_READBMPPALETTE:
                begin
                    main_state <= S_READBMP_INIT;
                end

                S_READBMP_INIT:
                begin
                    whratio_p1 <= curr_bmp_width * VGA_H;
                    if(curr_bmp_height[31] == 0) begin
                        curr_bmp_height_abs <= curr_bmp_height;
                        whratio_p2 <= curr_bmp_height * VGA_W;
                    end else begin
                        curr_bmp_height_abs <= (~curr_bmp_height) + 1;
                        whratio_p2 <= ((~curr_bmp_height) + 1) * VGA_W;
                    end
                    align_4bytes <= ((~(curr_bmp_width * 3) + 1) & 3);
                    readbmp_juststart <= 1;
                    main_state <= S_READBMP;
                end

                S_READBMP_CONFIRM:
                if(BTNU) begin
                    main_state <= S_READBMP;
                end

                S_READBMP_UPDATE:
                begin  
                    if(readbmp_update_cnt >= 0 && readbmp_update_cnt < 7)
                        readbmp_update_cnt <= readbmp_update_cnt + 1;

                    case (readbmp_update_cnt)
                        //读该像素
                        0:
                        begin
                            // if(whratio_p1 >= whratio_p2) begin
                            //     curr_vga_x <= curr_bmp_x * VGA_W / curr_bmp_width;
                            //     if(curr_bmp_height[31] == 0)
                            //         curr_vga_y <= (VGA_H - VGA_W * curr_bmp_height_abs / curr_bmp_width) / 2 + (curr_bmp_height_abs - curr_bmp_y - 1) * VGA_W / curr_bmp_width;
                            //     else
                            //         curr_vga_y <= (VGA_H - VGA_W * curr_bmp_height_abs / curr_bmp_width) / 2 + curr_bmp_y * VGA_W / curr_bmp_width;
                            // end else begin
                            //     curr_vga_x <= (VGA_W - VGA_H * curr_bmp_width / curr_bmp_height_abs) / 2 + curr_bmp_x * VGA_H / curr_bmp_height_abs;
                            //     if(curr_bmp_height[31] == 0)
                            //         curr_vga_y <= (curr_bmp_height_abs - curr_bmp_y - 1) * VGA_H / curr_bmp_height_abs;
                            //     else
                            //         curr_vga_y <= curr_bmp_y * VGA_H / curr_bmp_height_abs;
                            // end

                            if(curr_bmp_height[31] == 0) begin
                                curr_vga_x <= curr_bmp_x;
                                curr_vga_y <= (curr_bmp_height_abs - curr_bmp_y - 1);
                            end else begin
                                curr_vga_x <= curr_bmp_x;
                                curr_vga_y <= curr_bmp_y;
                            end
                            
                        end

                        1:
                        begin
                            if(bmp_cluster_addrb == ((1 << clus_size_log2) - 1))
                            begin
                                //读到了簇尾
                                main_state <= S_GETNEXTBMPCLUSTER;
                                bmp_cluster_addrb <= 0;
                            end else begin
                                bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                            end
                            curr_b <= bmp_cluster_doutb;
                        end

                        2:
                        begin
                        ;
                        end

                        3:
                        begin
                            if(bmp_cluster_addrb == ((1 << clus_size_log2) - 1))
                            begin
                                //读到了簇尾
                                main_state <= S_GETNEXTBMPCLUSTER;
                                bmp_cluster_addrb <= 0;
                            end else begin
                                bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                            end
                            curr_g <= bmp_cluster_doutb;
                            ;
                        end

                        4:
                        begin
                        ;
                        end

                        5:
                        begin
                            if(bmp_cluster_addrb == ((1 << clus_size_log2) - 1))
                            begin
                                //读到了簇尾
                                main_state <= S_GETNEXTBMPCLUSTER;
                                bmp_cluster_addrb <= 0;
                            end else begin
                                bmp_cluster_addrb <= bmp_cluster_addrb + 1;
                            end
                            curr_r <= bmp_cluster_doutb;

                            if(curr_vga_x >= 0 && curr_vga_x < VGA_W && curr_vga_y >= 0 && curr_vga_y < VGA_H)
                                curr_vga_latch <= 1;    //只有在区域内的像素才会被刷新到显存
                            ;
                        end

                        6:
                        begin
                            main_debug_info <= {20'hAF0,curr_r[7:4],curr_g[7:4],curr_b[7:4], curr_vga_y[15:0], curr_vga_x[15:0]};
                            main_debug_info_en <= 1;
                        end

                        7:
                        begin
                            main_debug_info <= {curr_bmp_y[15:0], curr_bmp_x[15:0], curr_vga_y[15:0], curr_vga_x[15:0]};
                            main_debug_info_en <= 1;
                            main_state <= nextstate3;
                            curr_vga_latch <= 0;
                            readbmp_update_cnt <= 0;
                        end

                        default:
                            readbmp_update_cnt <= 0;
                    endcase
                end

                S_READBMP:
                begin
                    if(readbmp_juststart) begin
                        readbmp_juststart <= 0;
                        nextstate3 <= S_READBMP;
                    end else if(curr_bmp_x == (curr_bmp_width - 1)) begin
                        curr_bmp_x <= 0;
                        bmp_filepos <= bmp_filepos + align_4bytes + 3;
                        //main_debug_info <= {curr_bmp_height_abs[15:0] - 1, curr_bmp_y};
                        //main_debug_info_en <= 1;
                        if(curr_bmp_y == (curr_bmp_height_abs - 1)) begin
                            //读完了
                            curr_bmp_y <= 0;
                            // main_debug_info <= {8{8'hAA}};
                            // main_debug_info_en <= 1;
                            nextstate3 <= S_AFTERREADBMP;
                        end else begin
                            curr_bmp_y <= curr_bmp_y + 1;
                            nextstate3 <= S_READBMP;
                        end
                    end else begin
                        bmp_filepos <= bmp_filepos + 3;
                        curr_bmp_x <= curr_bmp_x + 1;
                        nextstate3 <= S_READBMP;
                    end

                    bmp_cluster_addrb <= (bmp_filepos[14:0] & ((1 << clus_size_log2) - 1));
                    readbmp_update_cnt <= 0;
                    main_state <= S_READBMP_UPDATE;
                end

                S_AFTERREADBMP:
                begin
                    curr_bmp_x <= 0;
                    curr_bmp_y <= 0;
                    curr_vga_clear <= 0;
                    curr_vga_latch <= 0;
                    curr_vga_finished <= 1;
                    autopage_cnt <= 0;
                    main_state <= S_WAITFORSWITCH;
                end

                S_WAITFORSWITCH:
                begin
                    if(autopage_cnt == T_AUTOPAGE - 1) begin
                        if(autopage) begin
                            main_state <= S_SCANROOT_INC;
                            just_backward <= 0;
                        end
                        autopage_cnt <= T_AUTOPAGE_BTNSHIELD;                        
                    end else begin
                        autopage_cnt <= autopage_cnt + 1;
                    end

                    if(BTNR_down == 3'b001) begin
                        //按键在图片加载出来的0.1s内暂时屏蔽
                        if(autopage_cnt >= T_AUTOPAGE_BTNSHIELD) begin
                            main_state <= S_SCANROOT_INC;
                            just_backward <= 0;
                        end
                    end
                    else
                    if(BTNL_down == 3'b001) begin
                        if(autopage_cnt >= T_AUTOPAGE_BTNSHIELD) begin
                            main_state <= S_SCANROOT_INC;
                            just_backward <= 1;
                        end
                    end
                end

                S_GETNEXTBMPCLUSTER:
                begin
                    query_fat_clus <= curr_bmp_clus;
                    clusternum_is_for_bmp <= 1;
                    nextstate <= S_AFTERGETTINGBMPCLUSTERNUM;
                    main_state <= S_GETROOTCLUSTERNUM_CONFIRM;
                    //main_state <= S_STABLE;
                end

                S_GETROOTCLUSTERNUM_CONFIRM:
                begin
                    //if(BTNR)begin
                        main_state <= S_GETROOTCLUSTERNUM;
                    //end
                end

                S_AFTERGETTINGBMPCLUSTERNUM:
                begin
                    clusternum_is_for_bmp <= 0;                    
                    curr_bmp_clus <= result_fat_nextclus;
                    en_read <= 1;
                    read_bytecnt <= 0;
                    read_seccnt <= 0;
                    sectorcnt_read <= (1 << BPB_SecPerClus_log2);
                    addr_read <= ((result_fat_nextclus - 2) << BPB_SecPerClus_log2) + firstclus_sec;
                    nextstate <= S_READBMP_UPDATE;
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
