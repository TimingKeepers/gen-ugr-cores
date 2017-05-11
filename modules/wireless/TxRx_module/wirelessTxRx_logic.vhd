----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/17/2016 09:09:08 AM
-- Design Name: 
-- Module Name: top_wirelessTxRx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module is a replica of the GTP used to transmit on the ZEN board
-- It is the responsible to send a serial 12.5 MHz data stream encoded using 16B/20B.
-- On the reception it recovers the encoded clock and it uses it to sample the 
-- incoming data. After that, it decodes the data stream and turns it on a parallel
-- 16-bits-width frame.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Things to do: poner los patrones bien en la deteccion, hacer algo con loopen,
--               contar el bitslide de salida, chequear la disparidad que sacamos,
--               k_char 01 no es posible, data retiming
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

--use work.decode_8b10b_pkg.ALL;
--use work.encode_8b10b_pkg.ALL;

entity wirelessTxRx_logic is
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
        serdes_clk_i    : in STD_LOGIC; -- Clock signal (500 MHz)
        cdr_clk_i       : in STD_LOGIC; -- Clock signal (125 MHz)
        gtp_clk_i       : in STD_LOGIC; -- Clock signal (12.5 MHz)
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
        
end wirelessTxRx_logic;

architecture Behavioral of wirelessTxRx_logic is

    -- Clock Data Recovery module
    component cdr_counter is
        Port ( gt0_data_i  : in STD_LOGIC;
               gt1_data_i  : in STD_LOGIC;
               ref_clk_i   : in STD_LOGIC;
               rst_i       : in STD_LOGIC;
               gt0_data_o  : out STD_LOGIC;
               gt1_data_o  : out STD_LOGIC;
               ch0_clk_o   : out STD_LOGIC;
               ch1_clk_o   : out STD_LOGIC
               ); 
    end component cdr_counter;
    
    -- 16B/20B encoder module
    component encode_8b10b_wrapper IS
      PORT (
    
        CLK          : IN  STD_LOGIC                    := '0';
        DIN          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        KIN          : IN  STD_LOGIC                    := '0';
        DOUT         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)       ;
    
        CE           : IN  STD_LOGIC                    := '0';
        FORCE_CODE   : IN  STD_LOGIC                    := '0';
        FORCE_DISP   : IN  STD_LOGIC                    := '0';
        DISP_IN      : IN  STD_LOGIC                    := '0';
        DISP_OUT     : OUT STD_LOGIC                          ;
        ND           : OUT STD_LOGIC                    := '0';
        KERR         : OUT STD_LOGIC                    := '0';
    
        CLK_B        : IN  STD_LOGIC                    := '0';
        DIN_B        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        KIN_B        : IN  STD_LOGIC                    := '0';
        DOUT_B       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)       ;
    
        CE_B         : IN  STD_LOGIC                    := '0';
        FORCE_CODE_B : IN  STD_LOGIC                    := '0';
        FORCE_DISP_B : IN  STD_LOGIC                    := '0';
        DISP_IN_B    : IN  STD_LOGIC                    := '0';
        DISP_OUT_B   : OUT STD_LOGIC                          ;
        ND_B         : OUT STD_LOGIC                    := '0';
        KERR_B       : OUT STD_LOGIC                    := '0'
    
        );
    end component encode_8b10b_wrapper;
    
--    -- 16B/20B decoder module

    component decode_8b10b_wrapper IS
      PORT (
    
        CLK        : IN  STD_LOGIC                    := '0';
        DIN        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        DOUT       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) ;
        KOUT       : OUT STD_LOGIC                    ;
    
        CE         : IN  STD_LOGIC                    := '0';
        SINIT      : IN  STD_LOGIC                    := '0';
        DISP_IN    : IN  STD_LOGIC                    := '0';
        CODE_ERR   : OUT STD_LOGIC                    := '0';
        DISP_ERR   : OUT STD_LOGIC                    := '0';
        ND         : OUT STD_LOGIC                    := '0';
        RUN_DISP   : OUT STD_LOGIC                    := '0';
        SYM_DISP   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    
        CLK_B      : IN  STD_LOGIC                    := '0';
        DIN_B      : IN  STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        DOUT_B     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) ;
        KOUT_B     : OUT STD_LOGIC                    ;
    
        CE_B       : IN  STD_LOGIC                    := '0';
        SINIT_B    : IN  STD_LOGIC                    := '0';
        DISP_IN_B  : IN  STD_LOGIC                    := '0';
        CODE_ERR_B : OUT STD_LOGIC                    := '0';
        DISP_ERR_B : OUT STD_LOGIC                    := '0';
        ND_B       : OUT STD_LOGIC                    := '0';
        RUN_DISP_B : OUT STD_LOGIC                    := '0';
        SYM_DISP_B : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"
    
        );
    end component decode_8b10b_wrapper;
    
    -- Internal signals
    --signal clk_ref      : std_logic := '1'; -- 500 MHz reference  clock
    signal serdes_clk_n    : std_logic := '1'; -- 500 MHz reference inverted clock
    
    -- Tx flow
    signal gtp_dedicated_div_clk   : std_logic := '1'; -- Tx buffer reference clock
    
    -- Rx Clock Data Recovery
    signal ch0_recovered_clk : std_logic; -- CH0 recovered clock
    signal ch1_recovered_clk : std_logic; -- CH1 recovered clock
    signal ch0_cdr_clk       : std_logic_vector (7 downto 0); -- CH0 parallel clock from CDR module
    signal ch1_cdr_clk       : std_logic_vector (7 downto 0); -- CH1 parallel clock from CDR module
    signal ch0_reset_serdes  : std_logic; -- Reset signal for SERDES primitives
    signal ch1_reset_serdes  : std_logic; -- Reset signal for SERDES primitives
    
    -- Tx CH0 serializer and encoder
    signal ch0_dis_out : std_logic_vector (1 downto 0); -- Disparity from encoder 
    signal ch0_frame_out : std_logic_vector (1 downto 0); --1 when a frame has been encoded
    signal ch0_encoded_data_p : std_logic_vector(19 downto 0); --  parallel encoded data
    signal ch0_encoded_data_aux : std_logic_vector(19 downto 0); --  parallel encoded data
    
    -- Tx CH1 serializer and encoder
    signal ch1_dis_out : std_logic_vector (1 downto 0); -- Disparity from encoder 
    signal ch1_frame_out : std_logic_vector (1 downto 0); --1 when a frame has been encoded
    signal ch1_encoded_data_p : std_logic_vector(19 downto 0); --  parallel encoded data
    signal ch1_encoded_data_aux : std_logic_vector(19 downto 0); --  parallel encoded data
    
    -- Rx CH0 deserializer and decoder
    signal ch0_frame_in_dec : std_logic; -- 1 when there is a frame ready to be decoded
    signal ch0_buffer_rx_data : std_logic_vector(19 downto 0); -- store the input data
    signal ch0_buffer_rx_aux : std_logic_vector(19 downto 0); -- store the input data
    signal ch0_rx_bitslide : std_logic_vector (4 downto 0); -- receiver bitslide
    signal ch0_rx_aligned : std_logic := '0'; -- 1 when the tx data stream is aligned
    signal ch0_clk_rx_gen : std_logic := '1'; -- CH0 rx recovered clock
    signal ch0_frame_out_dec : std_logic_vector (1 downto 0); -- 1 when there is a frame already decoded 
    signal ch0_dec_data : std_logic_vector(15 downto 0); --decoded data
    signal ch0_k_char : std_logic_vector (1 downto 0); --k char
    signal ch0_enc_err : std_logic_vector (1 downto 0); --error decoding     
    signal ch0_data_smp      : std_logic; -- Data sampled
    signal ch0_rd_en     : std_logic; -- Data sampled
    
    -- Rx CH1 deserializer and decoder
    signal ch1_frame_in_dec : std_logic; -- 1 when there is a frame ready to be decoded
    signal ch1_buffer_rx_data : std_logic_vector(19 downto 0); -- store the input data
    signal ch1_buffer_rx_aux : std_logic_vector(19 downto 0); -- store the input data
    signal ch1_rx_bitslide : std_logic_vector (4 downto 0); -- receiver bitslide
    signal ch1_rx_aligned : std_logic := '0'; -- 1 when the tx data stream is aligned
    signal ch1_clk_rx_gen : std_logic := '1'; -- CH0 rx recovered clock
    signal ch1_frame_out_dec : std_logic_vector (1 downto 0); -- 1 when there is a frame already decoded 
    signal ch1_dec_data : std_logic_vector(15 downto 0); --decoded data
    signal ch1_k_char : std_logic_vector (1 downto 0); -- k char
    signal ch1_enc_err : std_logic_vector (1 downto 0); --error decoding
    signal ch1_data_smp      : std_logic; -- Data sampled
    signal ch1_rd_en     : std_logic; -- Data sampled

    signal clk_cntr     : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal ch0_des_cntr : unsigned(4 downto 0) := to_unsigned(0, 5);
    signal ch1_des_cntr : unsigned(4 downto 0) := to_unsigned(0, 5);
    
      -- DO NOT DELETE DEBUG SIGNALS, NEEDED TO CORRECT SYNTHESIS
    signal debug0 : std_logic;
    signal debug1 : std_logic;
    signal debug2 : std_logic;
    signal debug3 : std_logic;
    signal debug4 : std_logic;
    signal debug5 : std_logic;
    signal debug_vector0 : std_logic_vector (19 downto 0);
    signal debug_vector1 : std_logic_vector (19 downto 0);
    signal debug_vector2 : std_logic_vector (15 downto 0);
    signal debug_vector3 : std_logic_vector (15 downto 0);
    attribute mark_debug : string;
    attribute mark_debug of ch0_enc_err: signal is "true";
    attribute mark_debug of debug1: signal is "true";
    attribute mark_debug of debug2: signal is "true";
    attribute mark_debug of ch0_buffer_rx_data: signal is "true";
    attribute mark_debug of debug3: signal is "true";
--    attribute mark_debug of debug_vector2 : signal is "true";
    attribute mark_debug of debug_vector3 : signal is "true";
    attribute mark_debug of ch0_buffer_rx_aux : signal is "true";
    attribute mark_debug of ch0_rx_aligned : signal is "true";
--    attribute mark_debug of debug_vector0 : signal is "true";
    attribute mark_debug of debug5: signal is "true";
    attribute mark_debug of debug4: signal is "true";
--    attribute mark_debug of i: signal is "true";
--    attribute mark_debug of j: signal is "true"; 
--    attribute mark_debug of z: signal is "true"; 
    attribute mark_debug of ch0_data_smp: signal is "true"; 
--    attribute mark_debug of ch0_reset_serdes: signal is "true";
    

begin

    debug2 <= ch0_data_i;
    debug4 <= gtp_clk_i;
    --debug5 <= cdr_clk_i;
    debug_vector2 <= ch0_tx_data_i;
    
    -- Inverted clock
    serdes_clk_n <= not serdes_clk_i;
    
    -- Output Tx clock  
    tx_out_clk_o <= gtp_clk_i;
     
---------------------- CH0 Tx flow ------------------------ 
     
    -- control the disp value and serialize the data
    ch0_serializer : process (ch0_frame_out, gtp_clk_i, rst_i)
    begin
    if (rst_i = '0') then
        ch0_encoded_data_aux  <= (others => '0'); 
        ch0_tx_disparity_o <= '0';   
    else       
        -- If there is an available frame, serialize it
        if rising_edge(gtp_clk_i) then
            ch0_data_o <= ch0_encoded_data_aux(19);
            debug5 <= ch0_encoded_data_aux(19);
            ch0_encoded_data_aux <= ch0_encoded_data_aux (18 downto 0) & "0";
            -- when a frame is coded, change the disparity and store the coded frame
            if ch0_frame_out(1) = '1' then
                ch0_tx_disparity_o <= ch0_dis_out(0) OR ch0_dis_out(1);
                ch0_encoded_data_aux <= ch0_encoded_data_p;  
            end if; 
        end if;   
    end if;
    end process;
    
--    debug_vector0 <= ch0_tx_data_i;
--    debug_vector1 <= ch0_tx_k_i;
--    debug0 <= ch0_frame_in_i;
    
    -- Encode the parallel frame from the core
    ch0_encoder : encode_8b10b_wrapper
      port map(
    
        CLK          => gtp_clk_i,  -- Reference clock 12.5MHz
        DIN          => ch0_tx_data_i (15 downto 8), -- Parallel Tx data
        KIN          => ch0_tx_k_i(1), -- Transmission control code
        DOUT         => ch0_encoded_data_p (19 downto 10), -- Output coded frame
    
        CE           => ch0_frame_in_i,
        FORCE_CODE   => '0', -- Input frame available
        FORCE_DISP   => '1',
        DISP_IN      => (ch0_dis_out(0) OR ch0_dis_out(1)),
        DISP_OUT     => ch0_dis_out(1), -- Output frame disparity
        ND           => ch0_frame_out(1), -- Output coded frame available
        KERR         => open,
    
        CLK_B        => gtp_clk_i,  -- Reference clock 12.5MHz
        DIN_B        => ch0_tx_data_i (7 downto 0), -- Parallel Tx data
        KIN_B        => ch0_tx_k_i(0), -- Transmission control code
        DOUT_B       => ch0_encoded_data_p (9 downto 0), -- Output coded frame
    
        CE_B         => ch0_frame_in_i,
        FORCE_CODE_B => '0', -- Input frame available
        FORCE_DISP_B => '1',
        DISP_IN_B    => (ch0_dis_out(0) OR ch0_dis_out(1)),
        DISP_OUT_B   => ch0_dis_out(0), -- Output frame disparity
        ND_B         => ch0_frame_out(0), -- Output coded frame available
        KERR_B       => open
    
        );
         
---------------------- CH1 Tx flow ------------------------  
    
    -- control the disp value and serialize the data
    ch1_serializer : process (ch1_frame_out, gtp_clk_i, rst_i)
    begin
    if (rst_i = '0') then
        ch1_encoded_data_aux  <= (others => '0'); 
        ch1_tx_disparity_o <= '0';   
    else
        -- If there is an available frame, serialize it
        if rising_edge(gtp_clk_i) then
            ch1_data_o <= ch1_encoded_data_aux(19);
            ch1_encoded_data_aux <= ch1_encoded_data_aux (18 downto 0) & "0";
            -- when a frame is coded, change the disparity and store the coded frame
            if ch1_frame_out(1) = '1' then
                ch1_tx_disparity_o <= ch1_dis_out(0) OR ch1_dis_out(1);
                ch1_encoded_data_aux <= ch1_encoded_data_p;  
            end if; 
        end if;   
    end if;
    end process;
    
    -- Encode the parallel frame from the core
    ch1_encoder : encode_8b10b_wrapper
      port map(
    
        CLK          => gtp_clk_i, -- Reference clock 12.5MHz
        DIN          => ch1_tx_data_i (15 downto 8), -- Parallel Tx data
        KIN          => ch1_tx_k_i(1), -- Transmission control code
        DOUT         => ch1_encoded_data_p (19 downto 10), -- Output coded frame
    
        CE           => ch1_frame_in_i,
        FORCE_CODE   => '0', -- Input frame available
        FORCE_DISP   => '1',
        DISP_IN      => (ch1_dis_out(0) OR ch1_dis_out(1)),
        DISP_OUT     => ch1_dis_out(1), -- Output frame disparity
        ND           => ch1_frame_out(1), -- Output coded frame available
        KERR         => open,
    
        CLK_B        => gtp_clk_i, -- Reference clock 12.5MHz
        DIN_B        => ch1_tx_data_i (7 downto 0), -- Parallel Tx data
        KIN_B        => ch1_tx_k_i(0), -- Transmission control code
        DOUT_B       => ch1_encoded_data_p (9 downto 0), -- Output coded frame
    
        CE_B         => ch1_frame_in_i,
        FORCE_CODE_B => '0', -- Input frame available
        FORCE_DISP_B => '1',
        DISP_IN_B    => (ch1_dis_out(0) OR ch1_dis_out(1)),
        DISP_OUT_B   => ch1_dis_out(0), -- Output frame disparity
        ND_B         => ch1_frame_out(0), -- Output coded frame available
        KERR_B       => open
    
        );


---------------------- Rx flow ------------------------

    rx_cdr : cdr_counter 
    port map( 
        gt0_data_i  => ch0_data_i,
        gt1_data_i  => ch1_data_i,
        ref_clk_i   => cdr_clk_i,
        rst_i       => rst_i,
        gt0_data_o  => ch0_data_smp,
        gt1_data_o  => ch1_data_smp,
        ch0_clk_o   => ch0_rx_rbclk_o,
        ch1_clk_o   => ch1_rx_rbclk_o
    ); 
    
---------------------- CH0 Rx flow ------------------------ 

    debug1 <= ch0_rec_clk_i;
    debug3 <= ch1_rec_clk_i;
     
    -- CH0 received data deserializer and decoder signalling controller
    ch0_deserializer : process(ch0_rec_clk_i, rst_i)
    begin
        if (rst_i = '0') then
            ch0_des_cntr <= to_unsigned(20, 5);
            ch0_buffer_rx_aux  <= (others => '0');
            ch0_buffer_rx_data  <= (others => '0');    
            ch0_rx_aligned <= '0';
            ch0_frame_in_dec <= '0';
            ch0_rx_bitslide_o <= (others => '0');
        else 
            -- Sampling point in the middle of the data period 
            if falling_edge(ch0_rec_clk_i) then
                -- Aux buffer saves each serial data transition
                ch0_buffer_rx_aux <= ch0_buffer_rx_aux (18 downto 0) & ch0_data_smp;
                -- Check if aligned comparing with the idle word
                if (ch0_buffer_rx_aux = "00111110100110110101" or ch0_buffer_rx_aux = "11000001011001000101"
                    or ch0_buffer_rx_aux = "00111110101011010101" or ch0_buffer_rx_aux = "11000001011010101010") then
                    -- if aligned we set the bitslide, the clock and the aux signals
                    ch0_rx_aligned <= '1';
                    ch0_rx_bitslide_o <= (others => '0'); --std_logic_vector(to_unsigned(19 - ch0_des_cntr, 5));
                    ch0_buffer_rx_data <= ch0_buffer_rx_aux;
                    ch0_frame_in_dec <= '1';
                    ch0_des_cntr <= to_unsigned(20, 5);
                elsif (ch0_buffer_rx_aux = "00000000000000000000" or ch0_buffer_rx_aux = "11111111111111111111"
                    or ch0_enc_err /= "00") then
                    ch0_rx_aligned <= '0';
                    ch0_rx_bitslide_o <= (others => '0');
                else
                    -- Generates the parallel clock (0.625 MHz)
                    if (ch0_des_cntr = to_unsigned(1, 5)) then
                        ch0_des_cntr <= to_unsigned(20, 5);
                        -- Check if the word period is aligned, if yes frame ready to decode
                        if ch0_rx_aligned = '1' then
                            ch0_frame_in_dec <= '1';
                            ch0_buffer_rx_data <= ch0_buffer_rx_aux;
                        end if;
                    else
                        ch0_frame_in_dec <= '0';
                        ch0_des_cntr <= ch0_des_cntr - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
   
    ch0_ready_o <= ch0_rx_aligned;

     ch0_decoder : decode_8b10b_wrapper 
      port map (
    
        CLK        => ch0_rec_clk_i, -- Recovered clock 12.5 MHz
        DIN        => ch0_buffer_rx_data (19 downto 10), -- Deserialized input data
--        DISP_IN    => '1',
        DOUT       => ch0_dec_data (15 downto 8), -- Decoded data
        KOUT       => ch0_k_char(1), -- Transmission control code
    
        CE         => ch0_frame_in_dec, -- Frame ready to be decoded
        SINIT      => '0',
        CODE_ERR   => ch0_enc_err(1), -- Error during decoding
        DISP_ERR   => open,
        ND         => ch0_frame_out_dec(1), -- Frame has been decoded
        RUN_DISP   => open,
        SYM_DISP   => open,
    
        CLK_B      => ch0_rec_clk_i, -- Recovered clock 12.5 MHz
        DIN_B      => ch0_buffer_rx_data (9 downto 0), -- Deserialized input data
--        DISP_IN_B  => '1',
        DOUT_B     => ch0_dec_data (7 downto 0), -- Decoded data
        KOUT_B     => ch0_k_char(0), -- Transmission control code
    
        CE_B       => ch0_frame_in_dec, -- Frame ready to be decoded
        SINIT_B    => '0',
        CODE_ERR_B => ch0_enc_err(0), -- Error during decoding
        DISP_ERR_B => open,
        ND_B       => ch0_frame_out_dec(0), -- Frame has been decoded
        RUN_DISP_B => open,
        SYM_DISP_B => open
    
        );
      
    -- Hold the decoder outputs until a new frame is decoded and manage SERDES resets  
    ch0_hold_data : process(ch0_frame_out_dec, rst_i)
    begin
        if (rst_i = '0') then
            ch0_rx_data_o <= (others => '0');  
            ch0_rx_enc_err_o <= '0';
            ch0_rx_k_o <= (others => '0');
            debug_vector3 <= (others => '0');
        else
            if rising_edge (ch0_frame_out_dec(1)) then
                ch0_rx_data_o <= ch0_dec_data;
                ch0_rx_enc_err_o <= ch0_enc_err(0) or ch0_enc_err(1);
                ch0_rx_k_o <= ch0_k_char;
                debug_vector3 <= ch0_dec_data;
            end if;
        end if;
    end process;
    
    
    -- Manage the reset of the SERDES
    ch0_reset_manager : process (cdr_clk_i, ch0_frame_out_dec, rst_i)
        variable counter : integer := 0;
        begin
            if (rst_i = '0') then
                ch0_reset_serdes <= not rst_i;
                counter := 0;
            else
                -- if there are 1000 transtions without data
                if rising_edge (cdr_clk_i) then
                    counter := counter + 1;
                    if counter = 1000 then
                        ch0_reset_serdes <= '1';
                        counter := 0;
                    else
                        if ch0_frame_out_dec(1) = '1' then
                            counter := 0;
                        end if;
                    ch0_reset_serdes <= '0';
                    end if;
                end if;
            end if;
    end process;
    
---------------------- CH1 Rx flow ------------------------ 
         
    -- CH1 received data deserializer and decoder signalling controller
    ch1_deserializer : process(ch1_rec_clk_i, rst_i)
    begin
        if (rst_i = '0') then
            ch1_des_cntr <= to_unsigned(20, 5);
            ch1_buffer_rx_aux  <= (others => '0');
            ch1_buffer_rx_data  <= (others => '0');    
            ch1_rx_aligned <= '0';
            ch1_frame_in_dec <= '0';
            ch1_rx_bitslide_o <= (others => '0');
        else 
            -- Sampling point in the middle of the data period 
            if falling_edge(ch1_rec_clk_i) then
                -- Aux buffer saves each serial data transition
                ch1_buffer_rx_aux <= ch1_buffer_rx_aux (18 downto 0) & ch1_data_smp;
                -- Check if aligned comparing with the idle word
                if (ch1_buffer_rx_aux = "00111110101011010010" or ch1_buffer_rx_aux = "00111110100111001001"
                    or ch1_buffer_rx_aux = "11000001010100101101" or ch1_buffer_rx_aux = "11000001010111001001") then
                    -- if aligned we set the bitslide, the clock and the aux signals
                    ch1_rx_aligned <= '1';
                    ch1_rx_bitslide_o <= (others => '0'); --std_logic_vector(to_unsigned(19 - ch1_des_cntr, 5));
                    ch1_buffer_rx_data <= ch1_buffer_rx_aux;
                    ch1_frame_in_dec <= '1';
                    ch1_des_cntr <= to_unsigned(20, 5);
                elsif (ch1_buffer_rx_aux = "00000000000000000000" or ch1_buffer_rx_aux = "11111111111111111111"
                    or ch1_enc_err /= "00") then
                    ch1_rx_aligned <= '0';
                    ch1_rx_bitslide_o <= (others => '0');
                else
                    -- Generates the parallel clock (0.625 MHz)
                    if (ch1_des_cntr = to_unsigned(1, 5)) then
                        ch1_des_cntr <= to_unsigned(20, 5);
                        -- Check if the word period is aligned, if yes frame ready to decode
                        if ch1_rx_aligned = '1' then
                            ch1_frame_in_dec <= '1';
                            ch1_buffer_rx_data <= ch1_buffer_rx_aux;
                        end if;
                    else
                        ch1_frame_in_dec <= '0';
                        ch1_des_cntr <= ch1_des_cntr - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    ch1_ready_o <= ch1_rx_aligned;
                          
    ch1_decoder : decode_8b10b_wrapper 
     port map (
   
       CLK        => ch1_rec_clk_i, -- Recovered clock 12.5 MHz
       DIN        => ch1_buffer_rx_data (19 downto 10), -- Deserialized input data
       DOUT       => ch1_dec_data (15 downto 8), -- Decoded data
       KOUT       => ch1_k_char(1), -- Transmission control code
   
       CE         => ch1_frame_in_dec, -- Frame ready to be decoded
       SINIT      => '0',
       CODE_ERR   => ch1_enc_err(1), -- Error during decoding
       DISP_ERR   => open,
       ND         => ch1_frame_out_dec(1), -- Frame has been decoded
       RUN_DISP   => open,
       SYM_DISP   => open,
   
       CLK_B      => ch1_rec_clk_i, -- Recovered clock 12.5 MHz
       DIN_B      => ch1_buffer_rx_data (9 downto 0), -- Deserialized input data
       DOUT_B     => ch1_dec_data (7 downto 0), -- Decoded data
       KOUT_B     => ch1_k_char(0), -- Transmission control code
   
       CE_B       => ch1_frame_in_dec, -- Frame ready to be decoded
       SINIT_B    => '0',
       CODE_ERR_B => ch1_enc_err(0), -- Error during decoding
       DISP_ERR_B => open,
       ND_B       => ch1_frame_out_dec(0), -- Frame has been decoded
       RUN_DISP_B => open,
       SYM_DISP_B => open
   
       );      
          
    -- Hold the decoder outputs until a new frame is decoded and manage SERDES resets  
      ch1_hold_data : process(ch1_frame_out_dec, rst_i)
      begin
          if (rst_i = '0') then
              ch1_rx_data_o <= (others => '0');  
              ch1_rx_enc_err_o <= '0';
              ch1_rx_k_o <= (others => '0');
          else
              if rising_edge (ch1_frame_out_dec(1)) then
                  ch1_rx_data_o <= ch1_dec_data;
                  ch1_rx_enc_err_o <= ch1_enc_err(0) or ch1_enc_err(1);
                  ch1_rx_k_o <= ch1_k_char;
              end if;
          end if;
      end process;
      
      -- Manage the reset of the SERDES
      ch1_reset_manager : process (cdr_clk_i, ch1_frame_out_dec, rst_i)
      variable counter : integer := 0;
      begin
          if (rst_i = '0') then
              ch1_reset_serdes <= not rst_i;
              counter := 0;
          else
            -- if there are 1000 transtions without data
              if rising_edge (cdr_clk_i) then
                  counter := counter + 1;
                  if counter = 1000 then
                      ch1_reset_serdes <= '1';
                      counter := 0;
                  else
                      if ch1_frame_out_dec(1) = '1' then
                          counter := 0;
                      end if;
                  ch1_reset_serdes <= '0';
                  end if;
              end if;
          end if;
      end process;
    
end Behavioral;
