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
    generic (
-- number of bits for edge counter
    g_num_bits_cnt  : natural := 10;
-- max value of the counter 
    g_max_value     : natural := 1000;
-- max value of the counter 
    g_half_trans    : natural := 40;
-- max value of the counter 
    g_full_trans    : natural := 80    
    );

    Port ( ch0_data_i  : in STD_LOGIC_VECTOR (7 downto 0);
           ch1_data_i  : in STD_LOGIC_VECTOR (7 downto 0);
           ref_clk_i   : in STD_LOGIC;
           rst_i       : in STD_LOGIC;
           ch0_clk_i   : in STD_LOGIC;
           ch1_clk_i   : in STD_LOGIC;
           ch0_clk_o   : out STD_LOGIC_VECTOR (7 downto 0);
           ch1_clk_o   : out STD_LOGIC_VECTOR (7 downto 0);
           ch0_data_o  : out STD_LOGIC;
           ch1_data_o  : out STD_LOGIC;
           ch0_rd_en_o : out STD_LOGIC;
           ch1_rd_en_o : out STD_LOGIC
           ); 
end cdr_counter;

architecture struct of cdr_counter is

    component cdr_fifo is
        Generic (
            constant FIFO_DEPTH	: positive := 20
        );
        Port ( 
            CLK		: in  STD_LOGIC;
            RST		: in  STD_LOGIC;
            WriteEn	: in  STD_LOGIC;
            DataIn	: in  STD_LOGIC;
            ReadEn	: in  STD_LOGIC;
            DataOut	: out STD_LOGIC;
            Empty	: out STD_LOGIC;
            Full	: out STD_LOGIC
        );
    end component cdr_fifo;

    signal ch0_half_trans     : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(g_half_trans, g_num_bits_cnt);
    signal ch1_half_trans     : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(g_half_trans, g_num_bits_cnt);
    signal ch0_full_trans     : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(g_full_trans, g_num_bits_cnt);
    signal ch1_full_trans     : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(g_full_trans, g_num_bits_cnt);
    signal ch0_var_cntr       : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal ch1_var_cntr       : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal ch0_var_cntr1      : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal ch1_var_cntr1      : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal ch0_aux_clk        : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_clk        : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_clk1       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_clk1       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_clk2       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_clk2       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_data1       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_data2       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_data3       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch0_aux_data4       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_data        : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_data1        : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_data2       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_data3       : std_logic_vector (7 downto 0) := (others => '0');
    signal ch1_aux_data4       : std_logic_vector (7 downto 0) := (others => '0');
    
    signal ch0_var_trans      : std_logic_vector (1 downto 0) := (others => '0');
    signal ch1_var_trans      : std_logic_vector (1 downto 0) := (others => '0');
    signal ch0_var_trans1     : std_logic_vector (1 downto 0) := (others => '0');
    signal ch1_var_trans1     : std_logic_vector (1 downto 0) := (others => '0');
    signal ch0_var_trans_aux  : std_logic_vector (1 downto 0) := (others => '0');
    signal ch1_var_trans_aux  : std_logic_vector (1 downto 0) := (others => '0');
    
    signal ch0_var_flag0  : std_logic := '0'; 
    signal ch0_var_flag1  : std_logic := '0';
    signal ch0_var_flag2  : std_logic := '0';
    signal ch0_var_flag3  : std_logic := '0';
    signal ch0_var_flag4  : std_logic := '0';
    signal ch0_var_flag5  : std_logic := '0';
    signal ch0_var_flag6  : std_logic := '0';
    signal ch0_var_flag7  : std_logic := '0';
    signal ch0_cntr_0  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_1  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_2  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_3  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_4  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_5  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_6  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_cntr_7  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch0_var_flag_med0  : std_logic := '0';
    signal ch0_var_flag_med1  : std_logic := '0';
    signal ch0_var_flag_med2  : std_logic := '0';
    signal ch0_var_flag_med3  : std_logic := '0';
    signal ch0_var_flag_med4  : std_logic := '0';
    signal ch0_var_flag_med5  : std_logic := '0';
    signal ch0_var_flag_med6  : std_logic := '0';
    signal ch0_var_flag_med7  : std_logic := '0';
    
    signal ch1_var_flag0  : std_logic := '0'; 
    signal ch1_var_flag1  : std_logic := '0';
    signal ch1_var_flag2  : std_logic := '0';
    signal ch1_var_flag3  : std_logic := '0';
    signal ch1_var_flag4  : std_logic := '0';
    signal ch1_var_flag5  : std_logic := '0';
    signal ch1_var_flag6  : std_logic := '0';
    signal ch1_var_flag7  : std_logic := '0';
    signal ch1_cntr_0  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_1  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_2  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_3  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_4  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_5  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_6  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_cntr_7  : unsigned(g_num_bits_cnt-1 downto 0) := to_unsigned(0, g_num_bits_cnt);
    signal ch1_var_flag_med0  : std_logic := '0';
    signal ch1_var_flag_med1  : std_logic := '0';
    signal ch1_var_flag_med2  : std_logic := '0';
    signal ch1_var_flag_med3  : std_logic := '0';
    signal ch1_var_flag_med4  : std_logic := '0';
    signal ch1_var_flag_med5  : std_logic := '0';
    signal ch1_var_flag_med6  : std_logic := '0';
    signal ch1_var_flag_med7  : std_logic := '0';
    
    signal ch0_nbits     : integer := 0;
    signal ch0_nbits_aux : integer := 0;
    signal ch0_cntr      : integer := 0;
    signal ch0_edge_flag : integer := 0;
    signal ch0_head      : integer := 0;
    signal ch0_bit_value : std_logic := '0';
    signal ch0_bit_value_aux : std_logic := '0';
    signal ch0_clk1      : std_logic := '0';
    signal ch0_clk2      : std_logic := '0';
    signal ch0_fifo_wr   : std_logic := '0';
    signal ch0_fifo_rd   : std_logic := '0';
    signal ch0_fifo_rd1   : std_logic := '0';
    signal ch0_fifo_rd2   : std_logic := '0';
    signal ch0_rd_aux   : std_logic := '0';
    signal ch0_fifo_data   : std_logic := '0';
    
    signal ch1_nbits     : integer := 0;
    signal ch1_nbits_aux : integer := 0;
    signal ch1_cntr      : integer := 0;
    signal ch1_edge_flag : integer := 0;
    signal ch1_head      : integer := 0;
    signal ch1_bit_value : std_logic := '0';
    signal ch1_bit_value_aux : std_logic := '0';
    signal ch1_clk1      : std_logic := '0';
    signal ch1_clk2      : std_logic := '0';
    signal ch1_fifo_wr   : std_logic := '0';
    signal ch1_fifo_rd   : std_logic := '0';
    signal ch1_fifo_rd1   : std_logic := '0';
    signal ch1_fifo_rd2   : std_logic := '0';
    signal ch1_rd_aux   : std_logic := '0';
    signal ch1_fifo_data   : std_logic := '0';

    
begin

    -- CH0 CDR
    clk_cntr_ch0 : process (ref_clk_i, rst_i, ch0_data_i)
    
    begin
      -- if there is a reset, the counter and the clock are initialized
      if(rst_i = '0') then
        ch0_var_cntr <= to_unsigned(0, 4);
        ch0_var_trans <= (others => '0');
        ch0_var_trans1 <= (others => '0');
        ch0_var_trans_aux <= (others => '0');
        ch0_aux_data1 <= (others => '0');
        ch0_aux_data2 <= (others => '0');
        ch0_aux_data3 <= (others => '0');
        ch0_aux_data4 <= (others => '0');
      else
        -- each deserialized frame
        if rising_edge(ref_clk_i) then
            -- check the incoming edges, avoid electrical rebounds   
            if (ch0_aux_data4(7) /= ch0_aux_data1(0) and ch0_data_i(7) = ch0_aux_data2(0)
                and ch0_aux_data1(0) = ch0_aux_data1(7) and ch0_var_trans_aux(0) = ch0_aux_data2(0)) then
                case ch0_aux_data2 is
                    -- Assign a transition value depending on the received data
                    when "11111111" =>
                        if ch0_aux_data3(0) = '0' then
                            ch0_var_cntr <= to_unsigned(8, 4);
                            ch0_var_trans <= "10";
                            ch0_var_trans_aux <= "10";
                        else
                            ch0_var_cntr <= to_unsigned(0, 4);
                            ch0_var_trans <= "00";
                            ch0_var_trans_aux <= "10";
                        end if;
                    when "11111110" =>
                        ch0_var_cntr <= to_unsigned(1, 4); 
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "11111100" =>
                        ch0_var_cntr <= to_unsigned(2, 4); 
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "11111000" =>
                        ch0_var_cntr <= to_unsigned(3, 4);
                        ch0_var_trans <= "01"; 
                        ch0_var_trans_aux <= "01";
                    when "11110000" =>
                        ch0_var_cntr <= to_unsigned(4, 4);
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "11100000" =>
                        ch0_var_cntr <= to_unsigned(5, 4);
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "11000000" =>
                        ch0_var_cntr <= to_unsigned(6, 4);
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "10000000" =>
                        ch0_var_cntr <= to_unsigned(7, 4);
                        ch0_var_trans <= "01";
                        ch0_var_trans_aux <= "01";
                    when "00000000" =>
                        if ch0_aux_data3(0) = '1' then
                            ch0_var_cntr <= to_unsigned(8, 4);
                            ch0_var_trans <= "01";
                        else
                            ch0_var_cntr <= to_unsigned(0, 4);
                            ch0_var_trans <= "00";
                            ch0_var_trans_aux <= "01";
                        end if;
                    when "00000001" =>
                        ch0_var_cntr <= to_unsigned(1, 4); 
                        ch0_var_trans <= "10";
                        ch0_var_trans_aux <= "10";
                    when "00000011" =>
                        ch0_var_cntr <= to_unsigned(2, 4);
                        ch0_var_trans <= "10"; 
                        ch0_var_trans_aux <= "10";
                    when "00000111" =>
                        ch0_var_cntr <= to_unsigned(3, 4);
                        ch0_var_trans <= "10"; 
                        ch0_var_trans_aux <= "10";
                    when "00001111" =>
                        ch0_var_cntr <= to_unsigned(4, 4);
                        ch0_var_trans <= "10";
                        ch0_var_trans_aux <= "10";
                    when "00011111" =>
                        ch0_var_cntr <= to_unsigned(5, 4);
                        ch0_var_trans <= "10";
                        ch0_var_trans_aux <= "10";
                    when "00111111" =>
                        ch0_var_cntr <= to_unsigned(6, 4);
                        ch0_var_trans <= "10";
                        ch0_var_trans_aux <= "10";
                    when "01111111" =>
                        ch0_var_cntr <= to_unsigned(7, 4);
                        ch0_var_trans <= "10";
                        ch0_var_trans_aux <= "10";
                    when others => 
                        ch0_var_cntr <= to_unsigned(0, 4);
                        ch0_var_trans <= "00";
                end case;
            else
                ch0_var_cntr <= to_unsigned(0, 4);
                ch0_var_trans <= "00";
            end if;
            -- store the data state
            ch0_aux_data1 <= ch0_data_i;
            ch0_aux_data2 <= ch0_aux_data1;
            ch0_aux_data3 <= ch0_aux_data2;
            ch0_aux_data4 <= ch0_aux_data3;
            ch0_var_trans1 <= ch0_var_trans;
            ch0_var_cntr1 <= ch0_var_cntr;
        end if;
      end if;
    end process;


    ch0_trans_gen_0 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_0 > 1000) then
            ch0_var_flag0 <= '0';
            ch0_var_flag_med0 <= '0';
            ch0_cntr_0 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a half or a full cycle in ns 0    
                    if ((ch0_cntr_0 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag0 <= '1';
                    elsif ((ch0_cntr_0 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med0 <= '1';
                    else
                        ch0_var_flag0 <= '0';
                        ch0_var_flag_med0 <= '0';
                    end if;
                    -- Update the counter
                    ch0_cntr_0 <= ch0_cntr_0 + ch0_var_cntr + 8;
                else
                    ch0_var_flag0 <= '0';
                    ch0_var_flag_med0 <= '0';
                    ch0_cntr_0 <= to_unsigned(0, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_1 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_1 > 1000) then
            ch0_var_flag1 <= '0';
            ch0_var_flag_med1 <= '0';
            ch0_cntr_1 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_1 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag1 <= '1';
                    elsif ((ch0_cntr_1 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med1 <= '1';
                    else
                        ch0_var_flag1 <= '0';
                        ch0_var_flag_med1 <= '0';
                    end if;
                    ch0_cntr_1 <= ch0_cntr_1 + ch0_var_cntr + 8;
                else
                    ch0_var_flag1 <= '0';
                    ch0_var_flag_med1 <= '0';
                    ch0_cntr_1 <= to_unsigned(1, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_2 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_2 > 1000) then
            ch0_var_flag2 <= '0';
            ch0_var_flag_med2 <= '0';
            ch0_cntr_2 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_2 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag2 <= '1';
                    elsif ((ch0_cntr_2 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med2 <= '1';
                    else
                        ch0_var_flag2 <= '0';
                        ch0_var_flag_med2 <= '0';
                    end if;
                    ch0_cntr_2 <= ch0_cntr_2 + ch0_var_cntr + 8;
                else
                    ch0_var_flag2 <= '0';
                    ch0_var_flag_med2 <= '0';
                    ch0_cntr_2 <= to_unsigned(2, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_3 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_3 > 1000) then
            ch0_var_flag3 <= '0';
            ch0_var_flag_med3 <= '0';
            ch0_cntr_3 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_3 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag3 <= '1';
                    elsif ((ch0_cntr_3 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med3 <= '1';
                    else
                        ch0_var_flag3 <= '0';
                        ch0_var_flag_med3 <= '0';
                    end if;
                    ch0_cntr_3 <= ch0_cntr_3 + ch0_var_cntr + 8;
                else
                    ch0_var_flag3 <= '0';
                    ch0_var_flag_med3 <= '0';
                    ch0_cntr_3 <= to_unsigned(3, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_4 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_4 > 1000) then
            ch0_var_flag4 <= '0';
            ch0_var_flag_med4 <= '0';
            ch0_cntr_4 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_4 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag4 <= '1';
                    elsif ((ch0_cntr_4 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med4 <= '1';
                    else
                        ch0_var_flag4 <= '0';
                        ch0_var_flag_med4 <= '0';
                    end if;
                    ch0_cntr_4 <= ch0_cntr_4 + ch0_var_cntr + 8;
                else
                    ch0_var_flag4 <= '0';
                    ch0_var_flag_med4 <= '0';
                    ch0_cntr_4 <= to_unsigned(4, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_5 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_5 > 1000) then
            ch0_var_flag5 <= '0';
            ch0_var_flag_med5 <= '0';
            ch0_cntr_5 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_5 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag5 <= '1';
                    elsif ((ch0_cntr_5 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med5 <= '1';
                    else
                        ch0_var_flag5 <= '0';
                        ch0_var_flag_med5 <= '0';
                    end if;
                    ch0_cntr_5 <= ch0_cntr_5 + ch0_var_cntr + 8;
                else
                    ch0_var_flag5 <= '0';
                    ch0_var_flag_med5 <= '0';
                    ch0_cntr_5 <= to_unsigned(5, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_6 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0'or ch0_cntr_6 > 1000) then
            ch0_var_flag6 <= '0';
            ch0_var_flag_med6 <= '0';
            ch0_cntr_6 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_6 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag6 <= '1';
                    elsif ((ch0_cntr_6 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med6 <= '1';
                    else
                        ch0_var_flag6 <= '0';
                        ch0_var_flag_med6 <= '0';
                    end if;
                    ch0_cntr_6 <= ch0_cntr_6 + ch0_var_cntr + 8;
                else
                    ch0_var_flag6 <= '0';
                    ch0_var_flag_med6 <= '0';
                    ch0_cntr_6 <= to_unsigned(6, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch0_trans_gen_7 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch0_cntr_7 > 1000) then
            ch0_var_flag7 <= '0';
            ch0_var_flag_med7 <= '0';
            ch0_cntr_7 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch0_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch0_cntr_7 rem ch0_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch0_var_flag7 <= '1';
                    elsif ((ch0_cntr_7 rem ch0_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch0_aux_clk(0) = '1' then
                            ch0_var_flag_med7 <= '1';
                    else
                        ch0_var_flag7 <= '0';
                        ch0_var_flag_med7 <= '0';
                    end if;
                    ch0_cntr_7 <= ch0_cntr_7 + ch0_var_cntr + 8;
                else
                    ch0_var_flag7 <= '0';
                    ch0_var_flag_med7 <= '0';
                    ch0_cntr_7 <= to_unsigned(7, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;

    clk_gen_ch0 : process (ref_clk_i, rst_i)
                
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0') then
            ch0_aux_clk       <= (others => '0');
            ch0_nbits <= 0;
            ch0_cntr  <= 0;
            ch0_bit_value <= '0';
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- if there is a transition on the received data
                case ch0_var_trans1 is
                    when "01" => 
                        -- Set the output recovered clock
                        if ch0_aux_clk(0) = '0' then
                            ch0_aux_clk  <= not (ch0_aux_data4);
                        else
                            ch0_aux_clk <= "11111111";
                        end if;
                        -- Check how many bits without transition
                        if (ch0_cntr < 40) then
                            ch0_nbits <= 0;
                        elsif (ch0_cntr >= 40 and ch0_cntr < 120) then
                            ch0_nbits <= 1;
                        elsif (ch0_cntr >= 120 and ch0_cntr < 200) then
                            ch0_nbits <= 2;
                        elsif (ch0_cntr >= 200 and ch0_cntr < 280) then
                            ch0_nbits <= 3;
                        elsif (ch0_cntr >= 280 and ch0_cntr < 360) then
                            ch0_nbits <= 4;
                        else
                            ch0_nbits <= 5;
                        end if;
                        ch0_cntr <= to_integer(ch0_var_cntr1);
                        ch0_bit_value <= '1';
                    when "10" =>
                        if ch0_aux_clk(0) = '0' then
                            ch0_aux_clk  <= ch0_aux_data4;
                        else
                            ch0_aux_clk <= "11111111";
                        end if;
                        if (ch0_cntr < 40) then
                            ch0_nbits <= 0;
                        elsif (ch0_cntr >= 40 and ch0_cntr < 120) then
                            ch0_nbits <= 1;
                        elsif (ch0_cntr >= 120 and ch0_cntr < 200) then
                            ch0_nbits <= 2;
                        elsif (ch0_cntr >= 200 and ch0_cntr < 280) then
                            ch0_nbits <= 3;
                        elsif (ch0_cntr >= 280 and ch0_cntr < 360) then
                            ch0_nbits <= 4;
                        else
                            ch0_nbits <= 5;
                        end if;
                        ch0_cntr <= to_integer(ch0_var_cntr1);
                        ch0_bit_value <= '0';
                    when others =>   
                        if    ch0_var_flag0 = '1' then ch0_aux_clk <= "11111111"; 
                        elsif ch0_var_flag1 = '1' then ch0_aux_clk <= "01111111";
                        elsif ch0_var_flag2 = '1' then ch0_aux_clk <= "00111111";
                        elsif ch0_var_flag3 = '1' then ch0_aux_clk <= "00011111";
                        elsif ch0_var_flag4 = '1' then ch0_aux_clk <= "00001111";
                        elsif ch0_var_flag5 = '1' then ch0_aux_clk <= "00000111";
                        elsif ch0_var_flag6 = '1' then ch0_aux_clk <= "00000011";
                        elsif ch0_var_flag7 = '1' then ch0_aux_clk <= "00000001";
                        elsif ch0_var_flag_med0 = '1' then ch0_aux_clk <= "00000000";
                        elsif ch0_var_flag_med1 = '1' then ch0_aux_clk <= "10000000";
                        elsif ch0_var_flag_med2 = '1' then ch0_aux_clk <= "11000000";
                        elsif ch0_var_flag_med3 = '1' then ch0_aux_clk <= "11100000";
                        elsif ch0_var_flag_med4 = '1' then ch0_aux_clk <= "11110000";
                        elsif ch0_var_flag_med5 = '1' then ch0_aux_clk <= "11111000";
                        elsif ch0_var_flag_med6 = '1' then ch0_aux_clk <= "11111100";
                        elsif ch0_var_flag_med7 = '1' then ch0_aux_clk <= "11111110";
                        elsif ch0_aux_clk(0) = '0' then ch0_aux_clk <= "00000000";
                        elsif ch0_aux_clk(0) = '1' then ch0_aux_clk <= "11111111";
                        end if;
                        ch0_cntr <= ch0_cntr + 8;
                end case;
--                ch0_aux_clk1 <= ch0_aux_clk;
--                ch0_aux_clk2 <= ch0_aux_clk1;
                ch0_clk_o <= ch0_aux_clk;
            end if; 
        end if;
    end process;      
    
    data_smpl_ch0 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0') then
            ch0_edge_flag <= 0;
            ch0_nbits_aux <= 0;
            ch0_bit_value_aux <= '0';
            ch0_fifo_data <= '0';
            ch0_fifo_wr <= '0';
            ch0_fifo_rd <= '0';
            ch0_fifo_rd1 <= '0';
            ch0_fifo_rd2 <= '0';
            ch0_rd_aux <= '0';
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- Write the calculated number of bits without transition
                if (ch0_nbits_aux > ch0_edge_flag) then
                    ch0_fifo_data <= ch0_bit_value;
                    ch0_edge_flag <= ch0_edge_flag + 1;
                    ch0_fifo_wr <= '1';
                else
                    ch0_fifo_wr <= '0';
                end if;
                if (ch0_bit_value /= ch0_bit_value_aux) then
                    ch0_edge_flag <= 0;
                end if;
                -- Read each transition on the 12.5 MHz clock
                if (ch0_clk_i = '1' and ch0_clk1 = '1' and ch0_clk2 = '1' and ch0_rd_aux = '0'
                    and ch0_fifo_rd = '0' and ch0_fifo_rd1 = '0' and ch0_fifo_rd2 = '0') then
                    ch0_fifo_rd <= '1';
                    ch0_rd_aux <= '1';
                elsif (ch0_clk_i = '0' and ch0_clk1 = '0' and ch0_clk2 = '0') then
                    ch0_rd_aux <= '0';
                else
                    ch0_fifo_rd <= '0';
                end if;
                ch0_bit_value_aux <= ch0_bit_value;
                ch0_clk1 <= ch0_clk_i;
                ch0_clk2 <= ch0_clk1;
                ch0_nbits_aux <= ch0_nbits;
                ch0_rd_en_o <= ch0_fifo_rd;
                ch0_fifo_rd1 <= ch0_fifo_rd;
                ch0_fifo_rd2 <= ch0_fifo_rd1;
            end if;
        end if;
    end process;
    
    -- FIFO to store the data stream and desacoplate frequencies
    ch0_sampled_data_fifo: cdr_fifo
    PORT MAP (
        CLK        => ref_clk_i,
        RST        => not(rst_i),
        DataIn    => ch0_fifo_data,
        WriteEn    => ch0_fifo_wr,
        ReadEn    => ch0_fifo_rd,
        DataOut    => ch0_data_o,
        Full    => open,
        Empty    => open
    );
    
    
-- CH1 CDR
    clk_cntr_ch1 : process (ref_clk_i, rst_i, ch1_data_i)
    
    begin
      -- if there is a reset, the counter and the clock are initialized
      if(rst_i = '0') then
        ch1_var_cntr <= to_unsigned(0, 4);
        ch1_var_trans <= (others => '0');
        ch1_var_trans1 <= (others => '0');
        ch1_var_trans_aux <= (others => '0');
        ch1_aux_data1 <= (others => '0');
        ch1_aux_data2 <= (others => '0');
        ch1_aux_data3 <= (others => '0');
        ch1_aux_data4 <= (others => '0');
      else
        -- each deserialized frame
        if rising_edge(ref_clk_i) then
            -- check the incoming data    
            if (ch1_aux_data4(7) /= ch1_aux_data1(0) and ch1_data_i(7) = ch1_aux_data2(0)
                and ch1_aux_data1(0) = ch1_aux_data1(7) and ch1_var_trans_aux(0) = ch1_aux_data2(0)) then
                case ch1_aux_data2 is
                    when "11111111" =>
                        if ch1_aux_data3(0) = '0' then
                            ch1_var_cntr <= to_unsigned(8, 4);
                            ch1_var_trans <= "10";
                            ch1_var_trans_aux <= "10";
                        else
                            ch1_var_cntr <= to_unsigned(0, 4);
                            ch1_var_trans <= "00";
                            ch1_var_trans_aux <= "10";
                        end if;
                    when "11111110" =>
                        ch1_var_cntr <= to_unsigned(1, 4); 
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "11111100" =>
                        ch1_var_cntr <= to_unsigned(2, 4); 
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "11111000" =>
                        ch1_var_cntr <= to_unsigned(3, 4);
                        ch1_var_trans <= "01"; 
                        ch1_var_trans_aux <= "01";
                    when "11110000" =>
                        ch1_var_cntr <= to_unsigned(4, 4);
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "11100000" =>
                        ch1_var_cntr <= to_unsigned(5, 4);
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "11000000" =>
                        ch1_var_cntr <= to_unsigned(6, 4);
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "10000000" =>
                        ch1_var_cntr <= to_unsigned(7, 4);
                        ch1_var_trans <= "01";
                        ch1_var_trans_aux <= "01";
                    when "00000000" =>
                        if ch1_aux_data3(0) = '1' then
                            ch1_var_cntr <= to_unsigned(8, 4);
                            ch1_var_trans <= "01";
                        else
                            ch1_var_cntr <= to_unsigned(0, 4);
                            ch1_var_trans <= "00";
                            ch1_var_trans_aux <= "01";
                        end if;
                    when "00000001" =>
                        ch1_var_cntr <= to_unsigned(1, 4); 
                        ch1_var_trans <= "10";
                        ch1_var_trans_aux <= "10";
                    when "00000011" =>
                        ch1_var_cntr <= to_unsigned(2, 4);
                        ch1_var_trans <= "10"; 
                        ch1_var_trans_aux <= "10";
                    when "00000111" =>
                        ch1_var_cntr <= to_unsigned(3, 4);
                        ch1_var_trans <= "10"; 
                        ch1_var_trans_aux <= "10";
                    when "00001111" =>
                        ch1_var_cntr <= to_unsigned(4, 4);
                        ch1_var_trans <= "10";
                        ch1_var_trans_aux <= "10";
                    when "00011111" =>
                        ch1_var_cntr <= to_unsigned(5, 4);
                        ch1_var_trans <= "10";
                        ch1_var_trans_aux <= "10";
                    when "00111111" =>
                        ch1_var_cntr <= to_unsigned(6, 4);
                        ch1_var_trans <= "10";
                        ch1_var_trans_aux <= "10";
                    when "01111111" =>
                        ch1_var_cntr <= to_unsigned(7, 4);
                        ch1_var_trans <= "10";
                        ch1_var_trans_aux <= "10";
                    when others => 
                        ch1_var_cntr <= to_unsigned(0, 4);
                        ch1_var_trans <= "00";
                end case;
            else
                ch1_var_cntr <= to_unsigned(0, 4);
                ch1_var_trans <= "00";
            end if;
            -- store the data state
            ch1_aux_data1 <= ch1_data_i;
            ch1_aux_data2 <= ch1_aux_data1;
            ch1_aux_data3 <= ch1_aux_data2;
            ch1_aux_data4 <= ch1_aux_data3;
            ch1_var_trans1 <= ch1_var_trans;
            ch1_var_cntr1 <= ch1_var_cntr;
        end if;
      end if;
    end process;


    ch1_trans_gen_0 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_0 > 1000) then
            ch1_var_flag0 <= '0';
            ch1_var_flag_med0 <= '0';
            ch1_cntr_0 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_0 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag0 <= '1';
                    elsif ((ch1_cntr_0 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med0 <= '1';
                    else
                        ch1_var_flag0 <= '0';
                        ch1_var_flag_med0 <= '0';
                    end if;
                    ch1_cntr_0 <= ch1_cntr_0 + ch1_var_cntr + 8;
                else
                    ch1_var_flag0 <= '0';
                    ch1_var_flag_med0 <= '0';
                    ch1_cntr_0 <= to_unsigned(0, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_1 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_1 > 1000) then
            ch1_var_flag1 <= '0';
            ch1_var_flag_med1 <= '0';
            ch1_cntr_1 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_1 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag1 <= '1';
                    elsif ((ch1_cntr_1 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med1 <= '1';
                    else
                        ch1_var_flag1 <= '0';
                        ch1_var_flag_med1 <= '0';
                    end if;
                    ch1_cntr_1 <= ch1_cntr_1 + ch1_var_cntr + 8;
                else
                    ch1_var_flag1 <= '0';
                    ch1_var_flag_med1 <= '0';
                    ch1_cntr_1 <= to_unsigned(1, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_2 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_2 > 1000) then
            ch1_var_flag2 <= '0';
            ch1_var_flag_med2 <= '0';
            ch1_cntr_2 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_2 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag2 <= '1';
                    elsif ((ch1_cntr_2 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med2 <= '1';
                    else
                        ch1_var_flag2 <= '0';
                        ch1_var_flag_med2 <= '0';
                    end if;
                    ch1_cntr_2 <= ch1_cntr_2 + ch1_var_cntr + 8;
                else
                    ch1_var_flag2 <= '0';
                    ch1_var_flag_med2 <= '0';
                    ch1_cntr_2 <= to_unsigned(2, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_3 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_3 > 1000) then
            ch1_var_flag3 <= '0';
            ch1_var_flag_med3 <= '0';
            ch1_cntr_3 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_3 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag3 <= '1';
                    elsif ((ch1_cntr_3 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med3 <= '1';
                    else
                        ch1_var_flag3 <= '0';
                        ch1_var_flag_med3 <= '0';
                    end if;
                    ch1_cntr_3 <= ch1_cntr_3 + ch1_var_cntr + 8;
                else
                    ch1_var_flag3 <= '0';
                    ch1_var_flag_med3 <= '0';
                    ch1_cntr_3 <= to_unsigned(3, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_4 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_4 > 1000) then
            ch1_var_flag4 <= '0';
            ch1_var_flag_med4 <= '0';
            ch1_cntr_4 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_4 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag4 <= '1';
                    elsif ((ch1_cntr_4 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med4 <= '1';
                    else
                        ch1_var_flag4 <= '0';
                        ch1_var_flag_med4 <= '0';
                    end if;
                    ch1_cntr_4 <= ch1_cntr_4 + ch1_var_cntr + 8;
                else
                    ch1_var_flag4 <= '0';
                    ch1_var_flag_med4 <= '0';
                    ch1_cntr_4 <= to_unsigned(4, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_5 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_5 > 1000) then
            ch1_var_flag5 <= '0';
            ch1_var_flag_med5 <= '0';
            ch1_cntr_5 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_5 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag5 <= '1';
                    elsif ((ch1_cntr_5 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med5 <= '1';
                    else
                        ch1_var_flag5 <= '0';
                        ch1_var_flag_med5 <= '0';
                    end if;
                    ch1_cntr_5 <= ch1_cntr_5 + ch1_var_cntr + 8;
                else
                    ch1_var_flag5 <= '0';
                    ch1_var_flag_med5 <= '0';
                    ch1_cntr_5 <= to_unsigned(5, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_6 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0'or ch1_cntr_6 > 1000) then
            ch1_var_flag6 <= '0';
            ch1_var_flag_med6 <= '0';
            ch1_cntr_6 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_6 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag6 <= '1';
                    elsif ((ch1_cntr_6 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med6 <= '1';
                    else
                        ch1_var_flag6 <= '0';
                        ch1_var_flag_med6 <= '0';
                    end if;
                    ch1_cntr_6 <= ch1_cntr_6 + ch1_var_cntr + 8;
                else
                    ch1_var_flag6 <= '0';
                    ch1_var_flag_med6 <= '0';
                    ch1_cntr_6 <= to_unsigned(6, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;
    
    ch1_trans_gen_7 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0' or ch1_cntr_7 > 1000) then
            ch1_var_flag7 <= '0';
            ch1_var_flag_med7 <= '0';
            ch1_cntr_7 <= to_unsigned(0, g_num_bits_cnt);
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- when there is no data transition, check the counter
                if (ch1_var_trans = "00") then
                    -- check if we have completed a cycle time 0    
                    if ((ch1_cntr_7 rem ch1_full_trans) = to_unsigned(0, g_num_bits_cnt)) then
                        -- Set the output and store the transition and counter values
                        ch1_var_flag7 <= '1';
                    elsif ((ch1_cntr_7 rem ch1_half_trans) 
                            = to_unsigned(0, g_num_bits_cnt)) and ch1_aux_clk(0) = '1' then
                            ch1_var_flag_med7 <= '1';
                    else
                        ch1_var_flag7 <= '0';
                        ch1_var_flag_med7 <= '0';
                    end if;
                    ch1_cntr_7 <= ch1_cntr_7 + ch1_var_cntr + 8;
                else
                    ch1_var_flag7 <= '0';
                    ch1_var_flag_med7 <= '0';
                    ch1_cntr_7 <= to_unsigned(7, g_num_bits_cnt);
                end if;   
            end if;
        end if;
    end process;

    clk_gen_ch1 : process (ref_clk_i, rst_i)
                
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0') then
            ch1_aux_clk       <= (others => '0');
            ch1_nbits <= 0;
            ch1_cntr  <= 0;
            ch1_bit_value <= '0';
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- if there is a transition on the received data
                case ch1_var_trans1 is
                    when "01" => 
                        if ch1_aux_clk(0) = '0' then
                            ch1_aux_clk  <= not (ch1_aux_data4);
                        else
                            ch1_aux_clk <= "11111111";
                        end if;
                        if (ch1_cntr < 40) then
                            ch1_nbits <= 0;
                        elsif (ch1_cntr >= 40 and ch1_cntr < 120) then
                            ch1_nbits <= 1;
                        elsif (ch1_cntr >= 120 and ch1_cntr < 200) then
                            ch1_nbits <= 2;
                        elsif (ch1_cntr >= 200 and ch1_cntr < 280) then
                            ch1_nbits <= 3;
                        elsif (ch1_cntr >= 280 and ch1_cntr < 360) then
                            ch1_nbits <= 4;
                        else
                            ch1_nbits <= 5;
                        end if;
                        ch1_cntr <= to_integer(ch1_var_cntr1);
                        ch1_bit_value <= '1';
                    when "10" =>
                        if ch1_aux_clk(0) = '0' then
                            ch1_aux_clk  <= ch1_aux_data4;
                        else
                            ch1_aux_clk <= "11111111";
                        end if;
                        if (ch1_cntr < 40) then
                            ch1_nbits <= 0;
                        elsif (ch1_cntr >= 40 and ch1_cntr < 120) then
                            ch1_nbits <= 1;
                        elsif (ch1_cntr >= 120 and ch1_cntr < 200) then
                            ch1_nbits <= 2;
                        elsif (ch1_cntr >= 200 and ch1_cntr < 280) then
                            ch1_nbits <= 3;
                        elsif (ch1_cntr >= 280 and ch1_cntr < 360) then
                            ch1_nbits <= 4;
                        else
                            ch1_nbits <= 5;
                        end if;
                        ch1_cntr <= to_integer(ch1_var_cntr1);
                        ch1_bit_value <= '0';
                    when others =>   
                        if    ch1_var_flag0 = '1' then ch1_aux_clk <= "11111111"; 
                        elsif ch1_var_flag1 = '1' then ch1_aux_clk <= "01111111";
                        elsif ch1_var_flag2 = '1' then ch1_aux_clk <= "00111111";
                        elsif ch1_var_flag3 = '1' then ch1_aux_clk <= "00011111";
                        elsif ch1_var_flag4 = '1' then ch1_aux_clk <= "00001111";
                        elsif ch1_var_flag5 = '1' then ch1_aux_clk <= "00000111";
                        elsif ch1_var_flag6 = '1' then ch1_aux_clk <= "00000011";
                        elsif ch1_var_flag7 = '1' then ch1_aux_clk <= "00000001";
                        elsif ch1_var_flag_med0 = '1' then ch1_aux_clk <= "00000000";
                        elsif ch1_var_flag_med1 = '1' then ch1_aux_clk <= "10000000";
                        elsif ch1_var_flag_med2 = '1' then ch1_aux_clk <= "11000000";
                        elsif ch1_var_flag_med3 = '1' then ch1_aux_clk <= "11100000";
                        elsif ch1_var_flag_med4 = '1' then ch1_aux_clk <= "11110000";
                        elsif ch1_var_flag_med5 = '1' then ch1_aux_clk <= "11111000";
                        elsif ch1_var_flag_med6 = '1' then ch1_aux_clk <= "11111100";
                        elsif ch1_var_flag_med7 = '1' then ch1_aux_clk <= "11111110";
                        elsif ch1_aux_clk(0) = '0' then ch1_aux_clk <= "00000000";
                        elsif ch1_aux_clk(0) = '1' then ch1_aux_clk <= "11111111";
                        end if;
                        ch1_cntr <= ch1_cntr + 8;
                end case;
--                ch1_aux_clk1 <= ch1_aux_clk;
--                ch1_aux_clk2 <= ch1_aux_clk1;
                ch1_clk_o <= ch1_aux_clk;
            end if; 
        end if;
    end process;      
    
    data_smpl_ch1 : process (ref_clk_i, rst_i)
        
    begin
        -- if there is a reset, the counter and the clock are initialized
        if(rst_i = '0') then
            ch1_edge_flag <= 0;
            ch1_nbits_aux <= 0;
            ch1_bit_value_aux <= '0';
            ch1_fifo_data <= '0';
            ch1_fifo_wr <= '0';
            ch1_fifo_rd <= '0';
            ch1_fifo_rd1 <= '0';
            ch1_fifo_rd2 <= '0';
            ch1_rd_aux <= '0';
        else
            -- each deserialized frame
            if rising_edge(ref_clk_i) then
                -- Write the calculated number of bits without transition
                if (ch1_nbits_aux > ch1_edge_flag) then
                    ch1_fifo_data <= ch1_bit_value;
                    ch1_edge_flag <= ch1_edge_flag + 1;
                    ch1_fifo_wr <= '1';
                else
                    ch1_fifo_wr <= '0';
                end if;
                if (ch1_bit_value /= ch1_bit_value_aux) then
                    ch1_edge_flag <= 0;
                end if;
                -- Read each transition on the 12.5 MHz clock
                if (ch1_clk_i = '1' and ch1_clk1 = '1' and ch1_clk2 = '1' and ch1_rd_aux = '0'
                    and ch1_fifo_rd = '0' and ch1_fifo_rd1 = '0' and ch1_fifo_rd2 = '0') then
                    ch1_fifo_rd <= '1';
                    ch1_rd_aux <= '1';
                elsif (ch1_clk_i = '0' and ch1_clk1 = '0' and ch1_clk2 = '0') then
                    ch1_rd_aux <= '0';
                else
                    ch1_fifo_rd <= '0';
                end if;
                ch1_bit_value_aux <= ch1_bit_value;
                ch1_clk1 <= ch1_clk_i;
                ch1_clk2 <= ch1_clk1;
                ch1_nbits_aux <= ch1_nbits;
                ch1_rd_en_o <= ch1_fifo_rd;
                ch1_fifo_rd1 <= ch1_fifo_rd;
                ch1_fifo_rd2 <= ch1_fifo_rd1;
            end if;
        end if;
    end process;
    
    ch1_sampled_data_fifo: cdr_fifo
    PORT MAP (
        CLK        => ref_clk_i,
        RST        => not(rst_i),
        DataIn    => ch1_fifo_data,
        WriteEn    => ch1_fifo_wr,
        ReadEn    => ch1_fifo_rd,
        DataOut    => ch1_data_o,
        Full    => open,
        Empty    => open
    );

end struct;
