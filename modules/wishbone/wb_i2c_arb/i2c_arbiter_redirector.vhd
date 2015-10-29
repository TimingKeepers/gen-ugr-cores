-------------------------------------------------------------------------------
-- Title      : I2C Bus Arbiter Redirector
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : i2c_arbiter_redirector.vhd
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

entity i2c_arbiter_redirector is

generic (
	g_num_inputs : natural range 2 to 32 := 2;
    g_enable_oen : boolean := false
);
port (
	-- Clock & Reset
	clk_i : in std_logic;
	rst_n_i : in std_logic;
	enable_i : in std_logic;

	-- I2C input buses
	input_sda_i : in std_logic_vector(g_num_inputs-1 downto 0);
	input_sda_o : out std_logic_vector(g_num_inputs-1 downto 0);
	input_sda_oen : in std_logic_vector(g_num_inputs-1 downto 0);
	
	input_scl_i : in std_logic_vector(g_num_inputs-1 downto 0);
	input_scl_o : out std_logic_vector(g_num_inputs-1 downto 0);
	input_scl_oen : in std_logic_vector(g_num_inputs-1 downto 0);
	
	-- I2C output bus
	output_sda_i : in std_logic;
	output_sda_o : out std_logic;
	output_sda_oen : out std_logic;
	
	output_scl_i : in std_logic;
	output_scl_o : out std_logic;
	output_scl_oen : out std_logic;

	-- Redirector index & enable
	input_enabled_i : std_logic;
	input_idx_enabled_i : integer range 0 to g_num_inputs-1
);

end i2c_arbiter_redirector;

architecture struct of i2c_arbiter_redirector is
begin

gen_input_logic: for I in 0 to g_num_inputs-1 generate
    input_logic: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_n_i = '0' then
                    input_sda_o(I) <= '1';
                    input_scl_o(I) <= '1';
            else
                if enable_i = '1' and input_enabled_i = '1' then
                    if I /= input_idx_enabled_i then
                        input_sda_o(I) <= '1';
                        input_scl_o(I) <= '1';
                    else                   
                        input_sda_o(I) <= output_sda_i;
                        input_scl_o(I) <= output_scl_i;
                    end if;
                else
                    input_sda_o(I) <= '1';
                    input_scl_o(I) <= '1';
                end if;
            end if;
        end if;
    end process input_logic;
end generate gen_input_logic;

output_logic: process (clk_i)
begin
	if rising_edge(clk_i) then
		if rst_n_i = '0' then
		  output_sda_o <= '1';
          output_scl_o <= '1';
        else
            if enable_i = '1' and input_enabled_i = '1' then
                output_sda_o <= input_sda_i(input_idx_enabled_i);
                output_scl_o <= input_scl_i(input_idx_enabled_i);
            else
                output_sda_o <= '1';
                output_scl_o <= '1';
            end if;
        end if;
    end if;

end process output_logic;

gen_oen_signal: if g_enable_oen generate

	output_logic_en : process (clk_i)
	begin
		if rising_edge(clk_i) then

			if rst_n_i = '0' then
				output_sda_oen <= '0';
				output_scl_oen <= '0';
			else
				if enable_i = '1' and input_enabled_i = '1' then
                			output_sda_oen <= input_sda_oen(input_idx_enabled_i);
			                output_scl_oen <= input_scl_oen(input_idx_enabled_i);
            			else
			                output_sda_oen <= '0';
			                output_scl_oen <= '0';
			        end if;
			end if;

		end if;
	end process output_logic_en;
	
end generate gen_oen_signal;

not_gen_oen_signal : if not g_enable_oen generate
	output_sda_oen <= '0';
	output_scl_oen <= '0';
end generate not_gen_oen_signal;

-- Old tested version
--main: process(clk_i)
--begin
--	if rising_edge(clk_i) then
--		if rst_n_i = '0' then
--			for I in 0 to g_num_inputs-1 loop
--				input_sda_o(I) <= '1';
--				input_scl_o(I) <= '1';
--			end loop;
			
--			output_sda_o <= '1';
--			output_scl_o <= '1';
--		else
--		    if enable_i = '1' and input_enabled_i = '1' then

--			     for I in 0 to g_num_inputs-1 loop
--				    if I /= input_idx_enabled_i then
--					   input_sda_o(I) <= '1';
--					   input_scl_o(I) <= '1';
--				    else
--					   output_sda_o <= input_sda_i(I);
--					   output_scl_o <= input_scl_i(I);
									
--					   input_sda_o(I) <= output_sda_i;
--					   input_scl_o(I) <= output_scl_i;
--				    end if;
--			     end loop;
--			else
--			     for I in 0 to g_num_inputs-1 loop
--                    input_sda_o(I) <= '1';
--                    input_scl_o(I) <= '1';
--                 end loop;
                 
--                 output_sda_o <= '1';
--                 output_scl_o <= '1';
--			end if;
--		end if;
--	end if;
--end process main;

end struct;
