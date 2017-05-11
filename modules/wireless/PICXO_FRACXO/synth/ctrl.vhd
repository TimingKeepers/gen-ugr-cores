------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 2.1
--  \   \         Application : 
--  /   /         Filename : ctrl.vhd
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
use IEEE.NUMERIC_STD.ALL; 
   
   
entity ctrl is
   PORT(
        clk_bufg    : IN  std_logic;
        drpen_i     : in  STD_LOGIC;
        reset_i     : in  STD_LOGIC;
        ce_dsp_rate : in  std_logic_vector(15 downto 0);
        ce_pi_o     : out STD_LOGIC;
        ce_pi2_o    : out std_logic :='0';
        ce_dsp_o    : out std_logic :='0'
      );
END entity;
   
architecture Behavioral of ctrl is

   signal ce_pi       : std_logic :='0';
   signal ce_pi_bufg  : std_logic :='0';
   signal div_cnt_ce  : unsigned(15 downto 0):= X"0000";   
   signal ce_dsp_tc   : unsigned(15 downto 0);
   
begin
   
   process (clk_bufg) begin
      if rising_edge (clk_bufg) then
          if(reset_i = '1') then
            ce_pi <= '0';
          else
            ce_pi <= drpen_i;
          end if;
      end if;
   end process;
   
   ce_pi_o <= ce_pi;

    process (clk_bufg) begin
       if rising_edge (clk_bufg) then
          ce_pi_bufg <= ce_pi ;
       end if;
    end process;
---------------------------------------------------------------------------------------------------------
   process (clk_bufg) begin
      if rising_edge(clk_bufg) then
         if ce_pi_bufg = '1' then
            if div_cnt_ce = unsigned(ce_dsp_rate) then 
               div_cnt_ce <= (others =>'0');
            else
               div_cnt_ce <= div_cnt_ce + 1;
            end if;
         end if;
      end if;
   end process;

   ce_dsp_tc <= unsigned(ce_dsp_rate) - 1;


   process (clk_bufg) begin
      if rising_edge(clk_bufg) then
         if (div_cnt_ce = ce_dsp_tc and ce_pi_bufg = '1') or reset_i = '1' then 
            ce_dsp_o <= '1';
         else
            ce_dsp_o <= '0';
         end if;
      end if;
   end process;
   
   ce_pi2_o <= ce_pi_bufg;

end architecture;
   































