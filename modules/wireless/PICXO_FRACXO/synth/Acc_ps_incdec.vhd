------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 2.1
--  \   \         Application : 
--  /   /         Filename : Acc_ps_incdec.vhd
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
library UNISIM;
use UNISIM.VComponents.all;


ENTITY Acc_psincdec IS
  PORT (
    b     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    clk   : IN STD_LOGIC;
    add   : IN STD_LOGIC;
    ce    : IN STD_LOGIC;
    sclr  : IN STD_LOGIC;
    q     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END Acc_psincdec;


architecture Behavioral of Acc_psincdec is

   signal q_r :  signed (7 DOWNTO 0);

begin

process (clk) begin
   if rising_edge (clk) then
      if sclr = '1' then
         q_r <= (others =>'0');
      elsif ce = '1' then
         if add = '1' then
            q_r <= q_r + to_integer(unsigned(b));
         else
            q_r <= q_r - to_integer(unsigned(b));
         end if;
      end if;
   end if;
end process;

q <= std_logic_vector (q_r);

end architecture;































