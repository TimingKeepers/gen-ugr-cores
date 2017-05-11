#------------------------------------------------------------------------------
#  (c) Copyright 2013-2014 Xilinx, Inc. All rights reserved.
#
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES.
#------------------------------------------------------------------------------
# Timestamp : v25_0 @ Fri Apr  8 11:26:58 +0100 2016 Rev: 815:817

# UltraScale FPGAs Transceivers Wizard IP example design-level XDC file
# ----------------------------------------------------------------------------------------------------------------------

# Location constraints for differential reference clock buffers
# Note: the IP core-level XDC constrains the transceiver channel data pin locations
# ----------------------------------------------------------------------------------------------------------------------
set_property LOC GTHE3_CHANNEL_X0Y11 [get_cells -hierarchical -filter {NAME =~ *channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST}]

# SMA MGT REFCLK
set_property PACKAGE_PIN V6 [get_ports mgtrefclk0_x0y0_p]
#SMA Tx/Rx
set_property PACKAGE_PIN R4 [get_ports ch0_gthtxp_out]
set_property PACKAGE_PIN P2 [get_ports ch0_gthrxp_in]
# Si570 REFCLK
#set_property PACKAGE_PIN P6 [get_ports mgtrefclk0_x0y0_p]
# SFP0 Tx/Rx
#set_property PACKAGE_PIN U4 [get_ports ch0_gthtxp_out]
#set_property PACKAGE_PIN T2 [get_ports ch0_gthrxp_in]


set_property PACKAGE_PIN G10 [get_ports hb_gtwiz_reset_clk_freerun_in_p]
set_property IOSTANDARD LVDS [get_ports hb_gtwiz_reset_clk_freerun_in_p]

set_property PACKAGE_PIN AD10 [get_ports hb_gtwiz_reset_all_in]
set_property IOSTANDARD LVCMOS18 [get_ports hb_gtwiz_reset_all_in]

set_property PACKAGE_PIN AE10 [get_ports link_down_latched_reset_in]
set_property IOSTANDARD LVCMOS18 [get_ports link_down_latched_reset_in]

set_property PACKAGE_PIN AP8 [get_ports link_status_out]
set_property IOSTANDARD LVCMOS18 [get_ports link_status_out]
set_property PACKAGE_PIN H23 [get_ports link_down_latched_out]
set_property IOSTANDARD LVCMOS18 [get_ports link_down_latched_out]

set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
# Location constraints for other example design top-level ports
# Note: uncomment the following set_property constraints and replace "<>" with appropriate pin locations for your board
# ----------------------------------------------------------------------------------------------------------------------
#set_property package_pin <> [get_ports hb_gtwiz_reset_clk_freerun_in]
#set_property package_pin <> [get_ports hb_gtwiz_reset_all_in]
#set_property package_pin <> [get_ports prbs_error_latched_reset_in]
#set_property package_pin <> [get_ports prbs_match_all_out]
#set_property package_pin <> [get_ports prbs_error_latched_out]


















