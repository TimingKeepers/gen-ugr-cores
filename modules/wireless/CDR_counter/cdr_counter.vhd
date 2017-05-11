----------------------------------------------------------------------------------
-- Company: UGR
-- Engineer: Francisco Girela-Lopez
-- 
-- Create Date: 06/16/2016 10:10:13 AM
-- Design Name: Clock data recovery block
-- Module Name: cdr_counter - Behavioral
-- Project Name: Wireless White Rabbit
-- Target Devices: ZEN board
-- Tool Versions: 
-- Description: This module recovers the transmission clock of a 
-- data string.
-- We receive a 8-bits width signal from a ISERDES at
-- 125 MHz. This data is a sampling of the data signal. With this 
-- vector, we check when there is a transition on the data with a 
-- 1ns resolution. In case we have no transition in the period, we 
-- recreate the clock edge checking the counters.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cdr_counter is
    Port ( gt0_data_i  : in STD_LOGIC;
           gt1_data_i  : in STD_LOGIC;
           ref_clk_i   : in STD_LOGIC;
           rst_i       : in STD_LOGIC;
           gt0_data_o  : out STD_LOGIC;
           gt1_data_o  : out STD_LOGIC;
           ch0_clk_o   : out STD_LOGIC;
           ch1_clk_o   : out STD_LOGIC
           ); 
end cdr_counter;

architecture struct of cdr_counter is

    COMPONENT PICXO_FRACXO_0
     Port (      
          --Reset signal
          reset_i           : in  STD_LOGIC                            ;
          --Reference clock for locking the VCXO, can be any clock (local, BUFG, clock enable...)
          ref_clk_i         : in  STD_LOGIC                            ;
          --Clocks
          txoutclk_i        : in  std_logic                            ; 
          --phase detector clock enable, for future use
          rsigce_i          : in  STD_LOGIC                            ;
          vsigce_i          : in  STD_LOGIC                            ;
          vsigce_o          : out STD_LOGIC                            ;
          --Coefficients and divider values
          G1                : in  STD_LOGIC_VECTOR (4 downto 0)        ;
          G2                : in  STD_LOGIC_VECTOR (4 downto 0)        ;
          R                 : in  STD_LOGIC_VECTOR (15 downto 0)       ;
          V                 : in  STD_LOGIC_VECTOR (15 downto 0)       ;
          ce_dsp_rate       : in  std_logic_vector (15 downto 0)       ;
          acc_step          : in  std_logic_vector (3 downto 0)        ;
          --Offset, hold
          Offset_ppm        : in  std_logic_vector (21 downto 0)       ;
          Offset_en         : in  std_logic                            ;
          DON_I             : in  std_logic_vector (0  downto 0)       ;
          --Coefficients reserved
          C_i               : in  STD_LOGIC_VECTOR (6 downto 0);
          P_i               : in  STD_LOGIC_VECTOR (9 downto 0);
          N_i               : in  STD_LOGIC_VECTOR (9 downto 0)        ;
          --TXPI Port data
          acc_data          : out std_logic_vector (4 downto 0)        ;
          --Debug port
          error_o           : out std_logic_vector (20 downto 0)       ;
          volt_o            : out std_logic_vector (21 downto 0)       ;
          ce_pi_o           : out std_logic                            ;
          ce_pi2_o          : out std_logic                            ;
          ce_dsp_o          : out std_logic                            ;                
          ovf_pd            : out std_logic                            ;                                          
          ovf_ab            : out std_logic                            ;
          ovf_volt          : out std_logic                            ;
          ovf_int           : out std_logic                                           
     );
    END COMPONENT;
    
    COMPONENT pd 
        PORT (
            reset       : in   STD_LOGIC;
            refsig      : in   STD_LOGIC;
            rstcnt      : in   STD_LOGIC;
            vcoclk      : in   STD_LOGIC; 
            data        : out  STD_LOGIC;
            phase_error : out  STD_LOGIC_VECTOR(20 downto 0)
            );
    END COMPONENT;
    
    COMPONENT fq 
        PORT (
            rst_i       : in   STD_LOGIC;
            ref_status  : in   STD_LOGIC;
            phase_error : in   STD_LOGIC_VECTOR(20 downto 0);
            rstcnt      : in   STD_LOGIC;
            vcoclk      : in   STD_LOGIC; 
            vc          : out  STD_LOGIC_VECTOR(21 downto 0)
            );
    END COMPONENT;
    
    component WHITERABBIT_GTPE_2PCHANNEL_WRAPPER_GT
      generic
      (
        -- Simulation attributes
        WRAPPER_SIM_GTRESET_SPEEDUP    : string   := "false" -- Set to "true" to speed up sim reset
      );
      port
      (
        
        --GT0  (X0Y0)
        GT0_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
        GT0_DRPCLK_IN                           : in   std_logic;
        GT0_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
        GT0_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
        GT0_DRPEN_IN                            : in   std_logic;
        GT0_DRPRDY_OUT                          : out  std_logic;
        GT0_DRPWE_IN                            : in   std_logic;
        GT0_EYESCANDATAERROR_OUT                : out  std_logic;
        GT0_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
        GT0_RXUSERRDY_IN                        : in   std_logic;
        GT0_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
        GT0_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
        GT0_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
        GT0_RXBYTEISALIGNED_OUT                 : out  std_logic;
        GT0_RXSLIDE_IN                          : in   std_logic;
        GT0_RXCOMMADET_OUT                      : out  std_logic;  --eml. Added.
        GT0_GTRXRESET_IN                        : in   std_logic;
        GT0_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
        GT0_RXOUTCLK_OUT                        : out  std_logic;
        GT0_RXPMARESET_IN                       : in   std_logic;
        GT0_RXUSRCLK_IN                         : in   std_logic;
        GT0_RXUSRCLK2_IN                        : in   std_logic;
        GT0_GTPRXN_IN                           : in   std_logic;
        GT0_GTPRXP_IN                           : in   std_logic;
        GT0_RXCDRRESET_IN                       : in   std_logic;  --eml. Added.
        GT0_RXCDRLOCK_OUT                       : out  std_logic;
        GT0_RXELECIDLE_OUT                      : out  std_logic;
        GT0_RXLPMHFHOLD_IN                      : in   std_logic;
        GT0_RXLPMLFHOLD_IN                      : in   std_logic;
        GT0_RXRESETDONE_OUT                     : out  std_logic;
        GT0_TXUSERRDY_IN                        : in   std_logic;
        GT0_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
        GT0_GTTXRESET_IN                        : in   std_logic;
        GT0_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
        GT0_TXOUTCLK_OUT                        : out  std_logic;
        GT0_TXOUTCLKFABRIC_OUT                  : out  std_logic;
        GT0_TXOUTCLKPCS_OUT                     : out  std_logic;
        GT0_TXUSRCLK_IN                         : in   std_logic;
        GT0_TXUSRCLK2_IN                        : in   std_logic;
        GT0_GTPTXN_OUT                          : out  std_logic;
        GT0_GTPTXP_OUT                          : out  std_logic;
        GT0_TXRESETDONE_OUT                     : out  std_logic;
        GT0_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
        GT0_TXPPMSTEPSIZE_IN                    : in   std_logic_vector(4 downto 0);
    
        --GT1  (X0Y1)
        GT1_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
        GT1_DRPCLK_IN                           : in   std_logic;
        GT1_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
        GT1_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
        GT1_DRPEN_IN                            : in   std_logic;
        GT1_DRPRDY_OUT                          : out  std_logic;
        GT1_DRPWE_IN                            : in   std_logic;
        GT1_EYESCANDATAERROR_OUT                : out  std_logic;
        GT1_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
        GT1_RXUSERRDY_IN                        : in   std_logic;
        GT1_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
        GT1_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
        GT1_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
        GT1_RXBYTEISALIGNED_OUT                 : out  std_logic;
        GT1_RXSLIDE_IN                          : in   std_logic;
        GT1_RXCOMMADET_OUT                      : out  std_logic;  --Added. eml.
        GT1_GTRXRESET_IN                        : in   std_logic;
        GT1_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
        GT1_RXOUTCLK_OUT                        : out  std_logic;
        GT1_RXPMARESET_IN                       : in   std_logic;
        GT1_RXUSRCLK_IN                         : in   std_logic;
        GT1_RXUSRCLK2_IN                        : in   std_logic;
        GT1_GTPRXN_IN                           : in   std_logic;
        GT1_GTPRXP_IN                           : in   std_logic;
        GT1_RXCDRRESET_IN                       : in   std_logic;  --Added eml.
        GT1_RXCDRLOCK_OUT                       : out  std_logic;
        GT1_RXELECIDLE_OUT                      : out  std_logic;
        GT1_RXLPMHFHOLD_IN                      : in   std_logic;
        GT1_RXLPMLFHOLD_IN                      : in   std_logic;
        GT1_RXRESETDONE_OUT                     : out  std_logic;
        GT1_TXUSERRDY_IN                        : in   std_logic;
        GT1_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
        GT1_GTTXRESET_IN                        : in   std_logic;
        GT1_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
        GT1_TXOUTCLK_OUT                        : out  std_logic;
        GT1_TXOUTCLKFABRIC_OUT                  : out  std_logic;
        GT1_TXOUTCLKPCS_OUT                     : out  std_logic;
        GT1_TXUSRCLK_IN                         : in   std_logic;
        GT1_TXUSRCLK2_IN                        : in   std_logic;
        GT1_GTPTXN_OUT                          : out  std_logic;
        GT1_GTPTXP_OUT                          : out  std_logic;
        GT1_TXRESETDONE_OUT                     : out  std_logic;
        GT1_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
        GT1_TXPPMSTEPSIZE_IN                    : in   std_logic_vector(4 downto 0);
    
        ---------------------------- Common Block - Ports --------------------------
        GT0_GTREFCLK0_IN                        : in   std_logic;
        GT0_PLL0LOCK_OUT                        : out  std_logic;
        GT0_PLL0LOCKDETCLK_IN                   : in   std_logic;
        GT0_PLL0REFCLKLOST_OUT                  : out  std_logic;
        GT0_PLL0RESET_IN                        : in   std_logic);
    end component;
    
    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(31 downto 0);
    
    signal  picxo_rst0                      : STD_LOGIC_VECTOR (7 downto 0);
    signal  picxo_rst1                      : STD_LOGIC_VECTOR (7 downto 0);
    signal  gt0_txpippmstepsize_i           : STD_LOGIC_VECTOR (4 downto 0);
    signal  gt1_txpippmstepsize_i           : STD_LOGIC_VECTOR (4 downto 0);
    signal  ch0_error                       : STD_LOGIC_VECTOR (20 downto 0);
    signal  ch1_error                       : STD_LOGIC_VECTOR (20 downto 0);
    signal  ch0_volt                        : STD_LOGIC_VECTOR (21 downto 0);
    signal  ch1_volt                        : STD_LOGIC_VECTOR (21 downto 0);
--    signal  ce_pi                           : std_logic;
--    signal  ce_pi2                          : std_logic;
    signal  ch0_ce_dsp                      : std_logic;
    signal  ch1_ce_dsp                      : std_logic;
--    signal  ovf_pd                          : std_logic;
--    signal  ovf_ab                          : std_logic;
--    signal  ovf_volt                        : std_logic;
--    signal  ovf_int                         : std_logic;
    signal  qpll_lockdet                    : std_logic;
    signal  gt0_lock_filtered               : std_logic;
    signal  gt1_lock_filtered               : std_logic;
    signal  gt0_tx_out_clk                  : std_logic;
    signal  gt1_tx_out_clk                  : std_logic;
    signal  gt0_tx_out_clk_bufin            : std_logic;
    signal  gt1_tx_out_clk_bufin            : std_logic;  
--    signal  pllout_gt0_tx_out_clk           : std_logic;
--    signal  pllout_gt1_tx_out_clk           : std_logic;
    signal  pllout_gt0_tx_out               : std_logic;
    signal  pllout_gt1_tx_out               : std_logic;  
    signal  gt0_tx_pll_clk                  : std_logic;
    signal  gt1_tx_pll_clk                  : std_logic;
    signal  gt0_gtrxreset_i                 : std_logic;
    signal  gt1_gtrxreset_i                 : std_logic;
    signal  gt0_gttxreset_i                 : std_logic;
    signal  gt1_gttxreset_i                 : std_logic;
    signal  gt0_rx_rst_done                 : std_logic;
    signal  gt1_rx_rst_done                 : std_logic;
    signal  gt0_tx_rst_done                 : std_logic;
    signal  gt1_tx_rst_done                 : std_logic;
    signal  gt0_rst_done                    : std_logic;
    signal  gt1_rst_done                    : std_logic;
    signal  gt0_rx_data_int                 : std_logic_vector(15 downto 0);
    signal  gt1_rx_data_int                 : std_logic_vector(15 downto 0);

    constant c_rxcdrlock_max                : integer := 30;
    
    signal rst_n                            : std_logic;
    
    signal ch0_retimed_data                 : std_logic;
    signal ch1_retimed_data                 : std_logic;
    signal ch0_ref_off                      : std_logic;
    signal ch1_ref_off                      : std_logic;
    signal ch0_ref_vector                   : std_logic_vector (9 downto 0);
    signal ch1_ref_vector                   : std_logic_vector (9 downto 0);
        
    signal debugclk : std_logic;
    
    attribute mark_debug : string;
    attribute mark_debug of gt0_txpippmstepsize_i: signal is "true";
    attribute mark_debug of picxo_rst0: signal is "true";
    attribute mark_debug of ch0_error: signal is "true";
    attribute mark_debug of ch0_volt: signal is "true";
--    attribute mark_debug of error2: signal is "true";
--    attribute mark_debug of error3: signal is "true";
--    attribute mark_debug of volt2: signal is "true";
--    attribute mark_debug of ce_pi: signal is "true";
--    attribute mark_debug of ce_pi2: signal is "true";
    attribute mark_debug of ch0_ce_dsp : signal is "true";
--    attribute mark_debug of ovf_pd : signal is "true";
--    attribute mark_debug of ovf_ab : signal is "true";
--    attribute mark_debug of ovf_volt : signal is "true";
--    attribute mark_debug of ovf_int : signal is "true";
--    attribute mark_debug of debugclk : signal is "true";
    attribute mark_debug of qpll_lockdet : signal is "true";
    attribute mark_debug of gt0_lock_filtered : signal is "true";
    attribute mark_debug of gt0_tx_out_clk : signal is "true";
    attribute mark_debug of ch0_ref_vector : signal is "true";
    attribute mark_debug of ch0_ref_off : signal is "true";
    attribute mark_debug of ch0_retimed_data : signal is "true";
--    attribute mark_debug of gt0_tx_rst_done : signal is "true";
--    attribute mark_debug of gt0_rst_done : signal is "true";
--    attribute mark_debug of gt0_rx_data_int : signal is "true";
--    attribute mark_debug of ch0_debug0_o : signal is "true";
--    attribute mark_debug of ch0_debug1_o : signal is "true";
--    attribute mark_debug of ch0_debug2_o : signal is "true";
--    attribute mark_debug of ch0_debug3_o : signal is "true";
    
    
begin

    --  Static signal Assigments
    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(31 downto 0)   <= (others => '0');
  
    rst_n <= not rst_i;
    
      GT0_U_BUF_TxPllClk : BUFG
        port map (
          I => gt0_tx_out_clk_bufin,
          O => gt0_tx_pll_clk);
          
      GT0_BUFR_inst : BUFR
         generic map (
            BUFR_DIVIDE => "2",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
            SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
         )
         port map (
            O => pllout_gt0_tx_out,     -- 1-bit output: Clock output port
            CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
            CLR => '0', -- 1-bit input: Active high, asynchronous clear (Divided modes only)
            I => gt0_tx_pll_clk      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
         );    
          
      GT0_U_BUF_TxOutClk : BUFG
        port map (
          I => pllout_gt0_tx_out,
          O => gt0_tx_out_clk);
          
          
      ch0_clk_o <= gt0_tx_out_clk;

      gt0_gtrxreset_i <= not qpll_lockdet;
      gt0_gttxreset_i <= not qpll_lockdet;
      
      
      GT1_U_BUF_TxPllClk : BUFG
        port map (
          I => gt1_tx_out_clk_bufin,
          O => gt1_tx_pll_clk);
          
      GT1_BUFR_inst : BUFR
         generic map (
            BUFR_DIVIDE => "2",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
            SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
         )
         port map (
            O => pllout_gt1_tx_out,     -- 1-bit output: Clock output port
            CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
            CLR => '0', -- 1-bit input: Active high, asynchronous clear (Divided modes only)
            I => gt1_tx_pll_clk      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
         );    
          
      GT1_U_BUF_TxOutClk : BUFG
        port map (
          I => pllout_gt1_tx_out,
          O => gt1_tx_out_clk);
          
          
      ch1_clk_o <= gt1_tx_out_clk;

      gt1_gtrxreset_i <= not qpll_lockdet;
      gt1_gttxreset_i <= not qpll_lockdet;
    
    
    U_GTP_INST : WHITERABBIT_GTPE_2PCHANNEL_WRAPPER_GT
        generic map(
             -- Simulation attributes
            WRAPPER_SIM_GTRESET_SPEEDUP => "false")
      port map
        (
    
        --_________________________________________________________________________
        --GT0  (X0Y0)
        --_________________________________________________________________________
        ---------------------------- Channel - DRP Ports  --------------------------
        GT0_DRPADDR_IN            => (others => '0'),
        GT0_DRPCLK_IN             => gt0_tx_out_clk,  -- Be careful with the input clock
        GT0_DRPDI_IN              => (others => '0'),
        GT0_DRPDO_OUT             => open,
        GT0_DRPEN_IN              => '0',
        GT0_DRPRDY_OUT            => open,
        GT0_DRPWE_IN              => '0',
        -------------------------- RX Margin Analysis Ports ------------------------
        GT0_EYESCANDATAERROR_OUT  => open,
        ------------------------------- Loopback Ports -----------------------------
        GT0_LOOPBACK_IN           => "000",
        --------------------- RX Initialization and Reset Ports --------------------
        GT0_RXUSERRDY_IN          => '0', --gt0_lock_filtered,
        ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
        GT0_RXCHARISK_OUT         => open,
        GT0_RXCDRRESET_IN         => '0',                                --Don't use this pin. Before ch0_rx_cdr_rst
        GT0_RXCDRLOCK_OUT         => open,
        GT0_RXDISPERR_OUT         => open,
        GT0_RXNOTINTABLE_OUT      => open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        GT0_RXBYTEISALIGNED_OUT   => open,
        GT0_RXSLIDE_IN            => tied_to_ground_i,
        GT0_RXCOMMADET_OUT        => open,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        GT0_GTRXRESET_IN          => '0', --gt0_gtrxreset_i,
        GT0_RXPMARESET_IN         => '0',
        ------------------ Receive Ports - FPGA RX interface Ports -----------------
        GT0_RXDATA_OUT            => open, --gt0_rx_data_int,
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        GT0_RXOUTCLK_OUT          => open,
    
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        GT0_RXUSRCLK_IN           => '0',--gt0_tx_pll_clk,    --check the pag 220 to understand better
        GT0_RXUSRCLK2_IN          => '0',--gt0_tx_pll_clk,
    
        --------------------------- Receive Ports - RX AFE -------------------------
        GT0_GTPRXN_IN             => '0',
        GT0_GTPRXP_IN             => '0',
    
        --------------------------- Receive Ports - PCIe, SATA/SAS status ----------
        GT0_RXELECIDLE_OUT        => open,
    
        --------------------- Receive Ports - RX Equilizer Ports -------------------
        GT0_RXLPMHFHOLD_IN        => '0',
        GT0_RXLPMLFHOLD_IN        => '0',
    
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        GT0_RXRESETDONE_OUT       => open, --gt0_rx_rst_done,
        --------------------- TX Initialization and Reset Ports --------------------
        GT0_TXUSERRDY_IN          => qpll_lockdet,
        GT0_GTTXRESET_IN          => gt0_gttxreset_i,
    
        --------------------- Transmit Ports - TX Gearbox Ports --------------------
        GT0_TXCHARISK_IN          => "00",
    
        ------------------ Transmit Ports - TX Data Path interface -----------------
        GT0_TXDATA_IN             => tied_to_ground_vec_i(15 downto 0), --gt0_rx_data_int,
    
        ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        GT0_TXOUTCLK_OUT          => gt0_tx_out_clk_bufin,
        GT0_TXOUTCLKFABRIC_OUT    => open,
        GT0_TXOUTCLKPCS_OUT       => open,
    
        ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
        GT0_TXUSRCLK_IN           => gt0_tx_pll_clk,        -- NOT REF CLOCK
        GT0_TXUSRCLK2_IN          => gt0_tx_pll_clk,        -- NOT REF CLOCK
    
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        GT0_GTPTXN_OUT            => open,
        GT0_GTPTXP_OUT            => open,
    
        ------------- Transmit Ports - TX Initialization and Reset Ports -----------
        GT0_TXRESETDONE_OUT       => gt0_tx_rst_done,
        ------------------ Transmit Ports - pattern Generator Ports ----------------
        GT0_TXPRBSSEL_IN          => "000",
        ---TXPI---
        GT0_TXPPMSTEPSIZE_IN      => gt0_txpippmstepsize_i,
    
        --_________________________________________________________________________
        --GT1  (X0Y1)
        --_________________________________________________________________________
        ---------------------------- Channel - DRP Ports  --------------------------
        GT1_DRPADDR_IN            => (others => '0'),
        GT1_DRPCLK_IN             => gt1_tx_out_clk,  -- Be careful with the input clock
        GT1_DRPDI_IN              => (others => '0'),
        GT1_DRPDO_OUT             => open,
        GT1_DRPEN_IN              => '0',
        GT1_DRPRDY_OUT            => open,
        GT1_DRPWE_IN              => '0',
        -------------------------- RX Margin Analysis Ports ------------------------
        GT1_EYESCANDATAERROR_OUT  => open,
        ------------------------------- Loopback Ports -----------------------------
        GT1_LOOPBACK_IN           => "000",
        --------------------- RX Initialization and Reset Ports --------------------
        GT1_RXUSERRDY_IN          => '0',--gt1_lock_filtered,
        ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
        GT1_RXCHARISK_OUT         => open,
        GT1_RXCDRRESET_IN         => '0',                                --Don't use this pin. Before ch1_rx_cdr_rst
        GT1_RXCDRLOCK_OUT         => open,
        GT1_RXDISPERR_OUT         => open,
        GT1_RXNOTINTABLE_OUT      => open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        GT1_RXBYTEISALIGNED_OUT   => open,
        GT1_RXSLIDE_IN            => tied_to_ground_i,
        GT1_RXCOMMADET_OUT        => open,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        GT1_GTRXRESET_IN          => '0', --gt1_gtrxreset_i,
        GT1_RXPMARESET_IN         => '0',
        ------------------ Receive Ports - FPGA RX interface Ports -----------------
        GT1_RXDATA_OUT            => open, --gt1_rx_data_int,
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        GT1_RXOUTCLK_OUT          => open,
    
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        GT1_RXUSRCLK_IN           => '0', --gt1_tx_pll_clk,    --check the pag 220 to understand better
        GT1_RXUSRCLK2_IN          => '0', --gt1_tx_pll_clk,
    
        --------------------------- Receive Ports - RX AFE -------------------------
        GT1_GTPRXN_IN             => '0',
        GT1_GTPRXP_IN             => '0',
    
        --------------------------- Receive Ports - PCIe, SATA/SAS status ----------
        GT1_RXELECIDLE_OUT        => open,
    
        --------------------- Receive Ports - RX Equilizer Ports -------------------
        GT1_RXLPMHFHOLD_IN        => '0',
        GT1_RXLPMLFHOLD_IN        => '0',
    
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        GT1_RXRESETDONE_OUT       => open, --gt1_rx_rst_done,
        --------------------- TX Initialization and Reset Ports --------------------
        GT1_TXUSERRDY_IN          => qpll_lockdet,
        GT1_GTTXRESET_IN          => gt1_gttxreset_i,
    
        --------------------- Transmit Ports - TX Gearbox Ports --------------------
        GT1_TXCHARISK_IN          => "00",
    
        ------------------ Transmit Ports - TX Data Path interface -----------------
        GT1_TXDATA_IN             => tied_to_ground_vec_i(15 downto 0), --gt1_rx_data_int,
    
        ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        GT1_TXOUTCLK_OUT          => gt1_tx_out_clk_bufin,
        GT1_TXOUTCLKFABRIC_OUT    => open,
        GT1_TXOUTCLKPCS_OUT       => open,
    
        ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
        GT1_TXUSRCLK_IN           => gt1_tx_pll_clk,        -- NOT REF CLOCK
        GT1_TXUSRCLK2_IN          => gt1_tx_pll_clk,        -- NOT REF CLOCK
    
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        GT1_GTPTXN_OUT            => open,
        GT1_GTPTXP_OUT            => open,
    
        ------------- Transmit Ports - TX Initialization and Reset Ports -----------
        GT1_TXRESETDONE_OUT       => gt1_tx_rst_done,
        ------------------ Transmit Ports - pattern Generator Ports ----------------
        GT1_TXPRBSSEL_IN          => "000",
        ---TXPI---
        GT1_TXPPMSTEPSIZE_IN      => gt1_txpippmstepsize_i,
    
        ---------------------------- Common Block - Ports --------------------------
        GT0_GTREFCLK0_IN          => ref_clk_i,     -- Accoding to the CoreGen configuration this clock must be 100MHz 
        GT0_PLL0LOCK_OUT          => qpll_lockdet,
        GT0_PLL0LOCKDETCLK_IN     => '0',
        GT0_PLL0REFCLKLOST_OUT    => open,
        GT0_PLL0RESET_IN          => rst_n);        -- Before rst_int. for v15
        
    
    process (gt0_tx_out_clk, picxo_rst0, gt0_gttxreset_i)
    begin
        if(rst_i = '0' or gt0_gttxreset_i ='1') then
            picxo_rst0 (7 downto 1)     <= "1111111";
        elsif rising_edge (gt0_tx_out_clk) then
            picxo_rst0 (7 downto 1)     <=  picxo_rst0(6 downto 0);
        end if;
    end process;  
        
    PICXO_FRACXO_0_i : PICXO_FRACXO_0
     PORT MAP (
          REF_CLK_I        => '0',--gt0_data_i,
          RESET_I          => picxo_rst0(7),
          TXOUTCLK_I       => gt0_tx_out_clk,
          RSIGCE_I         => '1',
          VSIGCE_I         => '1',
          VSIGCE_O         => open,
          ACC_STEP         => x"F",
          G1               => "01001",--"01011", 01001 01100 00011
          G2               => "10001",--"10001", 01001 01100
          R                => x"0008",
          V                => x"0008",
          C_I              => tied_to_ground_vec_i(6 downto 0),
          P_I              => tied_to_ground_vec_i(9 downto 0),
          N_I              => tied_to_ground_vec_i(9 downto 0),
          DON_I            => "1",
          OFFSET_PPM       => ch0_volt,--tied_to_ground_vec_i(21 downto 0),
          OFFSET_EN        => '1',
          CE_DSP_RATE      => x"000A",
          --DRP USER PORT
          ACC_DATA         => gt0_txpippmstepsize_i,
          --DEBUG PORT
          ERROR_O          => open, --error,
          VOLT_O           => open, --volt,
          CE_PI_O          => open, --ce_pi,
          CE_PI2_O         => open, --ce_pi2,
          CE_DSP_O         => ch0_ce_dsp,
          OVF_PD           => open, --ovf_pd,
          OVF_AB           => open, --ovf_ab,
          OVF_VOLT         => open, --ovf_volt,
          OVF_INT          => open --ovf_int          
        );
                
            
           -- Accumulating Bang-Bang phase detector
        ch0_pd_comp : pd
          port map (
            -- Outputs
            data          => ch0_retimed_data,
            phase_error   => ch0_error,
            -- Inputs
            refsig        => gt0_data_i,
            rstcnt        => ch0_ce_dsp,
            vcoclk        => gt0_tx_out_clk,--serdes_clk_i,
            reset         => rst_n
            );
            
        gt0_data_o <= ch0_retimed_data;
          
        process (gt0_tx_out_clk)
        begin
            if (rst_i = '0') then
                ch0_ref_vector <= (others => '0');
                ch0_ref_off <= '1';
            elsif rising_edge (gt0_tx_out_clk) then
                ch0_ref_vector <= ch0_ref_vector (8 downto 0) & ch0_retimed_data;
                if (ch0_ref_vector = "0000000000") then
                    ch0_ref_off <= '1';
                else
                    ch0_ref_off <= '0';
                end if;
            end if;
        end process;  
          
        ch0_fq_comp :fq 
           port map (
            rst_i       => rst_i,
            ref_status  => ch0_ref_off,
            phase_error => ch0_error,
            rstcnt      => ch0_ce_dsp,
            vcoclk      => gt0_tx_out_clk, 
            vc          => ch0_volt
            );
            
            
            
    process (gt1_tx_out_clk, picxo_rst1, gt1_gttxreset_i)
    begin
        if(rst_i = '0' or gt1_gttxreset_i ='1') then
            picxo_rst1 (7 downto 1)     <= "1111111";
        elsif rising_edge (gt1_tx_out_clk) then
            picxo_rst1 (7 downto 1)     <=  picxo_rst1(6 downto 0);
        end if;
    end process;  
        
    PICXO_FRACXO_1_i : PICXO_FRACXO_0
     PORT MAP (
          REF_CLK_I        => '0',--gt0_data_i,
          RESET_I          => picxo_rst1(7),
          TXOUTCLK_I       => gt1_tx_out_clk,
          RSIGCE_I         => '1',
          VSIGCE_I         => '1',
          VSIGCE_O         => open,
          ACC_STEP         => x"F",
          G1               => "01001",--"01011", 01001 01100 00011
          G2               => "10001",--"10001", 01001 01100
          R                => x"0008",
          V                => x"0008",
          C_I              => tied_to_ground_vec_i(6 downto 0),
          P_I              => tied_to_ground_vec_i(9 downto 0),
          N_I              => tied_to_ground_vec_i(9 downto 0),
          DON_I            => "1",
          OFFSET_PPM       => ch1_volt,--tied_to_ground_vec_i(21 downto 0),
          OFFSET_EN        => '1',
          CE_DSP_RATE      => x"000A",
          --DRP USER PORT
          ACC_DATA         => gt1_txpippmstepsize_i,
          --DEBUG PORT
          ERROR_O          => open,
          VOLT_O           => open,
          CE_PI_O          => open,
          CE_PI2_O         => open,
          CE_DSP_O         => ch1_ce_dsp,
          OVF_PD           => open,
          OVF_AB           => open,
          OVF_VOLT         => open,
          OVF_INT          => open          
        );
                
            
        -- Accumulating Bang-Bang phase detector
        ch1_pd_comp : pd
          port map (
            -- Outputs
            data          => ch1_retimed_data,
            phase_error   => ch1_error,
            -- Inputs
            refsig        => gt1_data_i,
            rstcnt        => ch1_ce_dsp,
            vcoclk        => gt1_tx_out_clk,
            reset         => rst_n
            );
            
        gt1_data_o <= ch1_retimed_data;
          
        process (gt1_tx_out_clk)
        begin
            if (rst_i = '0') then
                ch1_ref_vector <= (others => '0');
                ch1_ref_off <= '1';
            elsif rising_edge (gt1_tx_out_clk) then
                ch1_ref_vector <= ch1_ref_vector (8 downto 0) & ch1_retimed_data;
                if (ch1_ref_vector = "0000000000") then
                    ch1_ref_off <= '1';
                else
                    ch1_ref_off <= '0';
                end if;
            end if;
        end process;  
          
        ch1_fq_comp :fq 
           port map (
            rst_i       => '1',
            ref_status  => ch1_ref_off,
            phase_error => ch1_error,
            rstcnt      => ch1_ce_dsp,
            vcoclk      => gt1_tx_out_clk, 
            vc          => ch1_volt
            );
          

end struct;
