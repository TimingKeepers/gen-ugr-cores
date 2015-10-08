-------------------------------------------------------------------------------
-- Title      : I2C Bus Arbiter
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : xwb_i2c_arbiter.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2015-09-06
-- Last update: 2015-09-06
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- This component allows to share a single I2C bus for many masters in a simple
-- way.
--
-------------------------------------------------------------------------------
-- TODO:
-------------------------------------------------------------------------------
--
-- Copyright (c) 2015 UGR
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
use work.i2c_arb_pkg.all;

entity xwb_i2c_arbiter is

generic (
	g_num_inputs : natural range 2 to 32 := 2;
	g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity : t_wishbone_address_granularity := WORD;
    g_enable_bypass_mode : boolean := true
);
port (
	-- Clock & Reset
	clk_i : in std_logic;
	rst_n_i : in std_logic;

	-- I2C input buses
	input_sda_i : in std_logic_vector(g_num_inputs-1 downto 0);
	input_sda_o : out std_logic_vector(g_num_inputs-1 downto 0);
	
	input_scl_i : in std_logic_vector(g_num_inputs-1 downto 0);
	input_scl_o : out std_logic_vector(g_num_inputs-1 downto 0);
	
	-- I2C output bus
	output_sda_i : in std_logic;
	output_sda_o : out std_logic;
	
	output_scl_i : in std_logic;
	output_scl_o : out std_logic;

	-- WB Slave bus
	slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out
);

end xwb_i2c_arbiter;

architecture struct of xwb_i2c_arbiter is
begin
	WB_I2C_ARB: wb_i2c_arbiter
	generic map(
		g_num_inputs => g_num_inputs,
		g_interface_mode => g_interface_mode,
		g_address_granularity => g_address_granularity,
		g_enable_bypass_mode => g_enable_bypass_mode
	)
	port map (
		clk_i => clk_i,
		rst_n_i => rst_n_i,

		input_sda_i => input_sda_i,
		input_sda_o => input_sda_o,
	
		input_scl_i => input_scl_i,
		input_scl_o => input_scl_o,
	
		output_sda_i => output_sda_i,
		output_sda_o => output_sda_o,
	
		output_scl_i => output_scl_i,
		output_scl_o => output_scl_o,

		wb_adr_i => slave_i.adr,
		wb_dat_i   => slave_i.dat,
      	wb_dat_o   => slave_o.dat,
		wb_cyc_i   => slave_i.cyc,
		wb_sel_i   => slave_i.sel,
      	wb_stb_i   => slave_i.stb,
      	wb_we_i    => slave_i.we,
	    wb_ack_o   => slave_o.ack,
      	wb_stall_o => slave_o.stall
	);
end struct;
