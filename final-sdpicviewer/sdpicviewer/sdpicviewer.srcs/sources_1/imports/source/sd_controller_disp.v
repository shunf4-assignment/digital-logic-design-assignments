`timescale 1ns /1ps
//输出SD控制器的各调试信息，主要通过SW来控制，主要通过数码管来输出
module sd_controller_disp(
    input CLK100MHZ,
    input rst,      //Usu. BTNU
    input done_rx,
    input [7:0] data_rx,
    input en_tx,
    input done_tx,
    input resp_startvalid_long,
    input [10:0] resp_bytecnt,
    input [7:0] data_tx,
    input [7:0] sd_state,
    input [4:0] spi_state,
    input [7:0] main_state,
    //外部电路根据输出的 history_info_pageselect 加载的 memory 对应位置的一个字，小端序
    input [15:0] memory_word,
    input [63:0] debug_info,
    input debug_info_en,
    input [31:0] curr_bmp_fat_sec,
    input [31:0] curr_root_fat_sec,
    input [31:0] curr_root_clus,
    input [31:0] curr_bmp_clus,
    input latch_n,
    input [31:0] img_cnt,

    input [15:0] SW,
    //SW2:SW0 - 0->View Debuginfo, 1->View RXHistory, 2->View TXHistory, 3->View SDStateHistory
    //          4->View MainStateHistory
    //SW3: SD START
    //SW4: ALL INFO'S LATCH
    //SW5: 1 - SHOW MEMORY AT AN[7:4], ADDR - SW15:SW8 (DEPTH: 1 WORD)
    //     0 - SHOW SPISTATE, SDSTATE AT AN[7:4]
    //SW6 - SW7: X
    //SW12:SW8 : PAGESELECTOR FOR DEBUGINFO
    //SW15:SW8 : PAGESELECTOR/ADDR FOR HISTORIES/MEMORY

    output [7:0] AN,
    output [7:0] C,
    //output [4:0] debug_info_pageselect,
    output [7:0] history_info_pageselect
);
    
    reg [7:0] data_rx_r;
    reg [7:0] data_tx_r;
    reg [7:0] sd_state_r;
    reg [4:0] spi_state_r;
    reg [7:0] main_state_r;

    reg [63:0] debug_info_r;

    localparam MAXPAGESLOG2 = 6;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] data_rx_history;   //可记录1字节x256个历史状态值
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] data_tx_history;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] sd_state_history;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] main_state_history;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] debug_info_history;

    //方便调试用，对SD控制器指标进行一些输出
    always @ (posedge CLK100MHZ) begin
        if(rst)begin
            data_rx_r <= 8'hAA;     //data_rx_r, data_tx_r, sd_state_r 考虑弃用
            data_tx_r <= 8'hBB;
            sd_state_r <= 5'h00;
            spi_state_r <= 5'h00;
            debug_info_r <= {8{8'HDA}};
            data_rx_history <= {((1<<MAXPAGESLOG2) * 8){8'HDC}};
            data_tx_history <= {((1<<MAXPAGESLOG2) * 8){8'HDD}};
            sd_state_history <= {((1<<MAXPAGESLOG2) * 8){8'HDE}};
            main_state_history <= {((1<<MAXPAGESLOG2) * 8){8'HDF}};
            debug_info_history <= {((1<<MAXPAGESLOG2) * 8){8'HDB}};
        end else
        //if(SW[4]) begin
        if(~latch_n) begin
            //if(SW[7:6] != 0 || data_rx != SW[15:8])
            data_rx_r <= data_rx;
                
            //if(SW[7:6] != 1 || data_tx != SW[15:8])
            data_tx_r <= data_tx;
            
            //if(SW[7:6] != 2 || sd_state != SW[15:8])
            sd_state_r <= sd_state;
            spi_state_r <= spi_state;
            main_state_r <= main_state;
            
            if(debug_info_en == 1'b1) begin
                debug_info_r <= debug_info;
            end

            //data_rx_history 等 记录了各个输出/输入/SD控制器状态的历史值
            //if(data_rx != data_rx_history[7:0] && done_rx)begin
            if(((data_rx != 8'hff || data_rx != data_rx_history[7:0]) && done_rx) && (resp_startvalid_long == 0 || resp_bytecnt >= 508))begin
                //RX完成 && 检测到值的变化 -> 移位压入
                data_rx_history[(1<<MAXPAGESLOG2) * 8 - 1:8] <= data_rx_history[(1<<MAXPAGESLOG2) * 8 - 1 - 8:0];
                data_rx_history[7:0] <= data_rx;
            end
            
            //if(data_tx != data_tx_history[7:0] && en_tx)begin
            if(done_tx)begin
                data_tx_history[(1<<MAXPAGESLOG2) * 8 - 1:8] <= data_tx_history[(1<<MAXPAGESLOG2) * 8 - 1 - 8:0];
                data_tx_history[7:0] <= data_tx;
            end
            
            if(sd_state != sd_state_history[7:0])begin
                sd_state_history[(1<<MAXPAGESLOG2) * 8 - 1:8] <= sd_state_history[(1<<MAXPAGESLOG2) * 8 - 1 - 8:0];
                sd_state_history[7:0] <= sd_state;
            end

            if(main_state != main_state_history[7:0]) begin
                main_state_history[(1<<MAXPAGESLOG2) * 8 - 1:8] <= main_state_history[(1<<MAXPAGESLOG2) * 8 - 1 - 8:0];
                main_state_history[7:0] <= main_state;
            end

            if(debug_info_en) begin
                debug_info_history[(1<<MAXPAGESLOG2) * 8 - 1:64] <= debug_info_history[(1<<MAXPAGESLOG2) * 8 - 1 - 64:0];
                debug_info_history[63:0] <= debug_info;
            end
            
        end
    end

    //pageselect：即SW[11:8]或SW[10:8]用来控制的、决定显示第几个历史状态的页码wire。
    assign debug_info_pageselect = SW[10:8];
    // assign history_info_pageselect = SW[8 +: (MAXPAGESLOG2)];
    assign history_info_pageselect = SW[15:8];

    //数码管显示
    display_7seg disp7seg(
        .clk_100MHz(CLK100MHZ),
        .rst(rst),
        .digit_ena(1'b1),
        // .digit7(
        // SW[5] ? memory[history_info_pageselect * 2 + 1][7:4]: {3'b0, spi_state_r[4]}
        // ),
        // .digit6(
        // SW[5] ? memory[history_info_pageselect * 2 + 1][3:0]: spi_state_r[3:0]
        // ),
        // .digit5(
        // SW[5] ? memory[history_info_pageselect * 2 ][7:4]: sd_state_r[7:4]
        // ),
        // .digit4(
        // SW[5] ? memory[history_info_pageselect * 2 ][3:0]: sd_state_r[3:0]
        // ),
        .digit7(
        SW[3] ? (
        SW[6:4] == 0 ? main_state_r[7:4]
            : SW[6:4] == 1 ? memory_word[7:4]
            : SW[6:4] == 2 ? memory_word[7:4]
            : SW[6:4] == 3 ? curr_root_fat_sec[31:28]
            : SW[6:4] == 4 ? curr_root_clus[31:28]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[31:28]
            : curr_bmp_clus[31:28]
        ) : img_cnt / 10000000
        ),
        .digit6(
        //SW[6:4] ? memory_word[3:0]: main_state_r[3:0]
        SW[3] ? (
        SW[6:4] == 0 ? main_state_r[3:0]
            : SW[6:4] == 1 ? memory_word[3:0]
            : SW[6:4] == 2 ? memory_word[3:0]
            : SW[6:4] == 3 ? curr_root_fat_sec[27:24]
            : SW[6:4] == 4 ? curr_root_clus[27:24]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[27:24]
            : curr_bmp_clus[27:24]
        ) : (img_cnt % 10000000) / 1000000
        ),
        .digit5(
        //SW[6:4] ? memory_word[15:12]: sd_state_r[7:4]
        SW[3] ? (
        SW[6:4] == 0 ? sd_state_r[7:4]
            : SW[6:4] == 1 ? memory_word[15:12]
            : SW[6:4] == 2 ? memory_word[15:12]
            : SW[6:4] == 3 ? curr_root_fat_sec[23:20]
            : SW[6:4] == 4 ? curr_root_clus[23:20]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[23:20]
            : curr_bmp_clus[23:20]
        ) : (img_cnt % 1000000) / 100000
        ),
        .digit4(
        //SW[6:5] ? memory_word[11:8]: sd_state_r[3:0]
        SW[3] ? (
        SW[6:4] == 0 ? sd_state_r[3:0]
            : SW[6:4] == 1 ? memory_word[11:8]
            : SW[6:4] == 2 ? memory_word[11:8]
            : SW[6:4] == 3 ? curr_root_fat_sec[19:16]
            : SW[6:4] == 4 ? curr_root_clus[19:16]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[19:16]
            : curr_bmp_clus[19:16]
        ) : (img_cnt % 100000) / 10000
        ),
        .digit3(
        SW[3] ? (
        (SW[6:4] >= 3) ? (
            SW[6:4] == 3 ? curr_root_fat_sec[15:12]
            : SW[6:4] == 4 ? curr_root_clus[15:12]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[15:12]
            : curr_bmp_clus[15:12]
        )
        : SW[2:0] == 0 ? debug_info_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 + 4 +: 4]
            : SW[2:0] == 1 ? data_rx_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 + 4 +: 4]
            : SW[2:0] == 2 ? data_tx_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 + 4 +: 4]
            : SW[2:0] == 3 ? sd_state_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 + 4 +: 4]
            : main_state_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 + 4 +: 4]
        ) : (img_cnt % 10000) / 1000
        ),
        .digit2(
        SW[3] ? (
        (SW[6:4] >= 3) ? (
            SW[6:4] == 3 ? curr_root_fat_sec[11:8]
            : SW[6:4] == 4 ? curr_root_clus[11:8]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[11:8]
            : curr_bmp_clus[11:8]
        )
        : SW[2:0] == 0 ? debug_info_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 +: 4]
            : SW[2:0] == 1 ? data_rx_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 +: 4]
            : SW[2:0] == 2 ? data_tx_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 +: 4]
            : SW[2:0] == 3 ? sd_state_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 +: 4]
            : main_state_history[history_info_pageselect[0 +: (MAXPAGESLOG2)] * 8 +: 4]
        ) : (img_cnt % 1000) / 100
        ),
        .digit1(
        SW[3] ? (
        (SW[6:4] >= 3) ? (
            SW[6:4] == 3 ? curr_root_fat_sec[7:4]
            : SW[6:4] == 4 ? curr_root_clus[7:4]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[7:4]
            : curr_bmp_clus[7:4]
        )
        : data_tx_r[7:4]
        ) : (img_cnt % 100) / 10
        ),
        .digit0(
        SW[3] ? (
        (SW[6:4] >= 3) ? (
            SW[6:4] == 3 ? curr_root_fat_sec[3:0]
            : SW[6:4] == 4 ? curr_root_clus[3:0]
            : SW[6:4] == 5 ? curr_bmp_fat_sec[3:0]
            : curr_bmp_clus[3:0]
        )
        : data_tx_r[3:0]
        ) : (img_cnt % 10)
        ),
        .dot(SW[3] ? ({1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0}) : 8'b00000000),
        .led_control({64{1'b0}}),
        .AN(AN),
        .C_wire(C)
    );

endmodule