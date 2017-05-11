------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.0
--  \   \         Application : 
--  /   /         Filename : drp_ctrl.vhd
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
use ieee.numeric_std.all;

entity drp_ctrl is
    Generic(GT_TYPE      : string   := "GTX" );
    Port (clk            : in  STD_LOGIC                        ;
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

end drp_ctrl;

architecture Behavioral of drp_ctrl is
   COMPONENT fifo_dac2acc
    Port ( 
        wclk  : in  STD_LOGIC                        ;
        wce   : in  STD_LOGIC                        ;
        rclk  : in  STD_LOGIC                        ;
        rce   : in  STD_LOGIC                        ;
        rdata : out STD_LOGIC_VECTOR (26 downto 0)   ;
        wdata : in  STD_LOGIC_VECTOR (26 downto 0)   
        );
   END COMPONENT;

   signal drpwen        : std_logic :='0';
   signal drpaddr       : std_logic_vector (7 downto 0);
   signal drprdy        : std_logic :='0';
   signal drprdy_d      : std_logic :='0';
   signal drprdy_delay  : std_logic :='0';
   signal wdata         : std_logic_vector (26 downto 0);
   signal fifo_out      : std_logic_vector (26 downto 0);
   signal drp_req_nobuf : std_logic;
   signal drpen_user    : std_logic :='0';
   signal sel_drpen     : std_logic;
   
   signal drpen_cnt     : unsigned (1 downto 0) :="00";
   signal drpen         : std_logic;
   signal drpen_div2    : std_logic;
   
   signal rst_cnt       : unsigned(3 downto 0):= "0000";
   signal rst_tc        : std_logic :='0';
   signal rst_drpen     : std_logic :='0';

   signal drp_user_req  : std_logic :='0';
   signal drpbusy_cnt   : unsigned(3 downto 0):= "0000";
   signal drpbusy       : std_logic :='1';
   
   type state is (idle, a64_0, a64_1, a9_10, a9_11, a9_00, a9_01, user_w, user);
   signal c_state, n_state : state;

   signal wait_rdy : unsigned (2 downto 0):="111";
   
begin

gtx_gen: if GT_TYPE = "GTX" generate begin

    process (clk) begin
      if rising_edge (clk) then
           if reset_i ='1' and drp_user_req_i = '0' then
                c_state <= idle;
           else
                c_state <= n_state;
           end if;
      end if;
    end process;
      
    process (c_state, drp_user_req_i, drprdy_i, wait_rdy) begin
           case c_state is
                when idle  => if drp_user_req_i = '1' then 
                                    n_state <= user_w;
                              else  
                                    n_state <= a64_0 ;
                              end if;
                when a64_0 => n_state <= a64_1;
                when a64_1 => n_state <= a9_10;
                when a9_10 => n_state <= a9_11;
                when a9_11 => n_state <= a9_00;
                when a9_00 => n_state <= a9_01;
                when a9_01 => if drp_user_req_i ='1' then
                                n_state <= user_w;
                              else
                                n_state <= a64_0;
                              end if;
                when user_w =>  if wait_rdy = "000" then 
                                    n_state <= user;
                                 else 
                                    n_state <= user_w;
                                end if;
                when user   => if drp_user_req_i = '0' then 
                                  n_state <= a64_0;
                               else 
                                  n_state <= user; 
                               end if;
                when others => n_state <= idle;
            end case;
    end process;
    
    process (clk) begin    
      if rising_edge (clk) then
            if reset_i = '1' and drp_user_req_i = '0' then 
                  drpen_o       <= '0';
                  drpwen_o      <= '0';
                  drpaddr_o     <= '0' & x"64";
                  drpdata_o     <= drpdata_i;
                  drpbusy_o     <= '1';
                  drprdy_bufg_o <= '0';
                  drprdy_user_o <= '0';
                  wait_rdy      <= "110";
            else
            case c_state is
                when idle   => drpen_o       <= '0';
                               drpwen_o      <= '0';
                               drpaddr_o     <= '0' & x"64";
                               drpdata_o     <= drpdata_i;
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a64_0  => drpen_o       <= '0';
                               drpaddr_o     <= '0' & x"64";
                               drpdata_o     <= drpdata_i;
                               drpwen_o      <= '0';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a64_1  => drpen_o       <= '1';
                               drpaddr_o     <= '0' & x"64";
                               drpdata_o     <= drpdata_i;
                               drpwen_o      <= '1';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a9_10  => drpen_o       <= '0';
                               drpaddr_o     <= '0' & x"9F";
                               drpdata_o     <= x"0035";
                               drpwen_o      <= '0';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '1';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a9_11  => drpen_o       <= '1';
                               drpaddr_o     <= '0' & x"9F";
                               drpdata_o     <= x"0035";
                               drpwen_o      <= '1';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a9_00  => drpen_o       <= '0';
                               drpaddr_o     <= '0' & x"9F";
                               drpdata_o     <= x"0034";
                               drpwen_o      <= '0';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when a9_01  => drpen_o       <= '1';
                               drpaddr_o     <= '0' & x"9F";
                               drpdata_o     <= x"0034";
                               drpwen_o      <= '1';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
                when user_w => drpen_o       <= '0';
                               drpaddr_o     <= drpaddr_user_i;
                               drpdata_o     <= drpdata_user_i;
                               drpwen_o      <= '0';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= wait_rdy - 1;
                when user   => drpen_o       <= drpen_user_i;
                               drpaddr_o     <= drpaddr_user_i;
                               drpdata_o     <= drpdata_user_i;
                               drpwen_o      <= drpwen_user_i;
                               if drp_user_req_i = '1' then 
                                    drpbusy_o <= '0'; 
                               else 
                                    drpbusy_o <= '1';
                               end if;
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= drprdy_i;
                               wait_rdy      <= wait_rdy - 1;
                when others => drpen_o       <= '0';
                               drpaddr_o     <= '0' & x"64";
                               drpdata_o     <= x"0000";
                               drpwen_o      <= '0';
                               drpbusy_o     <= '1';
                               drprdy_bufg_o <= '0';
                               drprdy_user_o <= '0';
                               wait_rdy      <= "110";
            end case;
            end if;
      end if;
    end process;

end generate;     

V6_gen: if GT_TYPE = "VIRTEX6" generate begin    

    process (clk) begin
       if rising_edge (clk) then
          if drp_user_req_i = '0' then
             drpbusy_cnt <= (others=>'0');
          elsif drpbusy = '1' then
             drpbusy_cnt <= drpbusy_cnt + 1;
          end if;
       end if;
    end process;
    
    process (clk) begin 
       if rising_edge (clk) then
          if drp_user_req_i = '0' or rst_tc = '1' then
             drpbusy <= '1';
          elsif drpbusy_cnt = "1111" then
             drpbusy <= '0';
          end if;
       end if;
    end process;
       
    drpbusy_o <= drpbusy;   
    
-- Reset generation logic -- one pulse reset is enough to start it
  
    process (clk) begin 
       if rising_edge (clk) then
          if reset_i ='1' then
             rst_cnt <= "0000";
          elsif rst_tc = '1' then
             rst_cnt <= rst_cnt + 1;
          end if;
       end if;
    end process;
    
    process (clk) begin 
       if rising_edge (clk) then
          if rst_cnt = "1110" or rst_cnt = "1111" then
             rst_tc <= '0';
          else 
             rst_tc <= '1';
          end if;
       end if;
    end process;
    
    process (clk) begin 
       if rising_edge (clk) then
          if rst_cnt = "1101" then
             rst_drpen <= '1';
          else 
             rst_drpen <= '0';
          end if;
       end if;
    end process;
  
    
--Mux and FIFO
  
    process (rst_tc, rst_drpen, drp_user_req_i, drpen_user_i, drpaddr, drpaddr_user_i (7 downto 0), drpdata_i, drpdata_user_i, drpwen, drpwen_user_i) begin
       if drp_user_req_i ='1' then
          wdata <= '1' & drpen_user_i & drpwen_user_i & drpdata_user_i & drpaddr_user_i (7 downto 0); 
       else
          wdata <= rst_tc & rst_drpen & drpwen & drpdata_i(15 downto 0) & drpaddr;   
       end if;
    end process;
   

    Inst_fifo_dac2acc: fifo_dac2acc 
    PORT MAP(
       wclk  => clk          ,
       wce    => '1'         ,
       rclk  => clk_nobufg   ,
       rce    => '1'         ,
       wdata => wdata        ,
       rdata => fifo_out      
    );
    
    sel_drpen  <= fifo_out (26) ;   
    drpen_user <= fifo_out (25) ;   
    drpen_o <= drpen; 

                     
    process (sel_drpen, drpen_user, drprdy_i, fifo_out (24)) begin
       if    sel_drpen = '0'    then
          drpen    <= drprdy_i;
          drpwen_o <= drprdy_i;
       elsif sel_drpen = '1'    then
          drpen    <= drpen_user;
          drpwen_o <= fifo_out (24);
       end if;
    end process;
    drpwen     <= '1'   ;
                     

    -- transfer drprdy_i into txoutclk domain
    process (clk, drprdy_i) begin
       if drprdy_i = '1' then 
             drprdy_d <= '1';
       elsif rising_edge(clk) then
          if drprdy = '1' then
             drprdy_d<= '0';
          end if;
       end if;
    end process;
    
    process (clk) begin
       if rising_edge(clk) then
          if drprdy ='1' then
             drprdy<='0';
          else
             drprdy <= drprdy_d;
          end if;
       end if;
    end process;

    drpdata_o    <= fifo_out (23 downto 8)   ;
    drpaddr      <= x"37"   ;
    drpaddr_o    <= '0' & fifo_out (7 downto 0)   ;
    
    drprdy_bufg_o <= drprdy;
                     
end generate;
 
   
end architecture;































