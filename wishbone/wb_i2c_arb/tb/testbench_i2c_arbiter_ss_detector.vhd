LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

library work;
use work.i2c_arb_pkg.all;

ENTITY testbench_i2c_arbiter_ss_detector IS 
END testbench_i2c_arbiter_ss_detector;

ARCHITECTURE behavior OF testbench_i2c_arbiter_ss_detector IS
   signal clk : std_logic := '0';
   signal reset : std_logic := '1'; -- low-level active

   constant clk_period : time := 16 ns; -- 62.5 MHz

   signal input_sda_i : std_logic;
   signal input_scl_i : std_logic;
   signal start_ack : std_logic;
   signal stop_ack : std_logic;
   signal start_state : std_logic;
   signal stop_state : std_logic;

BEGIN
   uut: i2c_arbiter_ss_detector
   port map (
   	clk_i => clk,
        rst_n_i => reset,
        
        input_sda_i => input_sda_i,
        input_scl_i => input_scl_i,
            
        start_ack_i => start_ack,
        stop_ack_i => stop_ack,
            
        start_state_o => start_state,
        stop_state_o => stop_state
        );

   clk_process :process
   begin
       clk <= '0';
       wait for clk_period/2; 
       clk <= '1';
       wait for clk_period/2;  
   end process;

   -- Stimulus process
  stim_proc: process
   begin         
       reset <='0'; -- reset!
       wait for 3 ns;
       reset <='1';
	   input_sda_i <= '1';
	   input_scl_i <= '1';
	   start_ack <= '0';
	   stop_ack <= '0';
	   wait for 250 ns;
	   input_sda_i <= '0';
	   wait for 250ns;
	   input_scl_i <= '0';
	   wait for 250 ns;
	   start_ack <= '1';
	   input_scl_i <= '1';
	   wait for 250 ns;
       input_scl_i <= '0';
       start_ack <= '0';
       wait for 250 ns;
       input_scl_i <= '1';
       wait for 250 ns;
       input_scl_i <= '0';
       wait for 250 ns;
       input_scl_i <= '1';
       wait for 250 ns;
       input_sda_i <= '1';
       wait for 100 ns;
       stop_ack <= '1';
       wait for 30 ns;
       stop_ack <= '0';
       wait;
  end process;

END;
