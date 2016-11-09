-- **************************************************************************
-- Owner:		Xilinx Inc.
-- File:  		enc_func.vhd
--
-- Purpose: 		Main 8B/10B encoder functionality.  Follows rules
--			for both 5B/6B and 3B/4B encoding schemes.  Encodes
--			incoming data AIN .. HIN into AOUT .. HOUT using 
--			disparity functions and sout.
--	
-- Author:		Jennifer Jenkins
-- Date:		7-5-2000
--
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ENC_FUNC is
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
	
 	  sin			: in STD_LOGIC;			-- S Signal input from S_GEN

	  -- Control terms
	  start_enc		: in STD_LOGIC;   		-- Asserted starts encoding sequence
	  s_done		: in STD_LOGIC;			-- Asserted when S signal is ready
	  
	  -- Outputs for S_GEN state machine
	  pos_l13 		: inout STD_LOGIC;		-- 1 one and 3 zeros signal in (A,B,C,D) 
	  pos_l31		: inout STD_LOGIC;		-- 3 ones and 1 zero signal in (A,B,C,D)

 	  -- Output data terms (AOUT .. JOUT)
	  do			: out STD_LOGIC_VECTOR(9 downto 0);

	  -- Output signals
	  init_rdy		: out STD_LOGIC;		-- Asserted when initial input 
								-- configurations determined
	  enc_done		: out STD_LOGIC			-- Asserted when encoding is complete, 
								-- provides handshaking to main control logic
          );

end ENC_FUNC;



architecture BEHAVIOUR of ENC_FUNC is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, ENCODE, S_INPUT, ASSIGN, DONE);
signal prs_state, nxt_state : STATE;

-- Encoder function variables for A,B,C,D
-- (ain not equal to bin) and (cin not equal to din)
signal a_neq_b, c_neq_d : STD_LOGIC;
 
-- (2 ones and 2 zeros)
signal pos_l22 : STD_LOGIC;

-- (4 ones and 0 zeros)
signal pos_l40 : STD_LOGIC;

-- (0 ones and 4 ones)
signal pos_l04 : STD_LOGIC;

-- 3B/4B encoder function (f and g and h)
signal fgh_and : STD_LOGIC;

-- Intermediate combinational signals
signal b_prel, c_prel, d_prel, e_prel : STD_LOGIC;
signal b_prel_com, c_prel_com, d_prel_com, e_prel_com : STD_LOGIC;
signal do_com : STD_LOGIC_VECTOR(9 downto 0);
 
begin


	-- ********************* SIGNAL ASSIGNMENTS ********************
	a_neq_b <= ((not(ain) and not(bin)) or (ain and bin)) when 
		   ((prs_state = ENCODE) or (prs_state = S_INPUT) or 
		    (prs_state = ASSIGN)) else '0';

	c_neq_d <= ((not(cin) and not(din)) or (cin and din)) when 
		   ((prs_state = ENCODE) or (prs_state = S_INPUT) or 
		    (prs_state = ASSIGN)) else '0';

	pos_l22 <= ((ain and bin and not(cin) and not(din)) or
		    (not(ain) and not(bin) and cin and din) or
		    (not(a_neq_b) and not(c_neq_d))) 
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';
			
	pos_l40 <= (ain and bin and cin and din) 
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';
	
	pos_l04 <= (not(ain) and not(bin) and not(cin) and not(din)) 
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';

	pos_l13 <= ((not(a_neq_b) and (not(cin) and not(din))) or
		    (not(c_neq_d) and (not(ain) and not(bin)))) 
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';

	pos_l31 <= ((not(a_neq_b) and (cin and din)) or
		    (not(c_neq_d) and (ain and bin))) 
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';
	
	fgh_and <= (fin and gin and hin)  
		   when ((prs_state = S_INPUT) or (prs_state = ASSIGN)) else '0';



	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize ENC_FUNC target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
			b_prel <= b_prel_com;
			c_prel <= c_prel_com;
			d_prel <= d_prel_com;
			e_prel <= e_prel_com;
			do <= do_com;
            
        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: ENC_FUNC ************************
    	-- Purpose: 	Encoding control logic.  Synchronize control logic 
	-- 		for encoding data inputs.  Get S control signal from 
	--		the S_GEN function.
	--
    	-- Components:	none
        
    	ENC_FUNC: process (prs_state, start_enc, s_done)
    	begin
    
    	 	nxt_state <= prs_state;
		init_rdy <= '0';
		enc_done <= '0';
		b_prel_com <= '0';
		c_prel_com <= '0';
		d_prel_com <= '0';
		e_prel_com <= '0';
		do_com <= (others => '0');

			    	
        	case prs_state is
        
        		----------------------- IDLE State -------------------------
        		when IDLE =>
        		
				-- Waits for go signal from main control logic
				-- Assertion of start_enc
        			if start_enc = '1' then
        				nxt_state <= ENCODE;
        			end if;
        		
        	
      	  		---------------------- ENCODE State -------------------------
	      		when ENCODE =>
			
				-- Generate the pre-encode signals			
				nxt_state <= S_INPUT;
				
		
			--------------------- S_INPUT State ------------------------
			when S_INPUT =>
		
				-- Generate initial encoding functions (5B/6B & 3B/4B)
				-- and assert init_rdy that initial encoding signals
				-- are assigned
				init_rdy <= '1';

				-- Make initial output assignments 
				b_prel_com <= (not(pos_l40) and bin) or pos_l04;
				c_prel_com <= pos_l04 or cin or (pos_l13 and ein and din);
				d_prel_com <= not (pos_l40 or not(din));
				e_prel_com <= (pos_l13 and not(ein)) or
					    (ein and (not(pos_l13) or not(ein) or not(din)));			
							
				-- Wait for S signal input
				if s_done = '1' then
					nxt_state <= ASSIGN;
				elsif s_done = '0' then
					nxt_state <= S_INPUT;
				end if;				
        		        	

        		--------------------- ASSIGN State -------------------------
			when ASSIGN =>

				-- Make signal output assignments		
				do_com(9) <= ain;
				do_com(8) <= b_prel;
				do_com(7) <= c_prel;
				do_com(6) <= d_prel;
				do_com(5) <= e_prel;
				do_com(4) <= (not(ein) and pos_l22) or (pos_l22 and kin) or
				             (pos_l04 and ein) or (ein and pos_l40) or
				             (ein and pos_l13 and not(din));		
				do_com(3) <= not(not(fin) or ((fgh_and and sin) or (fgh_and and kin)));
				do_com(2) <= gin or (not(fin) and not(gin) and not(hin));
				do_com(1) <= hin;
				do_com(0) <= ((fgh_and and sin) or (fgh_and and kin)) or 
				         	 (not((not(fin) and not(gin)) or 
				                 (fin and gin)) and not(hin));

				-- Assert enc_done to signal done with encoding 
				-- to main control logic
				enc_done <= '1';

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
        
    end process ENC_FUNC;


end BEHAVIOUR;






















