------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.0
--  \   \         Application : 
--  /   /         Filename : picxo_top_wrapper.vhd
-- /___/   /\     Authors: David Taylor, Vincent Vendramini 
-- \   \  /  \    Timestamp : v25_0 @ Fri Apr  8 11:26:58 +0100 2016 Rev: 815:817
--  \___\/\___\
--
-- 
-- 
-- 
-- (c) Copyright 2009-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.VComponents.all;
 
entity picxo_top_wrapper is
      Generic ( C_FAMILY     : string  := "KINTEX7";
                GT_TYPE      : string  := "GTX";
                MODE         : string  := "PICXO";
                CLOCK_REGION : string  := "X0Y0"
               );
      Port(--Global signals
            RESET_I           : in  STD_LOGIC                                 ;
            --Reference clock for locking the VCXO, can be any clock (local, BUFG, clock enable...)
            REF_CLK_I         : in  STD_LOGIC                                 ;
            --Clocks
            TXOUTCLK_I        : in  STD_LOGIC                                 ; 
            --DRP port to connect to GTX
            DRPEN_O           : out STD_LOGIC                                 ;
            DRPWEN_O          : out STD_LOGIC                                 ;
            DRPDO_I           : in  STD_LOGIC_VECTOR (15 downto 0)            ;
            DRPDATA_O         : out STD_LOGIC_VECTOR (15 downto 0)            ;
            DRPADDR_O         : out STD_LOGIC_VECTOR (8 downto 0)             ;
            DRPRDY_I          : in  STD_LOGIC                                 ;
            --phase detector clock enable,reserved
            RSIGCE_I          : in  STD_LOGIC                                 ;
            VSIGCE_I          : in  STD_LOGIC                                 ;
            VSIGCE_O          : out STD_LOGIC                                 ;
            --accumulator step
            ACC_STEP          : in  STD_LOGIC_VECTOR (3 downto 0)             ;
            --Coefficients and divider values
            G1                : in  STD_LOGIC_VECTOR (4 downto 0)             ;
            G2                : in  STD_LOGIC_VECTOR (4 downto 0)             ;
            R                 : in  STD_LOGIC_VECTOR (15 downto 0)            ;
            V                 : in  STD_LOGIC_VECTOR (15 downto 0)            ;
            CE_DSP_RATE       : in  std_logic_vector (15 downto 0)            ;
            --Coefficients for HSYNC
            C_I               : in  STD_LOGIC_VECTOR (6 downto 0)             ;
            P_I               : in  STD_LOGIC_VECTOR (9 downto 0)             ;
            N_I               : in  STD_LOGIC_VECTOR (9 downto 0)             ;
            --Offset, hold
            OFFSET_PPM        : in  STD_LOGIC_VECTOR (21 downto 0)            ;
            OFFSET_EN         : in  STD_LOGIC                                 ;
            HOLD              : in  STD_LOGIC                                 ;
            DON_I             : in  std_logic_vector (0  downto 0)            ;
             --DRP user port
            DRP_USER_REQ_I    : in  STD_LOGIC                                 ;
            DRP_USER_DONE_I   : in  STD_LOGIC                                 ; 
            DRPEN_USER_I      : in  STD_LOGIC                                 ;
            DRPWEN_USER_I     : in  STD_LOGIC                                 ;
            DRPADDR_USER_I    : in  STD_LOGIC_VECTOR (8  downto 0)            ;
            DRPDATA_USER_I    : in  STD_LOGIC_VECTOR (15 downto 0)            ;
            DRPDATA_USER_O    : out STD_LOGIC_VECTOR (15 downto 0)            ;
            DRPRDY_USER_O     : out STD_LOGIC                                 ;
            DRPBUSY_O         : out STD_LOGIC                                 ;
            --TXPI Port data
            ACC_DATA          : out STD_LOGIC_VECTOR (4  downto 0)            ;
            --SDM ports
            SDM_COARSE_I      : in  STD_LOGIC_VECTOR (5  downto 0)            ;
            SDM_DATA_O        : out STD_LOGIC_VECTOR (24 downto 0)            ;
            --Debug port
            ERROR_O           : out STD_LOGIC_VECTOR (20 downto 0)            ;
            VOLT_O            : out STD_LOGIC_VECTOR (21 downto 0)            ;
            DRPDATA_SHORT_O   : out STD_LOGIC_VECTOR (7  downto 0)            ;
            CE_PI_O           : out STD_LOGIC                                 ;
            CE_PI2_O          : out STD_LOGIC                                 ;
            CE_DSP_O          : out STD_LOGIC                                 ;
            OVF_PD            : out STD_LOGIC                                 ;                                          
            OVF_AB            : out STD_LOGIC                                 ;
            OVF_VOLT          : out STD_LOGIC                                 ;
            OVF_INT           : out STD_LOGIC                                  
            );
end picxo_top_wrapper;

architecture Behavioral of picxo_top_wrapper is

COMPONENT ctrl
   PORT(
      clk_bufg    : IN  std_logic                           ;
      drpen_i     : in  STD_LOGIC                           ;
      reset_i     : in  STD_LOGIC                           ;
      ce_dsp_rate : in std_logic_vector(15 downto 0)        ;
      ce_pi_o     : out STD_LOGIC                           ;
      ce_pi2_o    : OUT std_logic                           ;
      ce_dsp_o    : OUT std_logic :='0'
      );
END COMPONENT;

COMPONENT Acc_psincdec
     PORT (
       b    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       clk  : IN STD_LOGIC;
       add  : IN STD_LOGIC;
       ce   : IN STD_LOGIC;
       sclr : IN STD_LOGIC;
       q    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
     );
END COMPONENT;
   
COMPONENT drp_ctrl
    Generic (GT_TYPE : string   := "GTX" );
    Port (
        clk            : in  STD_LOGIC                        ;
        clk_nobufg     : in  STD_LOGIC                        ;
        drprdy_i       : in  STD_LOGIC                        ;
        drpdo_i        : in  STD_LOGIC_VECTOR (15 downto 0)   ;
        reset_i        : in  STD_LOGIC                        ;
        drpwen_o       : out STD_LOGIC                        ;
        drpen_o        : out STD_LOGIC                        ;
        drpaddr_o      : out STD_LOGIC_VECTOR (8 downto 0)    ;
        drpdata_i      : in  STD_LOGIC_VECTOR (15 downto 0)   ;
        drpdata_o      : out STD_LOGIC_VECTOR (15 downto 0)   ;
        drp_user_req_i : in  STD_LOGIC                        ;
        drpen_user_i   : in  STD_LOGIC                        ;
        drpwen_user_i  : in  STD_LOGIC                        ;
        drpaddr_user_i : in  STD_LOGIC_VECTOR (8 downto 0)    ;
        drpdata_user_i : in  STD_LOGIC_VECTOR (15 downto 0)   ;
        drprdy_user_o  : out STD_LOGIC                        ;
        drprdy_bufg_o  : out STD_LOGIC                        ;
        drpbusy_o      : out STD_LOGIC
    );
END COMPONENT;
   
   
   
COMPONENT picxo_top
    Port (      
        --reset signals
        reset_i           : in  STD_LOGIC                            ;
        --Reference clock for locking the VCXO, can be any clock (local, BUFG, clock enable...)
        ref_clk_i         : in  STD_LOGIC                            ;
        --controls        
        ce_pi2_i          : in  STD_LOGIC                            ; 
        ce_dsp_i          : in  STD_LOGIC                            ; 
        --Clocks
        txoutclk_i        : in  std_logic                            ; 
        --phase detector clock enable, for future use
        rsigce_i          : in  STD_LOGIC                            ;
        vsigce_i          : in  STD_LOGIC                            ;
        vsigce_o          : out STD_LOGIC                            ;
        --Coefficients and divider values
        G1                : in  STD_LOGIC_VECTOR (4 downto 0)        ;
        G2                : in  STD_LOGIC_VECTOR (4 downto 0)        ;
        R                 : in  STD_LOGIC_VECTOR (15 downto 0)       ;
        V                 : in  STD_LOGIC_VECTOR (15 downto 0)       ;
        --Offset, hold
        Offset_ppm        : in  std_logic_vector(21 downto 0)        ;
        Offset_en         : in  std_logic                            ;
        hold              : in  std_logic                            ;
        don_i             : in  std_logic_vector (0  downto 0)       ;
        --Coefficients reserved
        C_i               : in  STD_LOGIC_VECTOR (6 downto 0)        ;
        P_i               : in  STD_LOGIC_VECTOR (9 downto 0)        ;
        N_i               : in  STD_LOGIC_VECTOR (9 downto 0)        ;
        --outputs
        dac_data_o        : out std_logic                            ;
        dac_sign_o        : out std_logic                            ;
        --Debug port
        error_o           : out std_logic_vector(20 downto 0)        ;
        volt_o            : out std_logic_vector(21 downto 0)        ;
        ovf_pd            : out std_logic                            ;
        ovf_ab            : out std_logic                            ;
        ovf_volt          : out std_logic                            ;
        ovf_int           : out std_logic                            
    );
END COMPONENT;

    signal drprdy_bufg        : std_logic                    ;
    signal drprdy_bufg_gtx    : std_logic                    ;
    signal drprdy_bufg_gth    : std_logic := '0'             ;
    signal ce_pi2             : std_logic                    ;
    signal ce_pi              : std_logic                    ;
    signal ce_dsp             : std_logic                    ;
    signal dac_data           : std_logic                    ;
    signal dac_sign           : std_logic                    ;
    signal acc_in             : std_logic_vector(3  downto 0);
    signal drpdata_short      : std_logic_vector(7  downto 0);
    signal drpdata_acc        : std_logic_vector(15 downto 0);
    signal drp_ctrl_reset     : std_logic                    ; 
    signal drprdy_user        : std_logic                    ;  
    signal volt_unsigned      : std_logic_vector(21 downto 0);  
    signal volt               : std_logic_vector(21 downto 0);  
   
begin

----------   Controller (clock enable generation)   -------------------------------------------------------------------
Inst_ctrl: ctrl 
   PORT MAP(
      clk_bufg    => TXOUTCLK_I  ,
      drpen_i     => drprdy_bufg ,
      ce_pi2_o    => ce_pi2      ,
      reset_i     => RESET_I     ,
      ce_dsp_rate => ce_dsp_rate ,
      ce_dsp_o    => ce_dsp      ,
      ce_pi_o     => ce_pi            
   );

Inst_picxo_top: picxo_top  
     PORT MAP (
          ref_clk_i        => REF_CLK_I   ,
          reset_i          => RESET_I     , 
          ce_pi2_i         => ce_pi2      ,
          ce_dsp_i         => ce_dsp      ,
          txoutclk_i       => TXOUTCLK_I  ,
          rsigce_i         => RSIGCE_I    ,
          vsigce_i         => VSIGCE_I    ,
          vsigce_o         => VSIGCE_O    ,
          G1               => G1          ,
          G2               => G2          ,
          R                => R           ,
          V                => V           ,
          C_i              => C_i         ,
          P_i              => P_i         ,
          N_i              => N_i         ,
          Offset_ppm       => OFFSET_PPM  ,
          Offset_en        => OFFSET_EN   ,
          hold             => HOLD        ,
          don_i            => DON_I       ,
          dac_sign_o       => dac_sign    ,
          dac_data_o       => dac_data    ,
          --Debug port 
          error_o          => ERROR_O     ,
          volt_o           => volt        ,
          ovf_pd           => OVF_PD      ,  
          ovf_ab           => OVF_AB      ,
          ovf_volt         => OVF_VOLT    ,
          ovf_int          => OVF_INT
        ); 


acc_in   <=   acc_step when dac_data = '1' else "0000";
VOLT_O   <= volt;

----------   SDM/FRACXO --------------------------------------------------------------------------------------------------------

gen_fracxo: if MODE = "FRACXO" generate begin
                process (TXOUTCLK_I) begin
                   if rising_edge(TXOUTCLK_I) then
                        if volt(21) = '1' then
                            volt_unsigned <= '0' & volt (20 downto 0);
                        else
                            volt_unsigned <= '1' & volt (20 downto 0);
                        end if;
                   end if;
                end process;

                SDM_DATA_O (17 downto 0)  <=  volt_unsigned (21 downto 4);
                SDM_DATA_O (23 downto 18) <=  SDM_COARSE_I  (5  downto 0);
                SDM_DATA_O (24)           <=  '0';
end generate;
----------   Accumulator   -----------------------------------------------------------------------------------------------------   
gen_gth_gtp: if GT_TYPE = "GTH" or GT_TYPE ="GTP" or GT_TYPE ="GTY" generate begin
                        ACC_DATA          <= dac_sign & acc_in;
                        drprdy_bufg       <= drprdy_bufg_gth;
                        process (TXOUTCLK_I) begin 
                           if rising_edge(TXOUTCLK_I) then
                                drprdy_bufg_gth <= not drprdy_bufg_gth;
                           end if;
                        end process;
            end generate;
            
gen_no_gt : if GT_TYPE ="NO_GT" generate begin
                        ACC_DATA          <= dac_sign & acc_in;
                        drprdy_bufg       <= '1';
            end generate;


gen_V6_gtx:  if (GT_TYPE = "VIRTEX6") or (GT_TYPE = "GTX") generate begin
   Inst_acc : Acc_psincdec
   PORT MAP (
       b     => acc_in     ,
       clk   => TXOUTCLK_I ,
       add   => dac_sign   ,
       ce    => ce_pi      ,
       sclr  => RESET_I    ,
       q     => drpdata_short
   );
   
   gendrpdata_acc_v6 : if GT_TYPE = "VIRTEX6" generate
      begin
         drpdata_acc <=   drpdata_short(7 downto 0) & X"00";
      end generate;

   gendrpdata_acc_gtx : if GT_TYPE = "GTX" generate
      begin
         drpdata_acc <=   X"00" & '0' & drpdata_short(6 downto 0);
      end generate;   
   
   
-----------  DRP controller and arbiter--------------------------------------------------------------------------------   
   drp_ctrl_reset    <= RESET_I or DRP_USER_DONE_I;
   DRPDATA_USER_O <= drpdo_i;
   Inst_drp: drp_ctrl 
   GENERIC MAP (GT_TYPE => GT_TYPE)
   PORT MAP(
      clk             => TXOUTCLK_I     ,
      clk_nobufg      => '0'            ,
      drprdy_i        => drprdy_i       ,
      drpdo_i         => drpdo_i        ,
      reset_i         => drp_ctrl_reset ,
      drpwen_o        => DRPWEN_O       ,
      drpen_o         => DRPEN_O        ,
      drpaddr_o       => DRPADDR_O      ,
      drpdata_o       => DRPDATA_O      ,
      drp_user_req_i  => drp_user_req_i ,
      drpdata_i       => drpdata_acc    ,
      drpen_user_i    => DRPEN_USER_I   ,
      drpwen_user_i   => DRPWEN_USER_I  ,
      drpaddr_user_i  => DRPADDR_USER_I ,
      drpdata_user_i  => DRPDATA_USER_I ,
      drprdy_user_o   => drprdy_user    ,
      drprdy_bufg_o   => drprdy_bufg_gtx,
      drpbusy_o       => DRPBUSY_O      
   );
   drprdy_bufg       <= drprdy_bufg_gtx;

   drpdata_short_o   <= drpdata_short;
      
      
   gendrprdy_v6 : if GT_TYPE = "VIRTEX6" generate
      begin
            DRPRDY_USER_O     <= ce_pi  ;
      end generate;

   gendrprdy_gtx : if GT_TYPE = "GTX" generate
      begin
            DRPRDY_USER_O     <= drprdy_user  ;
      end generate;   
      
end generate;
  
   CE_PI_O           <= ce_pi  ;
   CE_PI2_O          <= ce_pi2  ;
   CE_DSP_O          <= ce_dsp ;

	
end Behavioral;











































