//------------------------------------------------------------------------------
//  (c) Copyright 2013-2015 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------


`timescale 1ps/1ps

// =====================================================================================================================
// This example design checking module checks PRBS31 data at the appropriate parallel data width from the receiver,
// along with performing any data manipulation or sideband signaling necessary for the selected data decoding. This
// module instance checks data from a single transceiver channel for data reception demonstration purposes.
// =====================================================================================================================

module gtwizard_ultrascale_0_example_checking_raw (
  input  wire         gtwiz_reset_all_in,
  input  wire         gtwiz_userclk_rx_usrclk2_in,
  input  wire         gtwiz_userclk_rx_active_in,
  input  wire [31:0] rxdata_in,
  output reg          prbs_match_out = 1'b0
);


  // -------------------------------------------------------------------------------------------------------------------
  // Reset synchronizer
  // -------------------------------------------------------------------------------------------------------------------

  // Synchronize the example stimulus reset condition into the rxusrclk2 domain
  wire example_checking_reset_int = gtwiz_reset_all_in || ~gtwiz_userclk_rx_active_in;
  wire example_checking_reset_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_reset_synchronizer example_checking_reset_synchronizer_inst (
    .clk_in  (gtwiz_userclk_rx_usrclk2_in),
    .rst_in  (example_checking_reset_int),
    .rst_out (example_checking_reset_sync)
  );


  // -------------------------------------------------------------------------------------------------------------------
  // PRBS checker enable and sideband control generation
  // -------------------------------------------------------------------------------------------------------------------

  // For raw mode data reception, the PRBS checker is always enabled
  wire prbs_any_chk_en_int = 1'b1;


  // -------------------------------------------------------------------------------------------------------------------
  // PRBS checker block
  // -------------------------------------------------------------------------------------------------------------------

  // The prbs_any block, described in Xilinx Application Note 884 (XAPP884), "An Attribute-Programmable PRBS Generator
  // and Checker", generates or checks a parameterizable PRBS sequence. Instantiate and parameterize a prbs_any block
  // to check a PRBS31 sequence with parallel data sized to the receiver user data width.
  wire [31:0] prbs_any_chk_error_int;

  gtwizard_ultrascale_0_prbs_any # (
    .CHK_MODE    (1),
    .INV_PATTERN (1),
    .POLY_LENGHT (31),
    .POLY_TAP    (28),
    .NBITS       (32)
  ) prbs_any_chk_inst (
    .RST      (example_checking_reset_sync),
    .CLK      (gtwiz_userclk_rx_usrclk2_in),
    .DATA_IN  (rxdata_in),
    .EN       (prbs_any_chk_en_int),
    .DATA_OUT (prbs_any_chk_error_int)
  );

  // The prbs_any block indicates a match of the parallel PRBS data when all DATA_OUT bits are 0. Register the result
  // of the NOR function as the PRBS match indicator.
  always @(posedge gtwiz_userclk_rx_usrclk2_in) begin
    if (example_checking_reset_sync)
      prbs_match_out <= 1'b0;
    else
      prbs_match_out <= ~(|prbs_any_chk_error_int);
  end


endmodule
