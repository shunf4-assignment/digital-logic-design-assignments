`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 19:28:20
// Design Name: 
// Module Name: test_top
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


module test_top(
        input CLK100MHZ,
        input BTNU,
//        input SW0,
//        input SW1,
//        input SW2,  //SW2:SW0 - page select for debuginfo
//        input SW3,  //SD START
//        input SW4,  //DEBUGINFO DATA LATCH
//        input SW5,  //FORCE SHOW MEMORY
//        input SW6,
//        input SW7,  //SW7SW6 : 0 - RX, 1 - TX, 2 - SDSTATE
        //SW15-SW8: THE VALUE OF {SW7SW6} SELECTED ITEM SHOULD NOT BE WHEN IT IS SW15:SW8
        input [15:0] SW,
        input BTNR,
        output [15:0] LED,
        output SD_SCK,
        output SD_CMD,
        input SD_DAT0,
        output SD_DAT3,
        output [7:0] AN,
        output [7:0] C
    );
    
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
    
    wire [7:0] sd_state;
    wire [4:0] spi_state;
    
    reg [7:0] data_rx_r;
    reg [7:0] data_tx_r;
    reg [7:0] sd_state_r;
    reg [4:0] spi_state_r;
    
    wire [63:0] debug_info;
    reg [63:0] debug_info_r;

    reg [255:0] data_rx_history;
    reg [255:0] data_tx_history;
    reg [255:0] sd_state_history;
    wire debug_info_en;
    
    //方便调试用，对SD控制器指标进行一些输出
    always @ (posedge CLK100MHZ) begin
        if(BTNU)begin
            data_rx_r <= 8'hAA;
            data_tx_r <= 8'hBB;
            sd_state_r <= 5'h00;
            spi_state_r <= 5'h00;
            debug_info_r <= {8{8'HDA}};
            data_rx_history <= {32{8'HDD}};
            data_tx_history <= {32{8'HDE}};
            sd_state_history <= {32{8'HDF}};
        end else
        if(SW[4]) begin
            //if(SW[7:6] != 0 || data_rx != SW[15:8])
                data_rx_r <= data_rx;
                
            //if(SW[7:6] != 1 || data_tx != SW[15:8])
            data_tx_r <= data_tx;
            
            //if(SW[7:6] != 2 || sd_state != SW[15:8])
            sd_state_r <= sd_state;
            spi_state_r <= spi_state;
            
            if(debug_info_en == 1'b1) begin
                debug_info_r <= debug_info;
            end

            if(data_rx != data_rx_history[7:0] && done_rx)begin
                data_rx_history[255:8] <= data_rx_history[247:0];
                data_rx_history[7:0] <= data_rx;
            end
            
            if(data_tx != data_tx_history[7:0] && en_tx)begin
                data_tx_history[255:8] <= data_tx_history[247:0];
                data_tx_history[7:0] <= data_tx;
            end
            
            if(sd_state != sd_state_history[7:0])begin
                sd_state_history[255:8] <= sd_state_history[247:0];
                sd_state_history[7:0] <= sd_state;
            end
            
        end
    end

    wire [4:0] debug_info_pageselect;
    assign debug_info_pageselect = SW[12:8];
    wire [7:0] history_info_pageselect;
    assign history_info_pageselect = SW[15:8];
    
    display_7seg disp7seg(
        CLK100MHZ,
        BTNU,
        1,
        SW[5] ? memory[history_info_pageselect * 2 + 1][7:4]: {3'b0, spi_state_r[4]},
        SW[5] ? memory[history_info_pageselect * 2 + 1][3:0]: spi_state_r[3:0],
        SW[5] ? memory[history_info_pageselect * 2 ][7:4]: sd_state_r[7:4],
        SW[5] ? memory[history_info_pageselect * 2 ][3:0]: sd_state_r[3:0],
        SW[1:0] == 0 ? debug_info_r[debug_info_pageselect * 8 + 4 +: 4]
            : SW[1:0] == 1 ? data_rx_history[history_info_pageselect * 8 + 4 +: 4]
            : SW[1:0] == 2 ? data_tx_history[history_info_pageselect * 8 + 4 +: 4]
            : sd_state_history[history_info_pageselect * 8 + 4 +: 4],
        SW[1:0] == 0 ? debug_info_r[debug_info_pageselect * 8 +: 4]
            : SW[1:0] == 1 ? data_rx_history[history_info_pageselect * 8 +: 4]
            : SW[1:0] == 2 ? data_tx_history[history_info_pageselect * 8 +: 4]
            : sd_state_history[history_info_pageselect * 8 +: 4],
        data_tx_r[7:4], data_tx_r[3:0],
        0,
        64'h0,
        AN,
        C
    );
    
    reg [5:0] read_state;
    reg en_read_r;
    reg [31:0] addr_read_r;
    wire done_read;
    wire [7:0] data_read;
    wire data_read_valid;
    reg done_read_r;

    reg [10:0] read_bytecnt;
    reg [7:0] memory [0:511];
    reg [10:0] memory_cnt;

    parameter S_READ_IDLE = 0;
    parameter S_READ_RESETMEM = 2;
    parameter S_READ_READING = 1;

    assign LED[13] = done_read_r;
    //控制SD卡进行“读”操作的控制器

    always @(posedge CLK100MHZ) begin
        if(BTNU)begin
            //复位
            read_state <= S_READ_IDLE;
            en_read_r <= 0;
            addr_read_r <= 0;
            read_bytecnt <= 0;
            done_read_r <= 0;
            memory_cnt <= 0;
            read_state <= S_READ_RESETMEM;
        end else begin
            if(read_state == S_READ_RESETMEM) begin
                memory_cnt <= memory_cnt + 1;
                memory[memory_cnt] = 0;
                if(memory_cnt == 'd511) begin
                    memory_cnt <= 0;
                    read_state <= S_READ_IDLE;
                end
            end else if(BTNR && read_state == S_READ_IDLE) begin
                read_state <= S_READ_READING;
                en_read_r <= 1'b1;
                addr_read_r <= (114514 << 9);
                read_bytecnt <= 0;
            end
            if(en_read_r == 1'b1)begin
                en_read_r <= 0;
            end
            if(read_state == S_READ_READING) begin
                if(data_read_valid)begin
                    memory[read_bytecnt] <= data_read;
                    read_bytecnt <= read_bytecnt + 1;
                    if(read_bytecnt == 'd511)begin
                        //读满了
                        read_state <= S_READ_IDLE;
                    end
                end
            end
            if(done_read == 1)
                done_read_r <= 1;
        end
    end

    sd_controller sdcon(
        .clk(CLK100MHZ),
        .rst(BTNU),
        .en_start(SW[3]),
        .done_start(LED[5]),
        .en_read(en_read_r),
        .addr_read(addr_read_r),
        .done_read(done_read),
        .data_read(data_read),
        .data_read_valid(data_read_valid),
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
        .cmd0_r_ok(LED[0]),
        .cmd1_r_ok(LED[14]),
        .cmd8_r_ok(LED[1]),
        .cmd55_r_ok(LED[2]),
        .acmd41_r_ok(LED[3]),
        .err(LED[15]),
        .sd_idle(LED[4]),
        .state(sd_state),
        .debug_info(debug_info),
        .debug_info_en(debug_info_en)
    );
    
    spi_controller spicon(
        .clk(CLK100MHZ),
        .rst(BTNU),
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
        .state(spi_state)
    );
    
endmodule
