-------------------------------------------------------------------------------
-- Title      : I2C Bus Arbiter
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : i2c_arbiter.vhd
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

library work;
use work.i2c_arb_pkg.all;

entity i2c_arbiter is

generic (
	g_num_inputs : natural range 2 to 32 := 2
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
	output_scl_o : out std_logic
);

end i2c_arbiter;

architecture struct of i2c_arbiter is

	-- Signals for the Start Condition Detectors
	signal start_cond_detect : std_logic_vector(g_num_inputs-1 downto 0);
	signal start_ack : std_logic_vector(g_num_inputs-1 downto 0);

	-- Signals for the Stop Condition Detectors
	signal stop_cond_detect : std_logic_vector(g_num_inputs-1 downto 0);
	signal stop_ack : std_logic_vector(g_num_inputs-1 downto 0);

	-- Signal for the Main process
	signal active_input : integer range g_num_inputs-1 downto -1 := -1;
    
	type arb_state is (ARB_IDLE, ARB_WAIT, ARB_BLOCKED, ARB_RELEASED);
	signal arb_st : arb_state := ARB_IDLE;

	-- PRIO Hotone Decoder
	function input_hotone_dec(inputs : std_logic_vector(g_num_inputs-1 downto 0)) return integer is
		variable active_i : integer range g_num_inputs-1 downto -1 := -1;
	begin
		active_i := -1;

		for I in g_num_inputs-1 downto 0 loop
			if inputs(I) = '1' then
				active_i := I;
			end if;
		end loop;

		return active_i;
	end input_hotone_dec;

	-- I2C Bus Configuration Logic
	procedure configure_i2c_bus
		(constant input_sda_i, input_scl_i : in std_logic_vector(g_num_inputs-1 downto 0);
		signal input_sda_o, input_scl_o : out std_logic_vector(g_num_inputs-1 downto 0);
		constant output_sda_i, output_scl_i : in std_logic;
		signal output_sda_o, output_scl_o : out std_logic;
		constant active_input: in integer range g_num_inputs-1 downto -1 := -1) is
	begin
		if active_input /= -1 then
			for I in 0 to g_num_inputs-1 loop
				if I /= active_input then
					input_sda_o(I) <= '1';
					input_scl_o(I) <= '1';
				else
					output_sda_o <= input_sda_i(I);
					output_scl_o <= input_scl_i(I);
									
					input_sda_o(I) <= output_sda_i;
					input_scl_o(I) <= output_scl_i;
				end if;

			end loop;
		else
			for I in 0 to g_num_inputs-1 loop
				input_sda_o(I) <= '1';
				input_scl_o(I) <= '1';
				output_sda_o <= '1';
				output_scl_o <= '1';
			end loop;
		end if;

	end configure_i2c_bus;

begin

    -- Start & Stop detectors
    ss_detectors : for I in 0 to g_num_inputs-1 generate
        ss: i2c_arbiter_ss_detector
        port map (
            clk_i => clk_i,
            rst_n_i => rst_n_i,
        
            input_sda_i => input_sda_i(I),
            input_scl_i => input_scl_i(I),
            
            start_ack_i => start_ack(I),
            stop_ack_i => stop_ack(I),
            
            start_state_o => start_cond_detect(I),
            stop_state_o => stop_cond_detect(I)
        );
    end generate ss_detectors;
   
	-- Main Arbiter process
	main : process(clk_i,rst_n_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				start_ack <= (others => '0');
				stop_ack <= (others => '0');

				configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);

				arb_st <= ARB_IDLE;
			else
				case arb_st is
					when ARB_IDLE =>
                       start_ack <= (others => '0');
                       stop_ack <= (others => '0');
                       
					   configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);
                       
					   active_input <= input_hotone_dec(start_cond_detect);
					   arb_st <= ARB_WAIT;
					  	
                    when ARB_WAIT =>
							if active_input /= -1 then
							    configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o,active_input);
								arb_st <= ARB_BLOCKED;
							else
							    configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);
								active_input <= input_hotone_dec(start_cond_detect);
							end if;
							
				    when ARB_BLOCKED =>
							configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o,active_input);
							
							if stop_cond_detect(active_input) = '1' then
								configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);
                                start_ack <= (others => '1');
								stop_ack <= (others => '1');
								arb_st <= ARB_RELEASED;
							end if;
							
				    when ARB_RELEASED =>
				            configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);
							arb_st <= ARB_IDLE;
					       
				    when others => 
				            configure_i2c_bus(input_sda_i,input_scl_i,input_sda_o,input_scl_o,output_sda_i,output_scl_i,output_sda_o,output_scl_o);
							arb_st <= ARB_IDLE;
				end case;
			end if;
		end if;
	end process main;

end struct;
