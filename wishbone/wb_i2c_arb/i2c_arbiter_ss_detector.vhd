-------------------------------------------------------------------------------
-- Title      : I2C Bus Arbiter Start/Stop detector
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : i2c_arbiter_ss_detector.vhd
-- Author     : Miguel Jimenez Lopez
-- Company    : UGR
-- Created    : 2015-09-06
-- Last update: 2015-09-06
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- This component allows to detect the START and STOP condition in a I2C bus.
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

entity i2c_arbiter_ss_detector is
port (
	-- Clock & Reset
	clk_i : in std_logic;
	rst_n_i : in std_logic;

	-- I2C input buses & ACK
	input_sda_i : in std_logic;
	input_scl_i : in std_logic;
	
	start_ack_i : in std_logic;
	stop_ack_i : in std_logic;
	
	-- Start/Stop outputs
	start_state_o : out std_logic;
	stop_state_o : out std_logic
);
end i2c_arbiter_ss_detector;

architecture struct of i2c_arbiter_ss_detector is
	-- Start FSM signals
	type i2c_arb_start_st is (ARB_START_IDLE, ARB_START_WAIT_SDA, ARB_START_DETECTED);
	signal arb_start_st : i2c_arb_start_st := ARB_START_IDLE;

	-- Stop FSM signals
	type i2c_arb_stop_st is (ARB_STOP_IDLE, ARB_STOP_WAIT_SDA, ARB_STOP_DETECTED);
	signal arb_stop_st : i2c_arb_stop_st := ARB_STOP_IDLE;
begin

	-- Start FSM
	start_detector: process(clk_i,rst_n_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				arb_start_st <= ARB_START_IDLE;
				start_state_o <= '0';
			else
				case arb_start_st is
					when ARB_START_IDLE =>
						start_state_o <= '0';
						if input_sda_i = '1' and input_scl_i = '1' then
							arb_start_st <= ARB_START_WAIT_SDA;
						end if;
					when ARB_START_WAIT_SDA =>
						if input_scl_i = '1' then
							if input_sda_i = '0' then
								start_state_o <= '1';
								arb_start_st <= ARB_START_DETECTED;
							end if;
						else
							start_state_o <= '0';
							arb_start_st <= ARB_START_IDLE;
						end if;
					when ARB_START_DETECTED =>
						if start_ack_i = '1' then
							start_state_o <= '0';
							arb_start_st <= ARB_START_IDLE;
						end if;
					when others =>
						start_state_o <= '0';
						arb_start_st <= ARB_START_IDLE;
				end case;
				
			end if;
		end if;
	end process start_detector;

	-- Stop FSM
	stop_detector: process(clk_i, rst_n_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				arb_stop_st <= ARB_STOP_IDLE;
				stop_state_o <= '0';
			else
				case arb_stop_st is
					when ARB_STOP_IDLE =>
						stop_state_o <= '0';
						if input_scl_i = '1' and input_sda_i = '0' then
							arb_stop_st <= ARB_STOP_WAIT_SDA;
						end if;
					when ARB_STOP_WAIT_SDA =>
						if input_scl_i = '1' then
							if input_sda_i = '1' then
								stop_state_o <= '1';
								arb_stop_st <= ARB_STOP_DETECTED;
							end if;
						else
							stop_state_o <= '0';
							arb_stop_st <= ARB_STOP_IDLE;
						end if;
					when ARB_STOP_DETECTED =>
						if stop_ack_i = '1' then
							stop_state_o <= '0';
							arb_stop_st <= ARB_STOP_IDLE;
						end if;
					when others =>
						stop_state_o <= '0';
						arb_stop_st <= ARB_STOP_IDLE;
				end case;
				
			end if;
		end if;
	end process stop_detector;

end struct;
