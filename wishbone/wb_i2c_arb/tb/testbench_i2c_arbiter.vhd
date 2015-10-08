LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

library work;
use work.i2c_arb_pkg.all;

ENTITY testbench_i2c_arbiter IS 
END testbench_i2c_arbiter;

ARCHITECTURE behavior OF testbench_i2c_arbiter IS
   signal clk : std_logic := '0';
   signal reset : std_logic := '1'; -- low-level active

   constant clk_period : time := 16 ns; -- 62.5 MHz
   constant c_num_i2c_inputs : integer := 2;

   signal input_sda_i : std_logic_vector(c_num_i2c_inputs-1 downto 0);
   signal input_sda_o : std_logic_vector(c_num_i2c_inputs-1 downto 0);
	
   signal input_scl_i : std_logic_vector(c_num_i2c_inputs-1 downto 0);
   signal input_scl_o : std_logic_vector(c_num_i2c_inputs-1 downto 0);
	
   --signal output_sda_i : std_logic;
   signal output_sda_o : std_logic;
	
   --signal output_scl_i : std_logic;
   signal output_scl_o : std_logic;

BEGIN
   	uut: wb_i2c_arbiter
	generic map(
		g_num_inputs => c_num_i2c_inputs
	)
	port map (
		clk_i => clk,
		rst_n_i => reset,

		input_sda_i => input_sda_i,
		input_sda_o => input_sda_o,
	
		input_scl_i => input_scl_i,
		input_scl_o => input_scl_o,
	
		output_sda_i => output_sda_o,
		output_sda_o => output_sda_o,
	
		output_scl_i => output_scl_o,
		output_scl_o => output_scl_o,

		wb_adr_i => (others => '0'),
		wb_dat_i   => (others => '0'),
      	wb_dat_o   => open,
		wb_cyc_i   => '0',
		wb_sel_i   => (others => '0'),
      	wb_stb_i   => '0',
      	wb_we_i    => '0',
	    wb_ack_o   => open,
      	wb_stall_o => open
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
	   input_sda_i(0) <= '1';
	   input_scl_i(0) <= '1';
	   input_sda_i(1) <= '1';
	   input_scl_i(1) <= '1';
	   wait for 250 ns;
	   input_sda_i(0) <= '0';
	   wait for 250ns;
	   input_scl_i(0) <= '0';
	   wait for 250 ns;
	   input_scl_i(0) <= '1';
	   wait for 250 ns;
       input_scl_i(0) <= '0';
       wait for 250 ns;
       input_scl_i(0) <= '1';
       wait for 250 ns;
       input_scl_i(0) <= '0';
       wait for 250 ns;
       input_scl_i(0) <= '1';
       wait for 250 ns;
       input_sda_i(0) <= '1';
       wait;
  end process;

END;
