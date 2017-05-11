------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 2.1
--  \   \         Application : 
--  /   /         Filename : fifo_dac2acc.vhd
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
library work;


entity fifo_dac2acc is
    Port ( wclk      : in  STD_LOGIC                  ;
           wce       : in  STD_LOGIC                  ;
           rclk      : in  STD_LOGIC                  ;
           rce       : in  STD_LOGIC                  ;
           rdata     : out STD_LOGIC_VECTOR (26 downto 0) := (others=>'0')   ;
           wdata     : in  STD_LOGIC_VECTOR (26 downto 0)   
          );

end fifo_dac2acc;

architecture Behavioral of fifo_dac2acc is

    signal waddr          : std_logic_vector (1 downto 0)  := (others=> '0');
    signal raddr          : std_logic_vector (1 downto 0)  := (others=> '0');
    signal raddr_tmp      : std_logic_vector (1 downto 0)  := (others=> '0'); 
    signal rxdata_tmp0    : std_logic_vector (26 downto 0) := (others=> '0');
    signal rxdata_tmp1    : std_logic_vector (26 downto 0) := (others=> '0');
    signal rxdata_tmp2    : std_logic_vector (26 downto 0) := (others=> '0');
    signal rxdata_tmp3    : std_logic_vector (26 downto 0) := (others=> '0');

 
begin

  resync: process (wclk)
  begin
    if(rising_edge (wclk)) then
       if wce ='1' then
         if(waddr = "00") then
           waddr <= "01";
           rxdata_tmp0 <= wdata;
         elsif(waddr = "01") then
           waddr <= "11";
           rxdata_tmp1 <= wdata;
         elsif(waddr = "11") then
           waddr <= "10";
           rxdata_tmp2 <= wdata;
         elsif(waddr = "10") then
           waddr <= "00";
           rxdata_tmp3 <= wdata;
         end if;
       end if;
    end if;
  end process;
  
  resync2 : process(rclk)
  begin
    if rising_edge (rclk) then
      if rce = '1' then
        raddr_tmp <= waddr;
        raddr <= raddr_tmp;
       end if;
    end if;
  end process;

  resync3 : process(rclk)
  begin
    if rising_edge (rclk) then
       if rce = '1' then
         if(raddr = "00") then
           rdata <= rxdata_tmp0;
         elsif(raddr = "01") then
           rdata <= rxdata_tmp1;
         elsif(raddr = "11") then
           rdata <= rxdata_tmp2;
         elsif(raddr = "10") then
           rdata <= rxdata_tmp3;
         end if;
       end if;
    end if;
  end process;

end architecture;































