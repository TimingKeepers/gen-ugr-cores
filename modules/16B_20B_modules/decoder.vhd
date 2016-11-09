-- **************************************************************
-- Owner:		Xilinx Inc.
-- File:  		decoder.vhd
--
-- Purpose: 		16B/20B decoder module.  Combines two parallel
--			working 8B/10B decoder modules.
--	
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--		
-- ****************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity DEC_16B20B is
	port(
		clk		: in STD_LOGIC;
		rst		: in STD_LOGIC;
		serial_data 	: in STD_LOGIC_VECTOR(19 downto 0);
		frame_in_dec	: in STD_LOGIC;
		frame_out_dec	: out STD_LOGIC;
		decoded_data	: out STD_LOGIC_VECTOR(15 downto 0);
		k_char		    : out STD_LOGIC_VECTOR (1 downto 0);
		enc_err         : out STD_LOGIC);		

end DEC_16B20B;


architecture BEHAVIOUR of DEC_16B20B is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 			: STD_LOGIC := '0';

-- ********************* SIGNAL DECLARATIONS ************************
signal data_out				: STD_LOGIC_VECTOR(15 downto 0);
signal frame_out_u, frame_out_l		: STD_LOGIC;
signal start_det_u, start_det_l		: STD_LOGIC;
signal kout_u, kout_l			: STD_LOGIC;
signal error_u, error_l			: STD_LOGIC;
signal start_det			: STD_LOGIC;


-- ******************** COMPONENT DECLARATION ***********************
-- 8B/10B Decoder Function
component DECODER
    	port(
        clk			: in STD_LOGIC;
        rst			: in STD_LOGIC;
        
          	-- Decoder inputs                      
	  	data_in			: in STD_LOGIC_VECTOR(9 downto 0);   	-- Parallel byte of incoming data
	  	frame_in 		: in STD_LOGIC;				-- Asserted when data stream is stable

		-- Decoder outputs
	 	data_out		: out STD_LOGIC_VECTOR(7 downto 0);  	-- Decoded data to present
	 	frame_out		: out STD_LOGIC;			-- Asserted when data is encoded and ready
										-- to be sent through the external serializer	  
	  	kout			: out STD_LOGIC;			-- Asserted when transmission of 
										-- special character is detected
	  	err_out			: out STD_LOGIC;			-- Asserted when a non-valid 8B/10B data 
										-- stream is detected
	  	start_det		: out STD_LOGIC); 			-- Asserted to start 16B/20B error detect
										-- state machine    
end component;

begin

	-- ******************* SIGNAL ASSIGNMENTS *********************
	decoded_data <= data_out;
	frame_out_dec <= frame_out_u and frame_out_l;
	start_det <= start_det_u and start_det_l;
	k_char <= kout_u & kout_l;
    enc_err <= error_u or error_l;


	-- ***************** COMPONENT ASSIGNMENTS *********************
	UPPER_DEC: DECODER	
		port map(	
			clk		=> clk,			
        		rst		=> rst,
 			data_in		=> serial_data(19 downto 10),
			frame_in 	=> frame_in_dec,		  	 
	  		data_out	=> data_out(15 downto 8),
	 		frame_out	=> frame_out_u,			  
	  		kout		=> kout_u,							
	  		err_out		=> error_u,										  		
			start_det	=> start_det_u);	

	LOWER_DEC: DECODER	
		port map(	
			clk		=> clk,			
        		rst		=> rst,
 			data_in		=> serial_data(9 downto 0),
			frame_in 	=> frame_in_dec,		  	 
	  		data_out	=> data_out(7 downto 0),
			frame_out	=> frame_out_l,			  
	  		kout		=> kout_l,							
	  		err_out		=> error_l,										  		
			start_det	=> start_det_l);	


end BEHAVIOUR;








































