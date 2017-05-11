*************************************************************************
   ____  ____ 
  /   /\/   / 
 /___/  \  /   
 \   \   \/    © Copyright 2012–2016 Xilinx, Inc. All rights reserved.
  \   \        This file contains confidential and proprietary 
  /   /        information of Xilinx, Inc. and is protected under U.S. 
 /___/   /\    and international copyright and other intellectual 
 \   \  /  \   property laws. 
  \___\/\___\ 
 
*************************************************************************

Vendor: Xilinx 
Current readme.txt Version: 2.5
Date Last Modified:  01APR16
Date Created: 01JUL12

Associated Filename: vcxo.zip
Associated Document: xapp589-VCXO.pdf, xapp1241-VCXO.pdf, XAPP1276.pdf

Supported Device(s): 7 series FPGAs, Zynq AP SOC, Ultrascale and Ultrascale+. 
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

*************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. DESIGN FILE HIERARCHY
5. INSTALLATION AND OPERATING INSTRUCTIONS
6. OTHER INFORMATION (OPTIONAL)
7. SUPPORT

1. REVISION HISTORY 

            Readme  
Date        Version      Revision Description
=========================================================================
07/01/12     1.0          Initial Xilinx release.
09/01/12     2.0          Kintex-7 support added. Various enhancements.
09/01/12     2.1          Vivado support added. Virtex-7 GTX and GTH support added. Various enhancements.
07/01/14     2.2          All 7 series devices (GTH, GTX, GTP). Full Vivado flow with IP repository and example design.
03/01/15     2.3          Various fixes, see section 6 of this readme for details.
08/01/15     2.4          Ultrascale support for GTH (pre-production), GTY (beta, no HW tests). 
04/01/16     2.5          Ultrascale support for GTY (pre-production), Ultrascale+ support for GTH and GTY (beta). 
=========================================================================

2. OVERVIEW

This readme describes how to use the files that come with XAPP589, XAPP1241 and XAPP1276.
This application note delivers a system (PICXO/FRACXO) which can replace external VCXO (Voltage Controlled Xtal Oscillator) type circuits directly in Gigabit Transceiver (GT) applications. 
The design demonstrates integration and implementation of the PICXO/FRACXO into an example design targeting the KC705, ZC706, VC709, AC701, KCU105, VCU108, ZCU102 design platforms.


3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

* Windows 7 (64 bits) or Red Hat Enterprise Linux WS release 5(64bit)
* Vivado 2016.1 or later


4. DESIGN FILE HIERARCHY

The directory structure underneath the top-level folder is described below:
\PICXO_FRACXO
    component.xml: IP definition  
    |
    \doc
     |   This folder contains this readme.txt file and an Excel sheet to facilitate PICXO response calculation
    \example_design
        \Board_Name (AC701, KC705, ZC706, VC709, KCU105, VCU108, ZCU102)
            Contains XDC file targeting named boards
        \GT name (GTP, GTX, GTH, GTH_ultrascale, GTY, GTH_plus)
            Contains example design files targeting respective  GT Type.
    \gui
        Contains file used by custom IP
    \picxo
        Contains IP core encrypted files
    \synth
        Contains IP core wrapper and infrastructure
    \ttcl    
        Contains tcl file used to generate the example design
    \xgui
        Contains file used by custom IP
      

5. INSTALLATION AND OPERATING INSTRUCTIONS 

It is strongly recommended to be familiar with the example design. Recommendation on constraints, clocking, resets, GT connections and settings must be respected.
Please refer to XAPP589, XAPP1241 and XAPP1276 for operating instructions
1) Install Xilinx Vivado 2016.1 or later tools. 
2) Add the IP repository to your project: Tools-->Project Options, select IP on the left pan, click "Add Repository" and select PICXO_FRACXO folder
   In non project mode, the following commands can be used:
        >>set_property ip_repo_paths  <path to ip repository>/PICXO_FRACXO [current_fileset]
        >>update_ip_catalog
3) In the IP catalog, select PICXO_FRACXO, right click-->Customize IP
   In non project mode, the following command can be used:
        >>create_ip -name PICXO_FRACXO -vendor xilinx.com -library ip -module_name ip_name
4) Right Click-->Generate Example design


6. OTHER INFORMATION  

1) Limitations
    Please refer to XAPP589, XAPP1241, XAPP1276 for mandatory conditions and limitations.
    The example design is limited to devices matching AC701, KC705, ZC706, VC709, KCU105, VCU108, ZCU102. For other parts, the xdc pinout needs to be adapted.
    For Virtex-6 support, please refer to previous revision of the XAPP.
    For ISE support, please refer to previous revision of the XAPP.

2) Design Notes
    The files in this reference design are to be used with Vivado Synthesis.

3) Fixes, Improvements
    v2.2
    (1) Fixed Low pass filter arithmetic error in saturation.
    (2) Fixed secondary clocking scheme error in pre_opt_design.tcl (AR# 59089)
    (3) Fixed pre_opt_design.tcl to allow integration into IPI
    (4) Allow arbitrary placement when PICXO is not associated with a GT (Kintex7 325T and 410T support only).
    (5) Fixed reset "lock up" when R=0 or V=0

    v2.3
    (1) Added DRP and GT interfaces for easier integration into IPI
    (2) Added false paths on DON_I and cross clock domain of RESET_I in picxo.xdc
    (3) Added HW version register. Please see AR 63586 for details.
    (4) pre_opt.tcl: Cleaned Critical warnings. 
    (5) pre_opt.tcl: Fix small Artix-7. 
    (6) Split timing and placement constraints in example designs.
        
    v2.4
    (1) Enabled support for Ultrascale devices
    (2) Fix NO_GT mode "lock up"
    (3) Removed TXOUTCLKPCS_I input
    (4) Example design top level files generated in their respective folders.
     
    v2.5 
    (1) Enable support for Ultrascale+ devices
    (2) Fix error in pre_opt.tcl when REFCLK_I is driven by a LUT6
    (3) Fix CRITICAL WARNING regarding top level not found when generating example design
    (4) Add port selection in the GUI
    (5) "NO GT" support for Artix-7, Zynq, Kintex
    (6) KCU105 example design: Correct clock frequency and board pinout
    (7) Speed up runtime during pre_route.tcl
    (8) Adding FRACXO support
    
    
4) Known Issues
    (1) FRACXO design supports only 1 FRACXO per GT tile on some parts.
    (2) Consult Master Answer record 56136 for up to date list of issues 

7. SUPPORT

Master Answer record 56136.

To obtain technical support for this reference design, go to 
www.xilinx.com/support to locate answers to known issues in the Xilinx
Answers Database or to create a WebCase.  