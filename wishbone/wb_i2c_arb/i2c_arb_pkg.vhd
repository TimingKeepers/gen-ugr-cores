library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.i2c_arb_wbgen2_pkg.all;

package i2c_arb_pkg is

constant c_I2C_ARB_SDB_DEVICE : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"0000000000000000",
      product     => (
        vendor_id => x"0000000000001164",  -- UGR
        device_id => x"7f5c6cbb", --echo -n "xwb_i2c_arbiter" | md5sum - | cut -c1-8
        version   => x"00000001",
        date      => x"20150609",
        name      => "WB I2C Arbiter     ")));

 component i2c_arbiter_ss_detector
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
    end component;

   component i2c_arbiter_redirector
   generic (
	g_num_inputs : natural range 2 to 32 := 2;
	g_enable_output_enable_signal : boolean := false
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
   end component;

   component i2c_arbiter_hotone_dec
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
   end component;

    component wb_i2c_arb_slave
    port (
    	rst_n_i                                  : in     std_logic;
    	clk_sys_i                                : in     std_logic;
    	wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    	wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    	wb_cyc_i                                 : in     std_logic;
    	wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    	wb_stb_i                                 : in     std_logic;
    	wb_we_i                                  : in     std_logic;
    	wb_ack_o                                 : out    std_logic;
    	wb_stall_o                               : out    std_logic;
    	regs_o                                   : out    t_i2c_arb_out_registers
   );
   end component;

   component wb_i2c_arbiter
	
	generic (
		g_num_inputs : natural range 2 to 32 := 2;
		g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
    	g_address_granularity : t_wishbone_address_granularity := WORD;
        g_enable_bypass_mode : boolean := true;
		g_enable_output_enable_signal : boolean := false
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
		wb_adr_i   				                 : in  std_logic_vector(31 downto 0);
		wb_dat_i                                 : in     std_logic_vector(31 downto 0);
	    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
	    wb_cyc_i                                 : in     std_logic;
	    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
	    wb_stb_i                                 : in     std_logic;
	    wb_we_i                                  : in     std_logic;
	    wb_ack_o                                 : out    std_logic;
	    wb_stall_o                               : out    std_logic
	);
	end component;

component xwb_i2c_arbiter
  generic (
      g_num_inputs : natural range 2 to 32 := 2;
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_enable_bypass_mode : boolean := true;
      g_enable_output_enable_signal : boolean := false
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
      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out
  );
  end component;

component i2c_arbiter

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

end component;
 
end package;

package body i2c_arb_pkg is

end package body;
