// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Wed Jun 13 16:33:13 2018
// Host        : SHUN-LAPTOP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Projects/digital-logic-design-assignments/FinalProject/sdpicviewer/sdpicviewer.srcs/sources_1/ip/vga_mem/vga_mem_stub.v
// Design      : vga_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module vga_mem(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[18:0],dina[13:0],clkb,addrb[18:0],doutb[13:0]" */;
  input clka;
  input [0:0]wea;
  input [18:0]addra;
  input [13:0]dina;
  input clkb;
  input [18:0]addrb;
  output [13:0]doutb;
endmodule
