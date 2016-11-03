-------------------------------------------------------------------------------
-- Title      : Wishbone slave -> AXI master (stream) bridge 
-- Project    : Misc
-------------------------------------------------------------------------------
-- File       : wb2axism.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2016-04-13
-- Last update: 2016-04-13
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- This component is designed to convert the Wishbone write transactions
-- to AXI stream ones.
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

entity wbs2axism is

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

end wbs2axism;

architecture struct of wbs2axism is
	type fsm_state is (IDLE, TX_WORD, TX_STALL);
	signal state : fsm_state := IDLE;
begin      
	
	-- Bridge FSM
	wbs2axim_fsm: process (clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				state <= IDLE;
			else
				case state is
					
					when IDLE =>
						if s_wb_cyc_i = '1' and s_wb_stb_i = '1' then
							state <= TX_WORD;
						end if;
						
					when TX_WORD =>
						if s_wb_cyc_i = '0' and s_wb_stb_i = '0' then
							state <= IDLE;
						end if;
						
						if m_axis_tready_i = '0' then
							state <= TX_STALL;
						end if;
						
					when TX_STALL =>
						if m_axis_tready_i = '1' then
							state <= TX_WORD;
						end if;
						
					when others =>
						state <= IDLE;
						
				end case;
			end if;
		end if;		
	end process wbs2axim_fsm;
	
	-- Data and tvalid
	wbs2axim_data: process (clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				m_axis_tdata_o <= (others => '0');
				m_axis_tvalid_o <= '0';
                m_axis_tkeep_o <= (others => '0');
                m_axis_tstrb_o <= (others => '0');
                
			else
				case state is
					
					when IDLE =>
						m_axis_tdata_o <= (others => '0');
						m_axis_tvalid_o <= '0';
                        m_axis_tkeep_o <= (others => '0');
                        m_axis_tstrb_o <= (others => '0');
						
					when TX_WORD =>
						if s_wb_cyc_i = '1' and s_wb_stb_i = '1' then
							m_axis_tdata_o <= s_wb_dat_i;
							m_axis_tkeep_o <= s_wb_sel_i;
						    m_axis_tstrb_o <= s_wb_sel_i;
							m_axis_tvalid_o <= '1';
						else
                            m_axis_tdata_o <= (others => '0');
							m_axis_tvalid_o <= '0';
							m_axis_tkeep_o <= (others => '0');
                            m_axis_tstrb_o <= (others => '0');
                                            
						end if;
						
					when others =>
						
				end case;
			end if;
		end if;		
	end process wbs2axim_data;
	
	-- Logic
	wbs2axim_logic: process(state, s_wb_cyc_i, s_wb_stb_i)
	begin
		
		case state is
			
			when TX_WORD =>
				if s_wb_cyc_i = '1' and s_wb_stb_i = '1' then
					s_wb_ack_o <= '1';
					s_wb_stall_o <= '0';
				else
					if s_wb_cyc_i = '0' and s_wb_stb_i = '0' then
						m_axis_tlast_o <= '1';
					end if;
				end if;
				
			when others =>
                s_wb_ack_o <= '0';
                s_wb_stall_o <= '1';
                m_axis_tlast_o <= '0';
				
		end case;
	end process wbs2axim_logic;
	
end struct;
