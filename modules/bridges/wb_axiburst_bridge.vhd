--------------------------------------------------------------------------------
-- Title      : Burst-capable wishbone to AXI bridge
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wb_axiburst_bridge.vhd
-- Author     : Jose Lopez
-- Company    : Universidad de Granada
-- Created    : 2016-05-17
-- Last update:
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: custom Wishbone to AXI bridge for zen-fmc-adc project.
-- - 64-bit data width and 256-word-long bursts by default.
-- - AXI4
-- - Wishbone pipelined
-- - No b-channel error control
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-05-17  1.0      joselj          Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;
use work.gencores_pkg.all;

entity wb_axiburst_bridge is
	generic (

    G_DATA_WIDTH    : integer    := 32;
    G_ADDR_WIDTH    : integer    := 32;
    
    G_BURST_WIDTH	: integer	 := 8

	);
	port (

	clk_i			: in std_logic;
    rst_n_i		: in std_logic;
        
--Wishbone ports

    wb_cyc_i       : in std_logic;
    wb_stb_i       : in std_logic;
    wb_ack_o       : out std_logic;
    wb_stall_o	   : out std_logic;
    wb_dat_i       : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
    wb_adr_i       : in std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    wb_we_i        : in std_logic;
    wb_sel_i       : in std_logic_vector(G_DATA_WIDTH/8-1 downto 0);
    
    adc_acq_count  : in std_logic_vector(31 downto 0); -- Not essential.
													   -- Unused at the moment.
    
    -- This port can be used to trigger an irq after the transfer is over:
    acq_end_o : out std_logic;

-- Ports of Axi Master Bus Interface M00_AXI

	m00_axi_aclk	: in std_logic;
	m00_axi_aresetn	: in std_logic;
	m00_axi_awaddr	: out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
	m00_axi_awlen	: out std_logic_vector(7 downto 0);
	m00_axi_awsize  : out std_logic_vector(2 downto 0);
	m00_axi_awburst : out std_logic_vector(1 downto 0);
	m00_axi_awprot	: out std_logic_vector(2 downto 0);
	m00_axi_awvalid	: out std_logic;
	m00_axi_awready	: in std_logic;
	m00_axi_wdata	: out std_logic_vector(G_DATA_WIDTH-1 downto 0);
	m00_axi_wstrb	: out std_logic_vector(G_DATA_WIDTH/8-1 downto 0);
	m00_axi_wlast	: out std_logic;
	m00_axi_wvalid	: out std_logic;
	m00_axi_wready	: in std_logic;
	m00_axi_bresp	: in std_logic_vector(1 downto 0);
	m00_axi_bvalid	: in std_logic;
	m00_axi_bready	: out std_logic);
end wb_axiburst_bridge;

architecture behavioral of wb_axiburst_bridge is

type addr_state_type is (idle, set_addr, wait_awready, ongoing_burst);
type data_state_type is (idle, burst_words, burst_end);

constant LAST_WORD_IDX : integer := 255;

signal addr_state  : addr_state_type;
signal data_state  : data_state_type;

signal total_bursts : std_logic_vector(31 downto 0);
signal beat_count : unsigned(G_BURST_WIDTH-1 downto 0);
signal wready_word_count : unsigned(G_BURST_WIDTH-1 downto 0);
signal burst_count	 : unsigned(19 downto 0);
signal burst_base_addr : unsigned(G_ADDR_WIDTH - 1 downto 0);
signal irq_delay_counter : unsigned(19 downto 0);


signal m00_axi_awvalid_sig : std_logic;
signal m00_axi_wdata_int : std_logic_vector(G_DATA_WIDTH-1 downto 0);
signal m00_axi_wvalid_int : std_logic;
signal m00_axi_wlast_sig : std_logic;
signal m00_axi_wstrb_int	: std_logic_vector(G_DATA_WIDTH/8-1 downto 0);

signal fifo_din 			: std_logic_vector((G_ADDR_WIDTH + G_DATA_WIDTH + G_DATA_WIDTH/8 + 2)-1 downto 0);
signal fifo_wr				: std_logic;
signal fifo_dout			: std_logic_vector((G_ADDR_WIDTH + G_DATA_WIDTH + G_DATA_WIDTH/8 + 2)-1 downto 0);
signal fifo_rd				: std_logic;
signal fifo_empty			: std_logic;
signal fifo_full			: std_logic;
signal fifo_count			: std_logic_vector(5 downto 0);
signal fifo_almost_full		: std_logic;
signal fifo_almost_empty	: std_logic;

signal wb_stb_d0			: std_logic;
signal axi_error            : std_logic;
signal burst_start_sig		: std_logic;
signal burst_start_ack		: std_logic;
signal acq_end				: std_logic;
signal awvalid_count		: unsigned(19 downto 0);
signal wlast_count			: unsigned(19 downto 0);
signal bvalid_count			: unsigned(19 downto 0);

signal last_burst			: std_logic;

signal debugsig0, debugsig1, debugsig2 : std_logic_vector(4 downto 0);

attribute mark_debug : string;
attribute mark_debug of fifo_wr : signal is "true";
attribute mark_debug of fifo_rd	: signal is "true";
attribute mark_debug of fifo_count : signal is "true";
attribute mark_debug of fifo_empty : signal is "true";
attribute mark_debug of fifo_full : signal is "true";
attribute mark_debug of fifo_almost_empty : signal is "true";
attribute mark_debug of fifo_almost_full : signal is "true";
attribute mark_debug of beat_count : signal is "true";
attribute mark_debug of wready_word_count : signal is "true";
attribute mark_debug of burst_start_sig : signal is "true";
attribute mark_debug of burst_count	: signal is "true";
attribute mark_debug of total_bursts : signal is "true";
attribute mark_debug of axi_error : signal is "true";
attribute mark_debug of debugsig0 : signal is "true";
attribute mark_debug of debugsig1 : signal is "true";
attribute mark_debug of debugsig2 : signal is "true";
attribute mark_debug of awvalid_count : signal is "true";
attribute mark_debug of wlast_count : signal is "true";
attribute mark_debug of bvalid_count : signal is "true";


begin

	wb_stall_o <= '0';
	
	ack_gen : process(clk_i)
	begin
		if(rst_n_i = '0') then
			wb_ack_o <= '0';
		elsif rising_edge(clk_i) then
			if(wb_cyc_i = '1' and wb_stb_i = '1') then
				wb_ack_o <= '1';
			else
				wb_ack_o <= '0';
			end if;
		end if;
	end process ack_gen;
	
	cmp_fifo : generic_sync_fifo
	generic map (
      g_data_width             => G_ADDR_WIDTH + G_DATA_WIDTH + G_DATA_WIDTH/8 + 2,
      g_size                   => 40,
      g_show_ahead             => false,
      g_with_empty             => true,
      g_with_full              => true,
      g_with_almost_empty      => true,
      g_with_almost_full       => true,
      g_with_count             => true,
      g_almost_empty_threshold => 15,
      g_almost_full_threshold  => 20
      )
    port map(
      rst_n_i        => rst_n_i,
      clk_i          => clk_i,
      d_i            => fifo_din,
      we_i           => fifo_wr,
      q_o            => fifo_dout,
      rd_i           => fifo_rd,
      empty_o        => fifo_empty,
      full_o         => fifo_full,
      almost_empty_o => fifo_almost_empty,
      almost_full_o  => fifo_almost_full,
      count_o        => fifo_count
      );
      
    fifo_din <= wb_adr_i & wb_sel_i & wb_cyc_i & wb_stb_i & wb_dat_i;
    fifo_wr	 <= wb_cyc_i and wb_stb_i;	
	
	cmp_addr_proc : process(clk_i)
	begin
	if(rst_n_i = '0') then
	-- default values:
	
	elsif(rising_edge(clk_i)) then
	
		wb_stb_d0 <= wb_stb_i;
		debugsig0 <= "00000";
	
		case addr_state is 
		
		when idle =>
			-- default values once again:
			acq_end <= '0';
			m00_axi_awvalid_sig <= '0';
			debugsig0 <= "10001";
			
			if(fifo_empty = '1') then
				fifo_rd <= '0';
				debugsig0 <= "00001";
			end if;
			
			
			-- if there is a new acq:
			if wb_cyc_i = '1' and wb_stb_d0 = '0' and wb_stb_i = '1' then
				-- addr comes directly from wishbone for the first burst
				burst_base_addr <= unsigned(wb_adr_i);
				-- save total_bursts
				total_bursts <= adc_acq_count(31 downto 8) & x"00"; -- this is not used.
				burst_count  <= to_unsigned(0,burst_count'length);
				-- goto set_addr
				addr_state <= set_addr;
				debugsig0 <= "00010";
			end if;
									
		when set_addr =>
		
				debugsig0 <= "10000";
				if(fifo_rd = '1') then
					burst_base_addr  <= (burst_base_addr) + to_unsigned(2048,burst_base_addr'length);					
					debugsig0 <= "00100";
				else
					debugsig0 <= "00101";
				end if;
				m00_axi_awvalid_sig	<= '1';
				m00_axi_awlen 	<= "11111111"; -- FIXME: this should be customizable
				m00_axi_awburst <= "01";
				m00_axi_awsize	<= "011"; -- FIXME: this should be customizable
				burst_count		<= burst_count + 1;
				addr_state	 	<= wait_awready;
			
		when wait_awready =>
		
		-- we just acknowledge that the addr is successfully set and
		-- we wait for ending_burst.
		
			m00_axi_awvalid_sig <= '0';
			debugsig0 <= "10010";
			if (fifo_almost_empty = '0' and fifo_empty = '0' and fifo_rd = '0') or fifo_full = '1' then
				burst_start_sig <= '1';
				addr_state		<= ongoing_burst;
				fifo_rd <= '1';
				debugsig0 <= "11111";
			end if;	
			
			if fifo_rd = '1' then
				m00_axi_awvalid_sig <= '0';
				addr_state		<= ongoing_burst;
				debugsig0 <= "01000";
			end if;
			
		when ongoing_burst =>
			
			fifo_rd 		<= '1';
			debugsig0 <= "01001";		

			-- only for the first burst in an acquisition
			if burst_start_sig = '1' and burst_start_ack = '0' then
				burst_start_sig <= '0';
				debugsig0 <= "01010";
			end if;
			
			-- when one burst is about to end, we can foresee the first address
			-- of the next burst and send it via the address channel so that there
			-- are no idle cycles between bursts if there is enough data left.
			if ((beat_count = LAST_WORD_IDX-5) and (unsigned(fifo_count) > 4)) then --
				addr_state		<= set_addr;
				debugsig0 <= "01011";
			end if;
			
			if(fifo_empty = '1') then
				addr_state  <= idle;
				debugsig0   <= "01100";
				acq_end     <= '1'; 
			end if;

		when others =>
		
		end case;
	
	end if;
	end process cmp_addr_proc;
	
	-- For our application we want to make sure that we only write in addresses
	-- from 0x10000000 to 0x1fffffff
	m00_axi_awaddr  <= "0001" & std_logic_vector(burst_base_addr(27 downto 0));
	m00_axi_awprot  <= "000";
	m00_axi_awvalid <= m00_axi_awvalid_sig when m00_axi_awready = '1' else '0';

	
	cmp_data_proc : process(clk_i)
	begin
	if rst_n_i = '0' then
	 
	elsif rising_edge(clk_i) then
	
		-- Make sure that wlast is only high for one cycle.
		m00_axi_wlast_sig <= '0';
		
		case data_state is
		
		when idle =>

		-- Default values, etc.
		debugsig1 <= "00000";

		if burst_start_sig = '1' then
			burst_start_ack <= '1';
			data_state <= burst_words;
			beat_count <= to_unsigned(0,beat_count'length);
			debugsig1 <= "00001";
		end if;
		
		when burst_words =>
		
			m00_axi_wvalid_int <= '0';
		
			-- Acknowledge the start of a new acquisition
			if(burst_start_sig = '0' and burst_start_ack = '1') then
				burst_start_ack <= '0';
				debugsig1 <= "00010";
			end if;
			
			if(fifo_rd = '1') then
				m00_axi_wdata_int  <= fifo_dout(G_DATA_WIDTH - 1 downto 0);
				m00_axi_wstrb      <= fifo_dout( (fifo_dout'length - G_ADDR_WIDTH - 1) downto (fifo_dout'length - G_ADDR_WIDTH - 8));
				m00_axi_wvalid_int <= '1';
				beat_count <= beat_count+1;
				debugsig1 <= "00011";
			elsif fifo_empty = '1' then
				m00_axi_wdata_int  <= fifo_dout(G_DATA_WIDTH - 1 downto 0);
				m00_axi_wstrb      <= (others => '0');
				m00_axi_wvalid_int <= '1';
				beat_count <= beat_count+1;
				debugsig1 <= "01000";
				last_burst <= '1';
			end if;
			
			if(m00_axi_wready = '1') then
				wready_word_count <= wready_word_count+1;
			end if;
			
			if (beat_count = LAST_WORD_IDX) then
				m00_axi_wlast_sig <= '1';
				beat_count	  <= to_unsigned(0, beat_count'length);
				debugsig1 <= "00100";
			end if;
			
			if ((wready_word_count = LAST_WORD_IDX) and last_burst = '1') then
				m00_axi_wvalid_int	<= '0';
				last_burst <= '0';
				data_state	 		<= idle;
				debugsig1 <= "00101";
			end if;
					
		when burst_end => -- This state has remained useless. We could just remove it. Nobody would tell.
				data_state			<= idle;
				debugsig1 <= "00110";
		
		when others =>
		
		end case;
		
	end if;	
	end process cmp_data_proc;
	
	m00_axi_wdata  <= m00_axi_wdata_int;
	m00_axi_wvalid <= m00_axi_wvalid_int;
	m00_axi_wlast  <= m00_axi_wlast_sig;
	
	
	-- At this moment axi_error just exists but we the bridge won't react to
	-- a bresp error in any way.
	cmp_bchan_proc : process(clk_i)
	begin
	if rst_n_i = '0' then
	
	elsif rising_edge(clk_i) then
		if m00_axi_bvalid = '1' then
			if(m00_axi_bresp = "00") then
				axi_error <= '0';
			else
				axi_error <= '1';
			end if;
		end if;
		
		if data_state = burst_words then
			m00_axi_bready <= '1';
		end if;
		if data_state /= burst_words and m00_axi_bvalid = '1' then
			m00_axi_bready <= '0';
		end if;
	end if;	
	end process cmp_bchan_proc;
	
	
	-- We don't want to tell Linux that we are done with our acquisition
	-- until everything has been written to the DDR. Let's give AXI slave
	-- and the memory controller some time to do their thing.
	cmp_acq_end_gen : process(clk_i)
	begin
		if rst_n_i = '0' then
		
		elsif rising_edge(clk_i) then
			
			acq_end_o <= '0';
			
			if(acq_end = '1') then
				irq_delay_counter <= to_unsigned(1,20);--burst_count(19 downto 2) & "00";
			end if;
			
			if irq_delay_counter > 0 then
				irq_delay_counter <= irq_delay_counter + 1;
			end if;
			
			--if(irq_delay_counter(19 downto 7) = burst_count(12 downto 0) and (fifo_empty = '1') and (burst_count(11 downto 0) /= x"000") ) then
			if irq_delay_counter = 1023 then
				acq_end_o <= '1';
				irq_delay_counter <= (others => '0');
			end if;
			
		end if;
	end process cmp_acq_end_gen;
	
	
	-- At any given point in time (if the bridge is working as it should)
	-- the counters of awvalids, wlasts and bvalids must not differ in more than 1.
	-- This can be an useful tool for debugging.	
	cmp_count_bursts_debug : process(clk_i)
	begin
		if rst_n_i = '0' then
			awvalid_count 	<= (others => '0');
			wlast_count		<= (others => '0');
			bvalid_count	<= (others => '0');
		elsif rising_edge(clk_i) then
			if(m00_axi_awvalid_sig = '1') then
				awvalid_count <= awvalid_count + 1;
			end if;
			
			if(m00_axi_wlast_sig = '1') then
				wlast_count <= wlast_count + 1;
			end if;
			
			if(m00_axi_bvalid = '1') then
				bvalid_count <= bvalid_count + 1;
			end if;
				
		end if;
	end process cmp_count_bursts_debug;

 end behavioral;
