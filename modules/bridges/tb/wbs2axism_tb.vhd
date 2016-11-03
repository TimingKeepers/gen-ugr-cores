-------------------------------------------------------------------------------
-- Title      : Testbench for the wb2axism IP core.
-- Project    : Misc
-------------------------------------------------------------------------------
-- File       : wb2axism_tb.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2016-04-13
-- Last update: 2016-04-13
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- It is the testbench for the wb2axism IP core.
--
-------------------------------------------------------------------------------
-- TODO:
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 UGR
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.wishbone_pkg.all;
use work.bridge_pkg.all;

entity wbs2axism_tb is
end wbs2axism_tb;

architecture struct of wbs2axism_tb is
	-- Constants
	constant C_CLK_PERIOD : time := 16 ns; -- 62.5 MHz
	constant C_ADDRESS_WIDTH : integer := 32;
	constant C_DATA_WIDTH : integer := 64;
	
	-- Clock & Reset (neg)
	signal clk   : std_logic;
	signal rst_n : std_logic;
    
    -- WB Slave (memory mapped) interface
	signal s_wb_cyc   : std_logic;
	signal s_wb_stb   : std_logic;
    
	signal s_wb_adr   : std_logic_vector(C_ADDRESS_WIDTH-1 downto 0);
	signal s_wb_dat   : std_logic_vector(C_DATA_WIDTH-1 downto 0);
	signal s_wb_sel   : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
	signal s_wb_we    : std_logic;
    
	signal s_wb_ack   : std_logic;
	signal s_wb_stall : std_logic;
	
	-- AXI Master (streaming) interface
	signal m_axis_tdata    : std_logic_vector(C_DATA_WIDTH-1 downto 0);
	signal m_axis_tkeep    : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
	signal m_axis_tlast    : std_logic;
	signal m_axis_tready   : std_logic;
	signal m_axis_tvalid   : std_logic;
	signal m_axis_tstrb    : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
	
begin   

	DUT: wbs2axism
		generic map(
			g_address_width => C_ADDRESS_WIDTH,
			g_data_width => C_DATA_WIDTH
		)
		port map(
			-- Clock & Reset (neg)
			clk_i   => clk,
			rst_n_i => rst_n,
		    
		    -- WB Slave (memory mapped) interface
			s_wb_cyc_i  => s_wb_cyc,
			s_wb_stb_i   => s_wb_stb,
		    
			s_wb_adr_i   => s_wb_adr,
			s_wb_dat_i   => s_wb_dat,
			s_wb_sel_i   => s_wb_sel,
			s_wb_we_i    => s_wb_we,
		    
			s_wb_ack_o   => s_wb_ack,
			s_wb_stall_o => s_wb_stall,
			
			-- AXI Master (streaming) interface
			m_axis_tdata_o   => m_axis_tdata,
			m_axis_tkeep_o   => m_axis_tkeep,
			m_axis_tlast_o   => m_axis_tlast,
			m_axis_tready_i  => m_axis_tready,
			m_axis_tvalid_o  => m_axis_tvalid,
			m_axis_tstrb_o   => m_axis_tstrb
		);
   
	clk_process :process
	begin
		clk <= '0';
		wait for C_CLK_PERIOD/2; 
		clk <= '1';
		wait for C_CLK_PERIOD/2;  
	end process;
   
   data_p : process(clk)
   	variable cnt : unsigned(C_DATA_WIDTH-1 downto 0) := (others => '0');
   begin
		if rising_edge(clk) then
			if rst_n = '0' then
				s_wb_dat <= (others => '0');
				cnt := (others => '0');
			else
			    if s_wb_stall = '0' and s_wb_ack = '1' then
				    cnt := cnt+1;
				    s_wb_dat <= std_logic_vector(cnt);
				end if;
			end if;
		end if;
   end process;
   
      -- Stimulus process
  stim_proc: process
   begin         
       rst_n <='0';
       wait for 20 ns;
       rst_n <='1';
       m_axis_tready <= '0';
       s_wb_cyc <= '1';
       wait for 1 ns;
       s_wb_adr <= (others => '0');
       s_wb_sel <= (others => '1');
       s_wb_we <= '1';
       s_wb_stb <= '1';
       wait for 3 ns;
       m_axis_tready <= '1';
       wait for 20 ns;
       s_wb_sel <= (others => '0');
       wait for 20 ns;
       s_wb_sel <= (others => '1');
       m_axis_tready <= '0';
       wait for 20 ns;
       m_axis_tready <= '1';
       wait for 300 ns;
       s_wb_cyc <= '0';
       s_wb_stb <= '0';
       wait;
  end process;
	
end struct;
