-- **************************************************************
-- Owner:		Xilinx Inc.
-- File:  		main_dec.vhd
--
-- Purpose: 		Main 8B/10B decoder description.  This decoder
--			can be used for fiber channel implementations.
--			Controls decoding and error detect for each 8B/10B
--			module for determining the output data byte.
--	
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--		
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity DECODER is
    port(
        
          clk			: in STD_LOGIC;
          rst			: in STD_LOGIC;
        
          -- Decoder inputs                      
	  data_in		: in STD_LOGIC_VECTOR(9 downto 0);   	-- Parallel byte of incoming data
	  frame_in 		: in STD_LOGIC;				-- Asserted when data stream is stable
		  	 
	  -- Decoder outputs
	  data_out		: out STD_LOGIC_VECTOR(7 downto 0);  	-- Decoded data to present
	  frame_out		: out STD_LOGIC;			-- Asserted when data is encoded and ready
									-- to be sent through the external serializer	  
	  kout			: out STD_LOGIC;			-- Asserted when transmission of 
									-- special character is detected
	  err_out		: out STD_LOGIC;			-- Asserted when a non-valid 8B/10B data 
									-- stream is detected
	  start_det		: out STD_LOGIC );			-- Asserted to start 16B/20B error detect
									-- state machine    

end DECODER;



architecture BEHAVIOUR of DECODER is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, ASSIGN, DONE);
signal prs_state, nxt_state : STATE;

--------------------------- Decoder Logic ----------------------------
-- Starting signal for decoder and error check logic
signal start_dec : STD_LOGIC;

-- Ending signals from decoder and error check logic
signal dec_done, errchk_done : STD_LOGIC;

-- Assinged from incoming data stream
signal  ain, bin, cin, din, ein, iin, fin, gin, hin, jin : STD_LOGIC;

-- Assign output data
signal  aout, bout, cout, dout, eout, fout, gout, hout : STD_LOGIC;

-- Asserted when special character detected
signal k_dec : STD_LOGIC;


-- ******************** COMPONENT DECLARATION ***********************

-- 8B/10B Encoder Function
component DEC_FUNC
	port(
		clk			: in STD_LOGIC;
        	rst			: in STD_LOGIC;
        
          	-- Data Inputs (ain .. jin)
	  	ain			: in STD_LOGIC;			
	  	bin			: in STD_LOGIC;
	  	cin			: in STD_LOGIC;			
	  	din			: in STD_LOGIC;
	  	ein			: in STD_LOGIC;
	  	iin			: in STD_LOGIC;			
	  	fin			: in STD_LOGIC;
	  	gin			: in STD_LOGIC;			
	  	hin			: in STD_LOGIC;  
	  	jin			: in STD_LOGIC;	
	
 	  	-- Control terms
	  	start_dec		: in STD_LOGIC;   	-- Asserted starts decoding sequence
	  	
	  	-- Output data terms (AOUT .. HOUT)
	  	aout			: out STD_LOGIC;
	  	bout			: out STD_LOGIC;
	  	cout			: out STD_LOGIC;
	  	dout			: out STD_LOGIC;
	  	eout			: out STD_LOGIC;
	  	fout			: out STD_LOGIC;
	  	gout			: out STD_LOGIC;
	  	hout			: out STD_LOGIC;

	  	kout			: out STD_LOGIC;	-- Asserted when special character
								-- is detected in transmission
	  	-- Output signals
	  	dec_done		: out STD_LOGIC		-- Asserted when decoding is complete, 
								-- provides handshaking to main control logic
        	);

end component;

component ERR_CHECK 
    port(
        
          	clk			: in STD_LOGIC;
          	rst			: in STD_LOGIC;
        
          	-- Data Inputs (ain .. jin)
	  	ain			: in STD_LOGIC;			
	  	bin			: in STD_LOGIC;
	  	cin			: in STD_LOGIC;			
	  	din			: in STD_LOGIC;
	  	ein			: in STD_LOGIC;
	  	iin			: in STD_LOGIC;			
	  	fin			: in STD_LOGIC;
	  	gin			: in STD_LOGIC;			
	  	hin			: in STD_LOGIC;  
	  	jin			: in STD_LOGIC;	
	
 	  	-- Control terms
	  	start_dec		: in STD_LOGIC;   		-- Asserted starts decoding sequence
	  	
	  	-- Output signals
	  	errchk_done		: out STD_LOGIC;		-- Asserted when encoding is complete, 
									-- provides handshaking to main control logic
	  	err_out			: out STD_LOGIC			-- Asserted when error has been detected

          	);

end component;


begin

	-- ****************** SIGNAL ASSIGNMENTS ***********************
	start_dec <= '1' when (prs_state = ASSIGN) else '0';

	-- ***************** COMPONENT ASSIGNMENTS *********************
	-- 8B/10B Decoder Function
	DEC_8B10B: DEC_FUNC
		port map(
			clk		=> clk,			
        		rst		=> rst,
	  		ain		=> ain,  	
			bin		=> bin,
	  		cin		=> cin,	
			din		=> din,		
	  		ein		=> ein,	
			iin		=> iin,
			fin		=> fin,		
	  		gin		=> gin,	
			hin		=> hin,	
			jin		=> jin,		  
	  		start_dec	=> start_dec,
	  		aout		=> aout,	
			bout		=> bout,	
	  		cout		=> cout,	
			dout		=> dout,	
	  		eout		=> eout,	
			fout		=> fout,	
			gout		=> gout,		
	  		hout		=> hout,
			kout		=> k_dec,	
	  		dec_done	=> dec_done );

	-- Error Checking Function
	ERR_CHK: ERR_CHECK
		port map(
			clk		=> clk,			
        		rst		=> rst,
	  		ain		=> ain,  	
			bin		=> bin,
	  		cin		=> cin,	
			din		=> din,		
	  		ein		=> ein,	
			iin		=> iin,
			fin		=> fin,		
	  		gin		=> gin,	
			hin		=> hin,	
			jin		=> jin,	
			start_dec	=> start_dec,
			errchk_done	=> errchk_done,		
	  		err_out		=> err_out );	
	

	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
            
        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: MAIN_DECODE ************************
    	-- Purpose: 	Main decoding control logic.  Asserts start_dec for
	--		DEC_FUNC and ERR_CHK state machines.  Waits for 10-bit 
	--		serial data to be decoded and free of errors before 
	--		asserting start_det which checks for errors in transmission
	--		of special characters at a 20B/16B decoding level.
	--		
    	-- Components:	none
        
    	MAIN_DECODE: process (prs_state, frame_in, dec_done, errchk_done)
    	begin
    
    	 	nxt_state <= prs_state;
		frame_out <= '0';
		start_det <= '0';
		ain <= '0';
		bin <= '0';
		cin <= '0';
		din <= '0';
		ein <= '0';
		iin <= '0';
		fin <= '0';
		gin <= '0';
		hin <= '0';
		jin <= '0';
		kout <= '0';
		data_out <= (others => '0');	    	

        	case prs_state is
        
        		------------------- IDLE State --------------------------
        		when IDLE =>
        		
        			-- Waits for valid data in the system
				-- Assertion of frame_in
        			if frame_in = '1' then
        				nxt_state <= ASSIGN;
        			end if;
        		
        	
      	  		------------------- ASSIGN State -----------------------
	      		when ASSIGN =>

				-- Start decoder and error check state machines 
				-- by asserting start_dec signal
				
				-- Brings data byte into module and assigns to
				-- corresponding ain .. jin
				ain <= data_in(9);
				bin <= data_in(8);
				cin <= data_in(7);
				din <= data_in(6);
				ein <= data_in(5);
				iin <= data_in(4);
				fin <= data_in(3);
				gin <= data_in(2);
				hin <= data_in(1);
				jin <= data_in(0);
			
				-- Waits for decoder to finish
				if (dec_done = '1') and (errchk_done = '1') then
					nxt_state <= DONE;
				end if;

					
			-------------------- DONE State -------------------
			when DONE =>
		
				-- Assign encoded data to output signal
				data_out(0) <= aout;
				data_out(1) <= bout;
				data_out(2) <= cout;
				data_out(3) <= dout;
				data_out(4) <= eout;
				data_out(5) <= fout;
				data_out(6) <= gout;
				data_out(7) <= hout;

				kout <= k_dec;
				
				-- Assert frame_out
				frame_out <= '1';

				-- Assert start signal to detect error in 16/20B transmission
				start_det <= '1';

				-- Wait for transition on frame_in signal
				if frame_in = '0' then
					nxt_state <= IDLE;
				end if;				
        		        	
        
			----------------------- DEFAULT -----------------------------
			when others =>
				nxt_state <= IDLE;	      
        	
        	        	
        end case;  
        
    end process MAIN_DECODE;


end BEHAVIOUR;


















