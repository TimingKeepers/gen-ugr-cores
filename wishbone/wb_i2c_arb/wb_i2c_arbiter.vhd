-------------------------------------------------------------------------------
-- Title      : WB I2C Bus Arbiter
-- Project    : White Rabbit Project
-------------------------------------------------------------------------------
-- File       : wb_i2c_arbiter.vhd
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
use work.i2c_arb_wbgen2_pkg.all;
use work.i2c_arb_pkg.all;
use work.wishbone_pkg.all;

entity wb_i2c_arbiter is

generic (
	g_num_inputs : natural range 2 to 32 := 2;
	g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity : t_wishbone_address_granularity := WORD;
    g_enable_bypass_mode : boolean := true;
    g_enable_oen : boolean := false
);
port (
	-- Clock & Reset
	clk_i : in std_logic;
	rst_n_i : in std_logic;

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

	-- WB Slave bus
	wb_adr_i   				 : in  std_logic_vector(31 downto 0);
	wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic
);

end wb_i2c_arbiter;

architecture struct of wb_i2c_arbiter is

	-- WB signals
	signal wb_in  : t_wishbone_slave_in;
  	signal wb_out : t_wishbone_slave_out;
    signal regs_out : t_i2c_arb_out_registers := c_i2c_arb_out_registers_init_value;

	-- Signals for the Start Condition Detectors
	signal start_cond_detect : std_logic_vector(g_num_inputs-1 downto 0);
	--signal start_acks : std_logic_vector(g_num_inputs-1 downto 0);
	signal start_ack : std_logic;

	-- Signals for the Stop Condition Detectors
	signal stop_cond_detect : std_logic_vector(g_num_inputs-1 downto 0);
	--signal stop_acks : std_logic_vector(g_num_inputs-1 downto 0);
	signal stop_ack : std_logic;

	-- Signal for the Main process
	signal active_input : integer range g_num_inputs-1 downto 0 := 0;
	signal active_input_hotone : integer range g_num_inputs-1 downto 0 := 0;
    
	type arb_state is (ARB_IDLE, ARB_WAIT, ARB_BLOCKED, ARB_RELEASED, ARB_BYPASS);
	signal arb_st : arb_state := ARB_IDLE;

	signal hotone_enable_input : std_logic;
	signal redirector_enable_input : std_logic;
	
	-- Debug stuff
	
--	attribute MARK_DEBUG : string;
    
--    attribute MARK_DEBUG of wb_in : signal is "TRUE";
--    attribute MARK_DEBUG of wb_out : signal is "TRUE";
--    attribute MARK_DEBUG of regs_out : signal is "TRUE";
--    attribute MARK_DEBUG of start_cond_detect : signal is "TRUE";
--    attribute MARK_DEBUG of start_ack : signal is "TRUE";
--    attribute MARK_DEBUG of stop_cond_detect : signal is "TRUE";
--    attribute MARK_DEBUG of stop_ack : signal is "TRUE";
--    attribute MARK_DEBUG of active_input : signal is "TRUE";
--    attribute MARK_DEBUG of active_input_hotone : signal is "TRUE";
--    attribute MARK_DEBUG of arb_st : signal is "TRUE";
--    attribute MARK_DEBUG of hotone_enable_input : signal is "TRUE";
--    attribute MARK_DEBUG of redirector_enable_input : signal is "TRUE";        
       
begin

   -- WB Adapter & Regs
   U_Adapter : wb_slave_adapter
    generic map (
      g_master_use_struct  => true,
      g_master_mode        => CLASSIC,
      g_master_granularity => WORD,
      g_slave_use_struct   => false,
      g_slave_mode         => g_interface_mode,
      g_slave_granularity  => g_address_granularity)
    port map (
      clk_sys_i  => clk_i,
      rst_n_i    => rst_n_i,
      master_i   => wb_out,
      master_o   => wb_in,
      sl_adr_i   => wb_adr_i,
      sl_dat_i   => wb_dat_i,
      sl_sel_i   => wb_sel_i,
      sl_cyc_i   => wb_cyc_i,
      sl_stb_i   => wb_stb_i,
      sl_we_i    => wb_we_i,
      sl_dat_o   => wb_dat_o,
      sl_ack_o   => wb_ack_o,
      sl_stall_o => wb_stall_o);

    U_WB_SLAVE : wb_i2c_arb_slave
    port map (
    	rst_n_i  => rst_n_i,
    	clk_sys_i => clk_i,
    	wb_dat_i   => wb_in.dat,
        wb_dat_o   => wb_out.dat,
        wb_cyc_i   => wb_in.cyc,
        wb_sel_i   => wb_in.sel,
        wb_stb_i   => wb_in.stb,
        wb_we_i    => wb_in.we,
        wb_ack_o   => wb_out.ack,
        wb_stall_o => wb_out.stall,
    	regs_o    => regs_out
   );

    -- Start & Stop detectors
    ss_detectors : for I in 0 to g_num_inputs-1 generate
        ss: i2c_arbiter_ss_detector
        port map (
            clk_i => clk_i,
            rst_n_i => rst_n_i,
        
            input_sda_i => input_sda_i(I),
            input_scl_i => input_scl_i(I),
            
            start_ack_i => start_ack,
            stop_ack_i => stop_ack,
            
            start_state_o => start_cond_detect(I),
            stop_state_o => stop_cond_detect(I)
        );
    end generate ss_detectors;
   
   -- I2C Redirector
   I2C_REDIRECTOR: i2c_arbiter_redirector
        generic map (
	       g_num_inputs => g_num_inputs,
	       g_enable_oen => g_enable_oen
        )
        port map (
	       clk_i => clk_i,
	       rst_n_i => rst_n_i,
	       enable_i => '1',

	       input_sda_i => input_sda_i,
	       input_sda_o => input_sda_o,
	       input_sda_oen => input_sda_oen,
	
	       input_scl_i => input_scl_i,
	       input_scl_o => input_scl_o,
	       input_scl_oen => input_scl_oen,
	
	       output_sda_i => output_sda_i,
	       output_sda_o => output_sda_o,
	       output_sda_oen => output_sda_oen,
	
	       output_scl_i => output_scl_i,
	       output_scl_o => output_scl_o,
	       output_scl_oen => output_scl_oen,

	       input_enabled_i => redirector_enable_input,
	       input_idx_enabled_i => active_input
    );

    -- I2C Hotone decoder
    I2C_HOTONE_DEC: i2c_arbiter_hotone_dec
        generic map (
	       g_num_inputs => g_num_inputs
        )
        port map (
	       clk_i => clk_i,
	       rst_n_i => rst_n_i,
	       enable_i => '1',

	       start_state_i => start_cond_detect,
	
	       input_enabled_o => hotone_enable_input,
	       input_idx_enabled_o => active_input_hotone
    );
    
    -- Mux for the I2C Redirector
    redirector_enable_input <= '1' when g_enable_bypass_mode and regs_out.cr_bypass_mode_o = '1' else hotone_enable_input;
    
    -- Active_input Reg
    active_input_idx_process: process(clk_i)
    begin
        if rising_edge(clk_i) then
                if rst_n_i = '0' then
                    active_input <= 0;
                elsif arb_st = ARB_WAIT then
                            if g_enable_bypass_mode and regs_out.cr_bypass_mode_o = '1' then
                                active_input <= to_integer(signed(regs_out.cr_bypass_src_o));
                            elsif hotone_enable_input = '1' then
                                active_input <= active_input_hotone;
                            end if;
                end if;
        end if;
    end process active_input_idx_process;
    
    -- Start/Stop Ack process
    start_stop_ack_process : process(arb_st,stop_cond_detect,active_input)
    begin
        case arb_st is
            when ARB_IDLE =>
               stop_ack <= '0';
               start_ack <= '0';
            when ARB_WAIT =>
               stop_ack <= '0';
               start_ack <= '0';
            when ARB_BLOCKED =>
                if stop_cond_detect(active_input) = '1' then
                    stop_ack <= '1';
                    start_ack <= '1';
                else
                    stop_ack <= '0';
                    start_ack <= '0';
               end if;
           when ARB_RELEASED =>
                stop_ack <= '0';
                start_ack <= '0';
           when ARB_BYPASS =>
                stop_ack <= '1';
                start_ack <= '1';
           when others =>
                stop_ack <= '0';
                start_ack <= '0';
        end case;
    end process start_stop_ack_process;
    
    -- FSM process
	main_state : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_n_i = '0' then
				arb_st <= ARB_IDLE;
			else
				case arb_st is
					when ARB_IDLE =>
                       
					   arb_st <= ARB_WAIT;
					  	
                    when ARB_WAIT =>
							if g_enable_bypass_mode and regs_out.cr_bypass_mode_o = '1' then  
								arb_st <= ARB_BYPASS;
							elsif hotone_enable_input = '1' then
									arb_st <= ARB_BLOCKED;
							end if;
							
				    when ARB_BLOCKED =>
							if stop_cond_detect(active_input) = '1' then
								arb_st <= ARB_RELEASED;
							end if;
							
				    when ARB_RELEASED =>
							arb_st <= ARB_IDLE;

				    when ARB_BYPASS => 
					       if g_enable_bypass_mode and regs_out.cr_bypass_mode_o = '0' then   
						      arb_st <= ARB_RELEASED;
					       end if;
					       
				    when others =>
							arb_st <= ARB_IDLE;
				end case;
			end if;
		end if;
	end process main_state;

end struct;
