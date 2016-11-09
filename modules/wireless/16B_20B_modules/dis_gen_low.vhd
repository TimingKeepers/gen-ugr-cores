-- *************************************************************************
-- Owner:		Xilinx Inc.
-- File:  		dis_gen_low.vhd
--
-- Purpose: 		8B/10B lower disparity generation module.  Controls 
--			disparity output signal for 8B/10B lower module.  
--			Intermediate stages include checking running disparity 
--			polarity for both 5B/6B and 3B/4B modules.  Asserts 
--			disfunc_rdy when these functions can be used in 
--			other modules.  Waits for disout_rdy from upper 
--			disparity module in 16B/20B combination.  
--	
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity DIS_GEN_LOW is
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
	  
	  -- Disparity Input Term 	 
	  disin_rdy		: in STD_LOGIC;			-- Asserted when dis_in is stable
	  dis_in		: in STD_LOGIC;			-- Disparity in for each 8B/10B module.
								-- In 16B/20B module, this is the disparity
								-- out of the upper to lower module or 
								-- lower to upper module.								
	  -- Control Term
	  start_enc		: in STD_LOGIC;   		-- Asserted starts encoding sequence
									
	  -- Disparity Output Terms
	  nds4			: inout STD_LOGIC;		-- Negative running disparity for 3B/4B module
	  pds4			: inout STD_LOGIC;		-- Positive running disparity for 3B/4B module
	  nds6			: inout STD_LOGIC;		-- Negative running disparity for 5B/6B module
	  pds6			: inout STD_LOGIC;		-- Positive running disparity for 5B/6B module
	  
 	  -- Output signals
	  disfunc_rdy		: out STD_LOGIC;		-- Asserted with running disparity functions
								-- have been assigned
	  dis_out		: out STD_LOGIC			-- Disparity out for 8B/10B block
        
          );

end DIS_GEN_LOW;


architecture BEHAVIOUR of DIS_GEN_LOW is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, DIS_FUNC, DIS_WAIT, DIS_ASGN, DONE);
signal prs_state, nxt_state : STATE;

signal dis_out_com : STD_LOGIC;

begin

	-- ****************** SIGNAL ASSIGNMENTS ***********************

	-- Running disparity functions (5B/6B & 3B/4B)
	nds4 <= (not(fin) and not(gin)) when (prs_state /= IDLE) else '0';

	pds4 <= (hin and gin and fin) when (prs_state /= IDLE) else '0';

	pds6 <= ((kin or ein) and
		 (kin or (not(din) and not(bin) and not(ain or cin)) or
		         ((bin and din and (ain or cin)) or
		          (ain and cin and (bin or din))))) when 
 	        (prs_state /= IDLE) else '0';

	nds6 <= (((not (ein or ((ain and cin) or (ain and bin) or (bin and cin)))) and not(din)) 
		  or ((not ((ain or bin or cin) and not(ain and bin and cin and not(ein)))) and din))
		when (prs_state /= IDLE) else '0';

	-- Running disparity out
	dis_out_com <= ((((pds4 and not(nds6) and not(pds6) and not(nds4)) or
		      (nds4 and not(nds6) and not(pds6) and not(pds4)) or
		      (pds6 and not(nds6) and not(nds4) and not(pds4)) or 
		      (nds6 and not(pds6) and not(nds4) and not(pds4))) and not(dis_in)) OR
		    ((((not(nds6) and not(pds6) and not(nds4) and not(pds4)) or
		       (pds6 and pds4 and not(nds6) and not(nds4)) or
		       (pds6 and nds4 and not(nds6) and not(pds4))) OR
		      ((nds6 and pds4 and not(pds6) and not(nds4)) or
		       (nds6 and nds4 and not(pds6) and not(pds4)))) and dis_in))
		   when ((prs_state = DIS_ASGN) or (prs_state = DONE)) else '0';
 

	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize ENC_FUNC target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
			dis_out <= dis_out_com;

        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: DISGEN ************************
    	-- Purpose:  	Generate the running disparity functions for each
    	--		5B/6B and 3B/4B modules and the disparity out for 
    	--		each 8B/10B module.
	--		
    	-- Components:	none
        
    	DISGEN: process (prs_state, start_enc, disin_rdy)
    	begin
    
    	 	nxt_state <= prs_state;	
		disfunc_rdy <= '1';
		    	
        	case prs_state is
        
        		----------------------- IDLE State -------------------------
        		when IDLE =>

				-- Asserted when disparity functions assigned
				disfunc_rdy <= '0';

				-- Waits for go signal from main control logic,
				-- assertion of start_enc
        			if start_enc = '1' then
        				nxt_state <= DIS_FUNC;
        			end if;
        		
        	
      	  		---------------------- DIS_FUNC State -------------------------
	      		when DIS_FUNC =>
			
				-- Create running disparity functions and
				-- assert disfunc_rdy to signal the running disparity
				-- functions have been assigned			
				nxt_state <= DIS_WAIT;
					
				
		
			--------------------- DIS_WAIT State ------------------------
			when DIS_WAIT =>
				
				-- Wait for disparity out of upper module to stablize
				if disin_rdy = '1' then
					nxt_state <= DIS_ASGN;
				end if;

		
			--------------------- DIS_ASGN State ------------------------
			when DIS_ASGN =>
		
				-- Assign running disparity out function					
				nxt_state <= DONE;

        	
			--------------------- DONE State -------------------------
			when DONE =>
		
				-- Wait for encoding signal to be deasserted
				if start_enc = '0' then
					nxt_state <= IDLE;
				end if;


			--------------------- DEFAULT State ------------------------
			when OTHERS =>
				nxt_state <= IDLE;	      
        	
        	        	
        end case;  
        
    end process DISGEN;


end BEHAVIOUR;












