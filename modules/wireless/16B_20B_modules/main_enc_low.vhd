-- **************************************************************
-- Owner:		Xilinx Inc.
-- File:  		main_enc_low.vhd
--
-- Purpose: 		Main 8B/10B encoder description.  This encoder
--			can be used for fiber channel implementations.
--			Controls encoding, disparity and s_gen
--			modules in determining the 10-bit serial output 
--			encoded data.
--	
-- Author:		Jennifer Jenkins
-- Date:		7-5-2000
--		
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ENCODER_LOW is
    port(
        
          clk			: in STD_LOGIC;
          rst			: in STD_LOGIC;
        
          -- Protocol Device Interface                      
	  data_in		: in STD_LOGIC_VECTOR(7 downto 0);   	-- Parallel byte of incoming data
	  k_char		: in STD_LOGIC;				-- Asserted specifies the transmission of 
									-- a special character
	  frame_in 		: in STD_LOGIC;				-- Asserted when parallel data is stable
		  	 
	  -- Disparity I/O
	  disin_rdy		: in STD_LOGIC;				-- Asserted when dis_in is stable
	  dis_in		: in STD_LOGIC;			   	-- Disparity in
	  dis_out		: out STD_LOGIC;		  	-- Disparity out

	  -- Encoder outputs
	  encoded_data		: out STD_LOGIC_VECTOR(9 downto 0);  	-- Encoded data to send out
	  frame_out		: out STD_LOGIC				-- Asserted when data is encoded and ready
									-- to be sent through the external serializer	  

        );

end ENCODER_LOW;



architecture BEHAVIOUR of ENCODER_LOW is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, ASSIGN, WAITING, DONE);
signal prs_state, nxt_state : STATE;

--------------------------- Encoder Logic ----------------------------
-- Starting signal for encoder, disparity, and s_gen logic
signal start_enc : STD_LOGIC;

-- Assignment and ending signals from encoder logic
signal init_rdy, assign_rdy, enc_done : STD_LOGIC;

-- Zero and One detect signals
signal l13, l31 : STD_LOGIC;			

-------------------------- Disparity Logic --------------------------
signal disfunc_rdy : STD_LOGIC;

-- Disparity Functions (positive and negative running disparity for
-- each 5B/6B and 3B/4B module)
signal nds4, pds4, nds6, pds6	: STD_LOGIC;

----------------------- S Generator Logic ----------------------------
signal s_term, s_done : STD_LOGIC;

-- Assinged from incoming parallel data byte
signal  ain, bin, cin, din, ein, fin, gin, hin : STD_LOGIC;

-- Preliminary output signals for b, c, d, and e
--signal b_prel, c_prel, d_prel, e_prel : STD_LOGIC;


-- ******************** COMPONENT DECLARATION ***********************
-- 8B/10B Encoder Function
component ENC_FUNC
	port(
		clk			: in STD_LOGIC;
        	rst			: in STD_LOGIC;

	  	ain			: in STD_LOGIC;		-- Data Inputs (AIN .. HIN)			
	  	bin			: in STD_LOGIC;
	  	cin			: in STD_LOGIC;			
	  	din			: in STD_LOGIC;
	  	ein			: in STD_LOGIC;			
	  	fin			: in STD_LOGIC;
	  	gin			: in STD_LOGIC;			
	  	hin			: in STD_LOGIC;  
	  	kin			: in STD_LOGIC;	
 	  	sin			: in STD_LOGIC;		-- S Signal input from S_GEN
	  	start_enc		: in STD_LOGIC;   	-- Asserted starts encoding sequence
	  	s_done			: in STD_LOGIC;		-- Asserted when S signal is ready

	  							-- Outputs for S_GEN state machine
	  	pos_l13 		: inout STD_LOGIC;	-- 1 one and 3 zeros signal in (A,B,C,D) 
	  	pos_l31			: inout STD_LOGIC;	-- 3 ones and 1 zero signal in (A,B,C,D)

	  	do			: out STD_LOGIC_VECTOR(9 downto 0);  -- Output data term (AOUT .. JOUT)
	
		init_rdy		: out STD_LOGIC;	-- Asserted when initial configurations made
	  	enc_done		: out STD_LOGIC);	-- Asserted when encoding is complete, 
								-- provides handshaking to main control logic

end component;


-- Disparity Generator
component DIS_GEN_LOW
    port(
        
          	clk			: in STD_LOGIC;
          	rst			: in STD_LOGIC;

          	-- Data Inputs (AIN .. HIN)
	  	ain			: in STD_LOGIC;			
	  	bin			: in STD_LOGIC;
	  	cin			: in STD_LOGIC;			
	  	din			: in STD_LOGIC;
	  	ein			: in STD_LOGIC;			
	  	fin			: in STD_LOGIC;
	 	gin			: in STD_LOGIC;			
	 	hin			: in STD_LOGIC;  
	 	kin			: in STD_LOGIC;	
	  
	 	 -- Disparity Input Terms 
		disin_rdy		: in STD_LOGIC;		-- Asserted when dis_in is stable	 
	  	dis_in			: in STD_LOGIC;		-- Disparity in for each 8B/10B module.
								-- In 16B/20B module, this is the disparity
								-- out of the upper to lower module or 
								-- lower to upper module.								
	  	-- Control terms
	  	start_enc		: in STD_LOGIC;   	-- Asserted starts encoding sequence
									
	  	-- Disparity Output Terms
	  	nds4			: inout STD_LOGIC;	-- Negative running disparity for 3B/4B module
	  	pds4			: inout STD_LOGIC;	-- Positive running disparity for 3B/4B module
	  	nds6			: inout STD_LOGIC;	-- Negative running disparity for 5B/6B module
	  	pds6			: inout STD_LOGIC;	-- Positive running disparity for 5B/6B module
	  
 	  	-- Output signals
	  	disfunc_rdy		: out STD_LOGIC;	-- Asserted with running disparity functions
								-- have been assigned								
	  	dis_out			: out STD_LOGIC		-- Disparity out for each 8B/10B block
        
          	);

end component;


-- S Signal Generator
component S_GEN
	port(      
        	clk			: in STD_LOGIC;
        	rst			: in STD_LOGIC;
	  	din			: in STD_LOGIC;		-- Data inputs D and E	
	  	ein			: in STD_LOGIC;		
	 	pos_l13 		: in STD_LOGIC;		-- 1 one and 3 zeros signal in (A,B,C,D) 
	  	pos_l31			: in STD_LOGIC;		-- 3 ones and 1 zero signal in (A,B,C,D)	  
		dis_in			: in STD_LOGIC;		-- Disparity in to 8B/10B block
		nds6			: in STD_LOGIC;		-- Negative running disparity for 5B/6B 
		pds6			: in STD_LOGIC;		-- Positive running disparity for 5B/6B 

	  	-- Input control terms
	  	start_enc		: in STD_LOGIC;   	-- Asserted starts s function	  	
		init_rdy		: in STD_LOGIC;		-- Asserted when initial configurations made
		disfunc_rdy		: in STD_LOGIC;		-- Running disparity functions determined

		-- Output control terms
		s_done			: out STD_LOGIC;	-- Asserted when S signal is ready
		sout			: out STD_LOGIC);	-- Output S signal

end component;



begin

	-- ****************** SIGNAL ASSIGNMENTS ***********************
	start_enc <= '1' when (prs_state = ASSIGN) else '0';

	-- ***************** COMPONENT ASSIGNMENTS *********************
	-- 8B/10B Encoder Function
	ENC_8B_10B: ENC_FUNC
		port map(
			clk		=> clk,			
        		rst		=> rst,
	  		ain		=> ain,  	
			bin		=> bin,
	  		cin		=> cin,	
			din		=> din,		
	  		ein		=> ein,	
			fin		=> fin,		
	  		gin		=> gin,	
			hin		=> hin,			  
	  		kin		=> k_char,			 	
 	  		sin		=> s_term,		 
	  		start_enc	=> start_enc,	 
	  		s_done		=> s_done,	
	 	  	pos_l13 	=> l13,	
	  		pos_l31		=> l31,	  	  
	  		do		=> encoded_data,
			init_rdy	=> init_rdy,		
	  		enc_done	=> enc_done);

	-- Disparity Generator
	DIS_FUNC: DIS_GEN_LOW
		port map(        
          		clk		=> clk,			
        		rst		=> rst,
	  		ain		=> ain,  	
			bin		=> bin,
	  		cin		=> cin,	
			din		=> din,		
	  		ein		=> ein,	
			fin		=> fin,		
	  		gin		=> gin,	
			hin		=> hin,			  
	  		kin		=> k_char,
			disin_rdy	=> disin_rdy,			
	  		dis_in		=> dis_in,					
	  	  	start_enc	=> start_enc,
	  		nds4		=> nds4,	
	  		pds4		=> pds4,
	  		nds6		=> nds6,	
	  		pds6		=> pds6,	
	  		disfunc_rdy	=> disfunc_rdy, 									
	  		dis_out		=> dis_out);


	-- S Signal Generator 
	S_FUNC: S_GEN
		port map(      
        		clk		=> clk,	
      	  		rst		=> rst,	
	  		din		=> din,		
	  		ein		=> ein,	
	 		pos_l13 	=> l13,	
	  		pos_l31		=> l31,	  
			dis_in 		=> dis_in,
			nds6		=> nds6,
	  		pds6		=> pds6,	  		
	  		start_enc	=> start_enc,	
			init_rdy	=> init_rdy,	
	  		disfunc_rdy	=> disfunc_rdy,			
			s_done		=> s_done,
			sout		=> s_term);



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
    
    
    
    	-- ******************** Process: MAIN_ENCODE ************************
    	-- Purpose: 	Main encoding control logic.  Synchronize control logic 
	-- 		for encoding 16-bit parallel data to 20-bit serial stream 
	--		of data in accordance to 8B/10B encoding rules.  Initializes
	--		start signal for disparity and encoding function
	--		generators.  Waits for end of encode signal and asserts
	--		frame_out when encoded_data is ready.
	--		
    	-- Components:	none
        
    	MAIN_ENCODE: process (prs_state, frame_in, enc_done)
    	begin
    
    	 	nxt_state <= prs_state;

		ain <= data_in(0);
		bin <= data_in(1);
		cin <= data_in(2);
		din <= data_in(3);
		ein <= data_in(4);
		fin <= data_in(5);
		gin <= data_in(6);
		hin <= data_in(7);
		frame_out <= '0';	
    	
        	case prs_state is
        
        		------------------- IDLE State --------------------------
        		when IDLE =>

				-- Reset input data signals
				ain <= '0';
				bin <= '0';
				cin <= '0';
				din <= '0';
				ein <= '0';
				fin <= '0';
				gin <= '0';
				hin <= '0';

				-- Waits for valid data in the system
				-- Assertion of frame_in
        			if frame_in = '1' then
        				nxt_state <= ASSIGN;        			
        			end if;
        		
        	
      	  		------------------- ASSIGN State -----------------------
	      		when ASSIGN =>

				-- Start encoder, disparity, and sgen
				-- state machines by asserting start_enc signal,
				-- and bring data byte into module and assign to
				-- corresponding AIN .. HIN				
			
				-- Waits for encoder to finish
				if enc_done = '1' then
					nxt_state <= DONE;
				end if;

					
			-------------------- DONE State -------------------
			when DONE =>
				
				-- Assert frame_out
				frame_out <= '1';

				-- Wait for transition on frame_in signal
				if frame_in = '0' then
					nxt_state <= IDLE;
				end if;				
        		        	
        
			----------------------- DEFAULT -----------------------------
			when others =>
				nxt_state <= IDLE;	      
        	        	
        end case;  
        
    end process MAIN_ENCODE;
  
end BEHAVIOUR;
















