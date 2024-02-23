// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Thu Feb 15 17:53:29 2024
// Host        : LAPTOP-H1858A6E running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/three_verilog/fpga_IP_define/DMA_Loop/prj/DMA_Loop/hdl/src/AXI_ILA/AXI_ILA_stub.v
// Design      : AXI_ILA
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2022.2" *)
module AXI_ILA(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, probe14, probe15, probe16, probe17, 
  probe18, probe19, probe20)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[7:0],probe1[0:0],probe2[23:0],probe3[0:0],probe4[15:0],probe5[0:0],probe6[0:0],probe7[7:0],probe8[31:0],probe9[0:0],probe10[0:0],probe11[0:0],probe12[0:0],probe13[31:0],probe14[24:0],probe15[24:0],probe16[0:0],probe17[23:0],probe18[7:0],probe19[11:0],probe20[11:0]" */;
  input clk;
  input [7:0]probe0;
  input [0:0]probe1;
  input [23:0]probe2;
  input [0:0]probe3;
  input [15:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [7:0]probe7;
  input [31:0]probe8;
  input [0:0]probe9;
  input [0:0]probe10;
  input [0:0]probe11;
  input [0:0]probe12;
  input [31:0]probe13;
  input [24:0]probe14;
  input [24:0]probe15;
  input [0:0]probe16;
  input [23:0]probe17;
  input [7:0]probe18;
  input [11:0]probe19;
  input [11:0]probe20;
endmodule
