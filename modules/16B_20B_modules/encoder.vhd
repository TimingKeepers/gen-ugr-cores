-- **************************************************************
-- Owner:		Xilinx Inc.
-- File:  		encoder.vhd
--
-- Purpose: 		16B/20B encoder.  Combines upper and lower
--			8B/10B modules.  Connects running disparity
--			from upper module as disparity in on lower
--			module.
--	
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--		
-- ****************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ENC_16B20B is
	port(
		clk		: in STD_LOGIC;
		rst		: in STD_LOGIC;
		data_trs	: in STD_LOGIC_VECTOR(15 downto 0);
		k_char		: in STD_LOGIC_VECTOR (1 downto 0);
		dis_in		: in STD_LOGIC;
		frame_in_enc	: in STD_LOGIC;
		frame_out_enc	: out STD_LOGIC;
		serial_data	: out STD_LOGIC_VECTOR(19 downto 0);
		dis_out		: out STD_LOGIC);

end ENC_16B20B;


architecture BEHAVIOUR of ENC_16B20B is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 			: STD_LOGIC := '0';

-- ********************* SIGNAL DECLARATIONS ************************
signal run_disparity			 : STD_LOGIC;
signal frame_out_upper, frame_out_lower  : STD_LOGIC;
signal enc_data_upper, enc_data_lower	 : STD_LOGIC_VECTOR(9 downto 0);
signal disparity_rdy			 : STD_LOGIC;
signal frame_out_enc_aux  : STD_LOGIC;
signal serial_data_aux : STD_LOGIC_VECTOR(19 downto 0);


-- ******************** COMPONENT DECLARATION ***********************
-- Upper 8B/10B Encoder Function
component ENCODER_UP
	port(
          	clk			: in STD_LOGIC;
          	rst			: in STD_LOGIC;
        
          	-- Protocol Device Interface                      
	  	data_in			: in STD_LOGIC_VECTOR(7 downto 0);   	-- Parallel byte of incoming data
	  	k_char			: in STD_LOGIC;				-- Asserted specifies the transmission of 
										-- a special character
	  	frame_in 		: in STD_LOGIC;				-- Asserted when parallel data is stable	 
	    	dis_in			: in STD_LOGIC;			   	-- Disparity in
	  	dis_out			: out STD_LOGIC;		  	-- Disparity out
		disout_rdy		: out STD_LOGIC;			-- Asserted when dis_out is stable

	  	-- Encoder outputs
	  	encoded_data		: out STD_LOGIC_VECTOR(9 downto 0);  	-- Encoded data to send out
	  	frame_out		: out STD_LOGIC				-- Asserted when data is encoded and ready
										-- to be sent through the external serializer
	  	);

end component;

-- Upper 8B/10B Encoder Function
component ENCODER_LOW
	port(
          	clk			: in STD_LOGIC;
          	rst			: in STD_LOGIC;
        
          	-- Protocol Device Interface                      
	  	data_in			: in STD_LOGIC_VECTOR(7 downto 0);   	-- Parallel byte of incoming data
	  	k_char			: in STD_LOGIC;				-- Asserted specifies the transmission of 
										-- a special character
	  	frame_in 		: in STD_LOGIC;				-- Asserted when parallel data is stable
		disin_rdy		: in STD_LOGIC;				-- Asserted when dis_in is stable	 
	    	dis_in			: in STD_LOGIC;			   	-- Disparity in
	  	dis_out			: out STD_LOGIC;		  	-- Disparity out

	  	-- Encoder outputs
	  	encoded_data		: out STD_LOGIC_VECTOR(9 downto 0);  	-- Encoded data to send out
	  	frame_out		: out STD_LOGIC				-- Asserted when data is encoded and ready
										-- to be sent through the external serializer
	  	);

end component;


begin

	-- ***************** SIGNAL ASSIGNMENTS ************************
	
    output : process (clk, rst)
    variable counter : integer := 0;
    begin
        if (rst = '0') then
            frame_out_enc_aux <= '0';
            serial_data_aux <= (others => '0');
            frame_out_enc <= '0';
            serial_data <= (others => '0');
        else
            if rising_edge (clk) then
                if ((frame_out_upper) and (frame_out_lower)) = '1' then
                    frame_out_enc_aux <= (frame_out_upper) and (frame_out_lower);
                    serial_data_aux <= enc_data_upper & enc_data_lower;     
                end if;
                if frame_in_enc = '1' then
                    frame_out_enc <= frame_out_enc_aux;
                    serial_data <= serial_data_aux;
                    frame_out_enc_aux <= '0';
                    serial_data_aux <= (others => '0');
                else
                    frame_out_enc <= '0';
                end if;
            end if;    
        end if;
    end process;
       

	-- ***************** COMPONENT ASSIGNMENTS *********************
	UPPER_ENC: ENCODER_UP
		port map(
          		clk		=> clk,			
        		rst		=> rst,
			data_in		=> data_trs(15 downto 8),
		  	k_char		=> k_char(1),
	  		frame_in 	=> frame_in_enc,	  
	  		dis_in		=> dis_in,			   	
	  		dis_out		=> run_disparity,
			disout_rdy	=> disparity_rdy,		  		
	  		encoded_data	=> enc_data_upper, 
	  		frame_out	=> frame_out_upper);


	LOWER_ENC: ENCODER_LOW
		port map(
          		clk		=> clk,			
        		rst		=> rst,
			data_in		=> data_trs(7 downto 0),
		  	k_char		=> k_char(0),
	  		frame_in 	=> frame_in_enc,
			disin_rdy	=> disparity_rdy,	  
	  		dis_in		=> run_disparity,			   	
	  		dis_out		=> dis_out,		  		
	  		encoded_data	=> enc_data_lower, 
	  		frame_out	=> frame_out_lower);

   
end BEHAVIOUR;
































