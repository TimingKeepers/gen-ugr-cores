-------------------------------------------------------------------------------
-- Title      : I2C Bus Arbiter Hotone Decoder
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : i2c_arbiter_hotone_dec.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2015-08-06
-- Last update: 2015-08-06
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

entity i2c_arbiter_hotone_dec is

generic (
	g_num_inputs : natural range 2 to 32 := 2
);
port (
	-- Clock & Reset
	clk_i : in std_logic;
	rst_n_i : in std_logic;
	enable_i : in std_logic;

	start_state_i : in std_logic_vector(g_num_inputs-1 downto 0);
	
	input_enabled_o : out std_logic;
	input_idx_enabled_o : out integer range 0 to g_num_inputs-1
);

end i2c_arbiter_hotone_dec;

architecture struct of i2c_arbiter_hotone_dec is
begin

main: process(clk_i)
	variable idx : integer := -1;
begin
	if rising_edge(clk_i) then
		if rst_n_i = '0' then
			input_enabled_o <= '0';
			input_idx_enabled_o <= 0;
		else
			if enable_i = '1' then
				idx := -1;

				for I in g_num_inputs-1 downto 0 loop
					if start_state_i(I) = '1' then
						idx := I;
					end if;
				end loop;

				if idx = -1 then
					input_enabled_o <= '0';
					input_idx_enabled_o <= 0;
				else
					input_enabled_o <= '1';
					input_idx_enabled_o <= idx;
				end if;
			end if;
		end if;
	end if;
end process main;

end struct;
