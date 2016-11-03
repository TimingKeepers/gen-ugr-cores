-------------------------------------------------------------------------------
-- Title      : Bridge package
-- Project    : Misc
-------------------------------------------------------------------------------
-- File       : bridge_pkg.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2016-04-13
-- Last update: 2016-04-13
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- This package contains the bridge IP core developed.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;

package bridge_pkg is

	component wbs2axism
		generic (
			g_address_width : integer := 32;
			g_data_width : integer := 64
		);
		port (
			-- Clock & Reset (neg)
			clk_i   : in  std_logic;
			rst_n_i : in std_logic;
		    
		    -- WB Slave (memory mapped) interface
			s_wb_cyc_i   : in std_logic;
			s_wb_stb_i   : in std_logic;
		    
			s_wb_adr_i   : in std_logic_vector(g_address_width-1 downto 0);
			s_wb_dat_i   : in std_logic_vector(g_data_width-1 downto 0);
			s_wb_sel_i   : in std_logic_vector((g_data_width/8)-1 downto 0);
			s_wb_we_i    : in std_logic;
		    
			s_wb_ack_o   : out  std_logic;
			s_wb_stall_o : out  std_logic;
			
			-- AXI Master (streaming) interface
			m_axis_tdata_o    : out std_logic_vector(g_data_width-1 downto 0);
			m_axis_tkeep_o    : out std_logic_vector((g_data_width/8)-1 downto 0);
			m_axis_tlast_o    : out std_logic;
			m_axis_tready_i    : in std_logic;
			m_axis_tvalid_o    : out std_logic;
			m_axis_tstrb_o    : out std_logic_vector((g_data_width/8)-1 downto 0)
		);
	end component;
	
	component wb_axi_bridge is
	generic (

    G_DATA_WIDTH    : integer    := 32;
    G_ADDR_WIDTH    : integer    := 32;
    
    G_BURST_WIDTH    : integer     := 8
    
    );
    port (
    
    clk_i            : in std_logic;
    rst_n_i        : in std_logic;
        
    --Wishbone ports
    
    wb_cyc_i       : in std_logic;
    wb_stb_i       : in std_logic;
    wb_ack_o       : out std_logic;
    wb_stall_o       : out std_logic;
    wb_dat_i       : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
    wb_adr_i       : in std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    wb_we_i        : in std_logic;
    wb_sel_i       : in std_logic_vector(G_DATA_WIDTH/8-1 downto 0);
    
    adc_acq_count : in std_logic_vector(31 downto 0);
    acq_end_o     : out std_logic;
    
    -- Ports of Axi Master Bus Interface M00_AXI
    
    m00_axi_aclk   : in std_logic;   -- It's not used.
    m00_axi_aresetn    : in std_logic;
    m00_axi_awaddr    : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    m00_axi_awlen    : out std_logic_vector(7 downto 0);
    m00_axi_awsize  : out std_logic_vector(2 downto 0);
    m00_axi_awburst : out std_logic_vector(1 downto 0);
    m00_axi_awprot    : out std_logic_vector(2 downto 0);
    m00_axi_awvalid    : out std_logic;
    m00_axi_awready    : in std_logic;
    m00_axi_wdata    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m00_axi_wstrb    : out std_logic_vector(G_DATA_WIDTH/8-1 downto 0);
    m00_axi_wlast    : out std_logic;
    m00_axi_wvalid    : out std_logic;
    m00_axi_wready    : in std_logic;
    m00_axi_bresp    : in std_logic_vector(1 downto 0);
    m00_axi_bvalid    : in std_logic;
    m00_axi_bready    : out std_logic);
    
	end component;

end package;

package body bridge_pkg is

end package body;
