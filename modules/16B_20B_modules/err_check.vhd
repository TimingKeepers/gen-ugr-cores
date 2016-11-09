-- **************************************************************************
-- Owner:		Xilinx Inc.
-- File:  		err_check.vhd
--
-- Purpose: 		8B/10B error checking module.  Asserts the error flag
--			when the incoming serial stream has an error.  Does not
--			check for errors involving special characters.
--	
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ERR_CHECK is
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
	  err_out		: out STD_LOGIC			-- Asserted when error has been detected

          );

end ERR_CHECK;



architecture BEHAVIOUR of ERR_CHECK is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, PREL, ERROR_CHK, DONE);
signal prs_state, nxt_state : STATE;

signal err_cl1, err_cl2, err_cl3 : STD_LOGIC;

begin


	-- ******************** SIGNAL ASSIGNMENTS **********************
	err_cl1 <= ((ain and bin and cin and din) or
		   (((ain and bin and iin) or (cin and din) or fin or
		     ((ain or bin) and (cin or din))) and
		    (not(not(gin) or not(jin) or not(hin) or ein))))
			when ((prs_state = PREL) or (prs_state = ERROR_CHK)) else '0';


	err_cl2 <= ((not(cin or din) or not(fin) or
		    not((ain or bin or iin) and ((ain and bin) or (cin and din)))) and
		   (not(not(ein) or gin or hin or jin)))
			when ((prs_state = PREL) or (prs_state = ERROR_CHK)) else '0';

	err_cl3 <= ((((not(cin and din) and not(ain or bin)) or
		     (not(ain or bin or cin or din)) or
		     (not(fin or gin or hin))) and not(iin) and not(ein)) OR
		   (gin and hin and jin and not(iin) and ein) OR
		   ((not(gin or hin or jin)) and iin and not(ein)) OR
		   (((fin and gin and hin) or
		     (cin and din and (ain or bin)) or
		     (ain and bin and (cin or din))) and iin and ein))
		   when ((prs_state = PREL) or (prs_state = ERROR_CHK)) else '0';


	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize ENC_FUNC target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
            
        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: ERR_CHK ************************
    	-- Purpose: 	Detect transmission error in data bits, ain through
	--		jin.  Does not check for special characters.
	--		
    	-- Components:	none
        
    	ERR_CHK: process (prs_state, start_dec)
    	begin
    
    	 	nxt_state <= prs_state;
		errchk_done <= '0';
		err_out <= '0';
			    	
        	case prs_state is
        
        		----------------------- IDLE State -------------------------
        		when IDLE =>
        	
        			-- Waits for go signal from main control logic
				-- Assertion of start_dec
        			if start_dec = '1' then
        				nxt_state <= PREL;
        			end if;
        		
			---------------------- PREL State -------------------------
	      		when PREL =>
			
				-- Generate preliminary output error signals				
				nxt_state <= ERROR_CHK;
	      	

      	  		---------------------- ERROR_CHK State -------------------------
	      		when ERROR_CHK =>
			
				-- Generate the output data 
				err_out <= (not(ain or bin) and not(cin or din)) or 
					   err_cl1 or err_cl2 or err_cl3;
				
				-- Assert decode done signal
				errchk_done <= '1';	
		
				nxt_state <= DONE;


			--------------------- DONE State -------------------------
			when DONE =>
		
				-- Wait for encoding signal to be deasserted
				if start_dec = '0' then
					nxt_state <= IDLE;
				end if;


			--------------------- DEFAULT State ------------------------
			when OTHERS =>
				nxt_state <= IDLE;	      
        	
        	        	
        end case;  
        
    end process ERR_CHK;


end BEHAVIOUR;


















