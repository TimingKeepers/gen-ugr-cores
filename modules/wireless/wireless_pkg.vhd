library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package wireless_pkg is
  
  component wirelessTxRx_logic is
      generic (
      -- Clock Data Recovery module parameters
      -- number of bits for edge counter
          g_num_bits_cnt_i : natural := 10;
      -- max value of the counter 
          g_max_value_i    : natural := 1000;
      -- max value of the counter 
          g_half_trans_i   : natural := 40;
      -- max value of the counter 
          g_full_trans_i   : natural := 80    
          );
          
      port (
      -- CH0 inputs
          --ch0_loopen_i    : in STD_LOGIC; -- Loop enable
          ch0_data_i      : in STD_LOGIC; -- Rx coded serial data
          ch0_tx_data_i   : in STD_LOGIC_VECTOR (15 downto 0); -- Tx data
          ch0_tx_k_i      : in STD_LOGIC_VECTOR (1 downto 0); -- Trans control code
          ch0_frame_in_i  : in STD_LOGIC; -- Frame available to be sent
          ch0_rec_clk_i   : in STD_LOGIC; -- OSERDES clock from the IOB
      -- CH1 inputs  
          --ch1_loopen_i    : in STD_LOGIC; -- Loop enable
          ch1_data_i      : in STD_LOGIC; -- Rx data
          ch1_tx_data_i   : in STD_LOGIC_VECTOR (15 downto 0); -- Tx data
          ch1_tx_k_i      : in STD_LOGIC_VECTOR (1 downto 0); -- Trans control code
          ch1_frame_in_i  : in STD_LOGIC; -- Frame available to be sent
          ch1_rec_clk_i   : in STD_LOGIC; -- OSERDES clock from the IOB
      -- Global inputs
          dedicated_clk_i : in STD_LOGIC; -- Clock signal (500 MHz)
          rst_i           : in STD_LOGIC; -- Reset
       
      -- CH0 outputs    
          ch0_data_o         : out STD_LOGIC; -- Tx coded serial data
          ch0_rx_bitslide_o  : out STD_LOGIC_VECTOR (4 downto 0); -- Bitslide
          ch0_rx_data_o      : out STD_LOGIC_VECTOR (15 downto 0); -- Rx data
          ch0_rx_enc_err_o   : out STD_LOGIC; -- Encoding error
          ch0_rx_k_o         : out STD_LOGIC_VECTOR (1 downto 0); -- Trans control code
          ch0_rx_rbclk_o     : out STD_LOGIC; -- Recovered clock from OSERDES to an IOB
          ch0_tx_disparity_o : out STD_LOGIC; -- Disparity on the last transmission
          ch0_ready_o        : out STD_LOGIC; -- Serdes is locked and aligned
      -- CH1 outputs
          ch1_data_o         : out STD_LOGIC; -- Tx coded serial data
          ch1_rx_bitslide_o  : out STD_LOGIC_VECTOR (4 downto 0); -- Bitslide
          ch1_rx_data_o      : out STD_LOGIC_VECTOR (15 downto 0); -- Rx data
          ch1_rx_enc_err_o   : out STD_LOGIC; -- Encoding error
          ch1_rx_k_o         : out STD_LOGIC_VECTOR (1 downto 0); -- Trans control code
          ch1_rx_rbclk_o     : out STD_LOGIC; -- Recovered clock from OSERDES to an IOB
          ch1_tx_disparity_o : out STD_LOGIC; -- Disparity on the last transmission
          ch1_ready_o        : out STD_LOGIC; -- Serdes is locked and aligned
      -- Global output
          tx_out_clk_o       : out STD_LOGIC -- Transmission clock
            
          );
  end component;

end wireless_pkg;
