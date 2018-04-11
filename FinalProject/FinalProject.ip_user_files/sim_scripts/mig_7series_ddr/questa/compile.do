vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm

vlog -work xil_defaultlib -64 -sv \
"D:/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 \
"D:/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/clocking/mig_7series_v4_0_clk_ibuf.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/clocking/mig_7series_v4_0_infrastructure.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/clocking/mig_7series_v4_0_iodelay_ctrl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/clocking/mig_7series_v4_0_tempmon.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_arb_mux.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_arb_row_col.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_arb_select.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_cntrl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_common.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_compare.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_mach.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_queue.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_bank_state.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_col_mach.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_mc.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_rank_cntrl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_rank_common.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_rank_mach.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/controller/mig_7series_v4_0_round_robin_arb.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_buf.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_dec_fix.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_gen.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_merge_enc.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ecc/mig_7series_v4_0_fi_xor.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ip_top/mig_7series_v4_0_memc_ui_top_std.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ip_top/mig_7series_v4_0_mem_intfc.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_group_io.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_lane.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_calib_top.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_if_post_fifo.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy_wrapper.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_of_pre_fifo.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_4lanes.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal_hr.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_init.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_cntlr.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_data.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_edge.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_lim.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_mux.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_po_cntlr.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_samp.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_oclkdelay_cal.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_prbs_rdlvl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_rdlvl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_tempmon.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_top.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrcal.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl_off_delay.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_prbs_gen.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_cc.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_edge_store.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_meta.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_pd.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_tap_base.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/phy/mig_7series_v4_0_poc_top.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ui/mig_7series_v4_0_ui_cmd.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ui/mig_7series_v4_0_ui_rd_data.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ui/mig_7series_v4_0_ui_top.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/ui/mig_7series_v4_0_ui_wr_data.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/mig_7series_ddr_mig_sim.v" \
"../../../../FinalProject.srcs/sources_1/ip/mig_7series_ddr/mig_7series_ddr/user_design/rtl/mig_7series_ddr.v" \

vlog -work xil_defaultlib "glbl.v"

