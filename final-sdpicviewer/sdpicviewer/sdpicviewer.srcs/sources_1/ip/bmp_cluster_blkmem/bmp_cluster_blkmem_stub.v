// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Wed Jun 13 16:30:24 2018
// Host        : SHUN-LAPTOP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Projects/digital-logic-design-assignments/FinalProject/sdpicviewer/sdpicviewer.srcs/sources_1/ip/bmp_cluster_blkmem/bmp_cluster_blkmem_stub.v
// Design      : bmp_cluster_blkmem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module bmp_cluster_blkmem(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[14:0],dina[7:0],clkb,addrb[14:0],doutb[7:0]" */;
  input clka;
  input [0:0]wea;
  input [14:0]addra;
  input [7:0]dina;
  input clkb;
  input [14:0]addrb;
  output [7:0]doutb;
endmodule
