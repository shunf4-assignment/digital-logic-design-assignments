`timescale 1ns /1ps
//���SD�������ĸ�������Ϣ����Ҫͨ��SW�����ƣ���Ҫͨ������������
module sd_controller_disp(
    input CLK100MHZ,
    input rst,      //Usu. BTNU
    input done_rx,
    input [7:0] data_rx,
    input en_tx,
    input done_tx,
    input [7:0] data_tx,
    input [7:0] sd_state,
    input [4:0] spi_state,
    input [7:0] main_state,
    //�ⲿ��·��������� history_info_pageselect ���ص� memory ��Ӧλ�õ�һ���֣�С����
    input [15:0] memory_word,
    input [63:0] debug_info,
    input debug_info_en,

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
    output [4:0] debug_info_pageselect,
    output [7:0] history_info_pageselect
);
    
    reg [7:0] data_rx_r;
    reg [7:0] data_tx_r;
    reg [7:0] sd_state_r;
    reg [4:0] spi_state_r;
    reg [7:0] main_state_r;

    reg [63:0] debug_info_r;

    localparam MAXPAGESLOG2 = 4;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] data_rx_history;   //�ɼ�¼1�ֽ�x256����ʷ״ֵ̬
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] data_tx_history;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] sd_state_history;
    reg [(1<<MAXPAGESLOG2) * 8 - 1:0] main_state_history;

    //��������ã���SD������ָ�����һЩ���
    always @ (posedge CLK100MHZ) begin
        if(rst)begin
            data_rx_r <= 8'hAA;     //data_rx_r, data_tx_r, sd_state_r ��������
            data_tx_r <= 8'hBB;
            sd_state_r <= 5'h00;
            spi_state_r <= 5'h00;
            debug_info_r <= {8{8'HDA}};
            data_rx_history <= {256{8'HDC}};
            data_tx_history <= {256{8'HDD}};
            sd_state_history <= {256{8'HDE}};
            main_state_history <= {256{8'HDF}};
        end else
        if(SW[4]) begin
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

            //data_rx_history �� ��¼�˸������/����/SD������״̬����ʷֵ
            //if(data_rx != data_rx_history[7:0] && done_rx)begin
            if((data_rx != 8'hff || data_rx != data_rx_history[7:0]) && done_rx)begin
                //RX��� && ��⵽ֵ�ı仯 -> ��λѹ��
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
            
        end
    end

    //pageselect����SW[11:8]��SW[10:8]�������Ƶġ�������ʾ�ڼ�����ʷ״̬��ҳ��wire��
    assign debug_info_pageselect = SW[10:8];
    assign history_info_pageselect = SW[8 +: (MAXPAGESLOG2)];

    //�������ʾ
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
        SW[5] ? memory_word[7:4]: main_state_r[7:4]
        ),
        .digit6(
        SW[5] ? memory_word[3:0]: main_state_r[3:0]
        ),
        .digit5(
        SW[5] ? memory_word[15:12]: sd_state_r[7:4]
        ),
        .digit4(
        SW[5] ? memory_word[11:8]: sd_state_r[3:0]
        ),
        .digit3(
        SW[2:0] == 0 ? debug_info_r[debug_info_pageselect * 8 + 4 +: 4]
            : SW[2:0] == 1 ? data_rx_history[history_info_pageselect * 8 + 4 +: 4]
            : SW[2:0] == 2 ? data_tx_history[history_info_pageselect * 8 + 4 +: 4]
            : SW[2:0] == 3 ? sd_state_history[history_info_pageselect * 8 + 4 +: 4]
            : main_state_history[history_info_pageselect * 8 + 4 +: 4]
        ),
        .digit2(
        SW[2:0] == 0 ? debug_info_r[debug_info_pageselect * 8 +: 4]
            : SW[2:0] == 1 ? data_rx_history[history_info_pageselect * 8 +: 4]
            : SW[2:0] == 2 ? data_tx_history[history_info_pageselect * 8 +: 4]
            : SW[2:0] == 3 ? sd_state_history[history_info_pageselect * 8 +: 4]
            : main_state_history[history_info_pageselect * 8 +: 4]
        ),
        .digit1(data_tx_r[7:4]), .digit0(data_tx_r[3:0]),
        .dot({1'b0, SW[5] ? 1'b0 : 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0}),
        .led_control({64{1'b0}}),
        .AN(AN),
        .C_wire(C)
    );

endmodule