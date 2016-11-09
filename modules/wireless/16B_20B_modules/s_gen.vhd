-- **************************************************************************
-- Owner:		Xilinx Inc.
-- File:  		s_gen.vhd
--
-- Purpose: 		Creates S signal for encoding functionality.  Output signal
--			based on running disparity functions, l13, l31, din, and 
--			ein signals.  S control signal used for encoding fout and jout
--			data signals.
--	
-- Author:		Jennifer Jenkins
-- Date:		7-5-2000
--
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity S_GEN is
    port(
        
        	clk			: in STD_LOGIC;
        	rst			: in STD_LOGIC;
        	
		-- Data inputs D and E			
	  	din			: in STD_LOGIC;		
	  	ein			: in STD_LOGIC;		
	  	
		-- Input data terms	 
		pos_l13 		: in STD_LOGIC;		-- 1 one and 3 zeros signal in (A,B,C,D) 
	  	pos_l31			: in STD_LOGIC;		-- 3 ones and 1 zero signal in (A,B,C,D)	  
		dis_in			: in STD_LOGIC;		-- Disparity in to 8B/10B block
		nds6			: in STD_LOGIC;		-- Negative running disparity for 5B/6B 
		pds6			: in STD_LOGIC;		-- Positive running disparity for 5B/6B 

	  	-- Input control terms
	  	start_enc		: in STD_LOGIC;   	-- Asserted starts s function
	 	init_rdy		: in STD_LOGIC;		-- Asserted when initial configuration
								-- assignments have been made 	
		disfunc_rdy		: in STD_LOGIC;		-- Running disparity functions determined

		-- Output control terms
		s_done			: out STD_LOGIC;	-- Asserted when S signal is ready
	 
		-- Output data signals
		sout			: out STD_LOGIC		-- Output S signal
        
		);

end S_GEN;



architecture BEHAVIOUR of S_GEN is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, ASSIGN_S, DONE);
signal prs_state, nxt_state : STATE;

signal sout_com : STD_LOGIC;


begin

	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize GEN_S target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
			sout <= sout_com;
            
        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: GEN_S ************************
    	-- Purpose: 	Generate S output control signal.  State machine
	--		logic must wait for initial data classifications,
	--		i.e. pos_l31 and pos_l13.  The logic then waits for 
	--		the running disparity functions to be determined.
	--		the s_done signal is asserted in the DONE state for
	--		the ENC_FUNC logic.
	--		
    	-- Components:	none
        
    	GEN_S: process (prs_state, start_enc, init_rdy, disfunc_rdy)
    	begin
    
    	 	nxt_state <= prs_state;
		s_done <= '0';
		sout_com <= '0';
		    	
        	case prs_state is
        
        		----------------------- IDLE State -------------------------
        		when IDLE =>
        		
				-- Wait for assertion of init_rdy and disfunc_rdy
				-- to start GEN_S state machine
        			if (init_rdy = '1') and (disfunc_rdy = '1') then
        				nxt_state <= ASSIGN_S;
        			end if;
        		
		
			--------------------- ASSIGN_S State ------------------------
			when ASSIGN_S =>
				
				-- Assert s_done to represent the sout signal has been determined
				s_done <= '1';		

				sout_com <= ((pos_l31 and din and not(ein)) and (not(dis_in) or nds6 or pds6)) or
					    ((pos_l13 and ein and not(din)) and dis_in and not(nds6) and not(pds6));

				nxt_state <= DONE;


			--------------------- DONE State -------------------------
			when DONE =>
		
				-- Wait for the deassertion of the encoding signal
				if start_enc = '0' then
					nxt_state <= IDLE;
				end if;


			--------------------- DEFAULT State ------------------------
			when OTHERS =>
				nxt_state <= IDLE;	      
        	
        	        	
        end case;  
        
    end process GEN_S;


end BEHAVIOUR;











