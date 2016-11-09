-- **************************************************************************
-- Owner:		Xilinx Inc.
-- File:  		dec_func.vhd
--
-- Purpose: 		Main 8B/10B decoder function.  Decodes serial data
--			stream following 5B/6B and 3B/4B encoding schemes.  Decodes
--			incoming 10-bit transmitted serial data stream of ain .. jin
--			to byte wide data AOUT .. HOUT.  Incoming data includes control
--			characters i and j.  Detects transmission of special characters 
--			and asserts KOUT respectively.
--
-- Author:		Jennifer Jenkins
-- Date:		3-31-2000
--
-- **************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity DEC_FUNC is
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
	  	
	  -- Output data terms (AOUT .. HOUT)
	  aout			: out STD_LOGIC;
	  bout			: out STD_LOGIC;
	  cout			: out STD_LOGIC;
	  dout			: out STD_LOGIC;
	  eout			: out STD_LOGIC;
	  fout			: out STD_LOGIC;
	  gout			: out STD_LOGIC;
	  hout			: out STD_LOGIC;

	  kout			: out STD_LOGIC;		-- Asserted when special character
								-- is detected in transmission
	  -- Output signals
	  dec_done		: out STD_LOGIC			-- Asserted when encoding is complete, 
								-- provides handshaking to main control logic
          );

end DEC_FUNC;



architecture BEHAVIOUR of DEC_FUNC is

-- ******************** CONSTANT DECLARATIONS ***********************
constant RESET_ACTIVE 	: STD_LOGIC := '0';


-- ********************* SIGNAL DECLARATIONS ************************

-- Define states for download state machine
type STATE is (IDLE, PREL, DECODE, DONE);
signal prs_state, nxt_state : STATE;

-- Preliminary output signals
signal a_cl1, a_cl2, a_cl3 : STD_LOGIC;
signal b_cl1, b_cl2, b_cl3 : STD_LOGIC;
signal c_cl1, c_cl2, c_cl3 : STD_LOGIC;
signal d_cl1, d_cl2, d_cl3 : STD_LOGIC;
signal e_cl1, e_cl2, e_cl3 : STD_LOGIC;
signal f_sel1, f_sel2 : STD_LOGIC;
signal g_cl1, g_cl2 : STD_LOGIC;
signal h_cl1, h_cl2 : STD_LOGIC;
signal k_cl1, k_cl2 : STD_LOGIC;

-- Output combinational signals
signal aout_com, bout_com, cout_com, dout_com : STD_LOGIC;
signal eout_com, fout_com, gout_com, hout_com, kout_com : STD_LOGIC;


begin

	-- **************** SIGNAL ASSIGNMENTS *************************
	a_cl1 <= ((ein or not(iin) or (not(cin xor bin) or din)) and
		 (ein or not(bin and din and
		 (not(iin or cin) or (not(ain) and iin and cin)))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	a_cl2 <= ((not(ein) or ((din or bin) and (iin or cin))) and
		 (iin or (not(cin) or (din and bin))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	a_cl3 <= (not(cin) and din and iin and not(((ain and ein) or (bin and not(ein)))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	b_cl1 <= ((not(bin) and (din xor ein) and iin) or not(iin or din or ein)) 
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	b_cl2 <= (bin and not(iin) and 
		 not(((ain and cin) or not(din or ein)) and (not(ein) or din)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	b_cl3 <= (not((not((bin and ein) or (bin and din) or (iin and din)) or ain or cin) and
		    (din or ein or not(iin) or not(ain xor cin))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	c_cl1 <= (not(ain) and din and iin and (not(bin) or (not(cin) and ein)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	c_cl2 <= (not((ain and bin and not(cin) and din and iin) or
		 (not(iin or not(bin) or not(ain xor din))) or
		 (not(din) and ((not(ain) and bin and iin) or (ain and not(bin) and iin)))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	c_cl3 <= (cin and not(((not(ain) and not(ein)) or (ain and bin) or iin) and
			     ((iin and bin) or din or not(ein))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	d_cl1 <= ((not(ain) and (din or (iin and not(ein))) and (cin xor bin)) or
		 (ain and (cin xor bin) and ((not(din) and ein and iin) or
					     (not(ein) and not(iin)))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	d_cl2 <= (not(ein or not(iin) or (not(ain and not(bin) and not(cin)) and
					 (not(ain) or not(bin) or not(cin) or din))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';
 
	d_cl3 <= ((not(bin) and ein) or (bin and not(ain and cin)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

				
	e_cl1 <= ((not(iin) and bin and ((ain and not(cin) and not(din)) or 
				(ein and (ain xor cin)))) or
		 (not(bin or not(din) or ((not(ain) or not(ein) or iin) and
					  ((ain or cin or ein or not(iin)))))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';
					       
	e_cl2 <= ((cin and not((ain or (bin and din) or (not(bin) and not(iin))) and
			      ((iin and bin) or not(ain) or din))) or
		 not(cin or din or not(bin) or not(iin)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	e_cl3 <= ((cin or ain or not(bin)) and (bin or not(ain xor cin)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	f_sel1 <= (not(hin and not(iin or ein or din or cin)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	f_sel2 <= (hin or not(iin or ein or din or cin))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

				
	g_cl1 <= (((not(not(fin) or (hin and (iin or ein or din or cin)))) or
		  fin or (hin and (iin or ein or din or cin))) and
		 ((not(not(fin) or (hin and (iin or ein or din or cin)))) or
		  gin))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	g_cl2 <= (not((fin or not(iin or ein or hin or din or cin)) and
		 ((gin or hin or iin or ein or din or cin) and (gin or fin))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	h_cl1 <= (not((jin and not(iin or ein or din or cin)) or 
		     (fin and not(jin or gin))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	h_cl2 <= ((hin and not(jin) and (iin or ein or din or cin)) or 
		 ((hin xor jin) and not(gin xor fin)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';


	k_cl1 <= (not(((ain xor bin) and cin and din) or 
		     (ain and bin and not(iin or not(din xor cin)))))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';

	k_cl2 <= ((not(ain or bin) and (iin and (din xor cin))) or 
		 ((ain xor bin) and not(cin or din)))
		when ((prs_state = PREL) or (prs_state = DECODE)) else '0';



	-- ***************** Process: SEQUENTIAL ************************
	-- Purpose:  	Synchronize ENC_FUNC target state machine
	-- Components: 	none
    
    	SEQUENTIAL: process (rst, clk)
    	begin
       	 	if rst = RESET_ACTIVE then	
         	   	prs_state <= IDLE;
            
       	 	elsif clk'event and (clk = '1') then
         	   	prs_state <= nxt_state;
			aout <= aout_com;
			bout <= bout_com;
			cout <= cout_com;
			dout <= dout_com;
			eout <= eout_com;
			fout <= fout_com;
			gout <= gout_com;
			hout <= hout_com;
			kout <= kout_com;
            
        	end if;

    	end process SEQUENTIAL;
    
    
    
    	-- ******************** Process: DECFUNC ************************
    	-- Purpose: 	Decoding control logic.  Synchronize control logic 
	-- 		for decoding data inputs.  Asserts dec_done when 
	--		decoding is completed.
	--		
    	-- Components:	none
        
    	DECFUNC: process (prs_state, start_dec)
    	begin
    
    	 	nxt_state <= prs_state;
		dec_done <= '0';
		aout_com <= '0';
		bout_com <= '0';
		cout_com <= '0';
		dout_com <= '0';
		eout_com <= '0';
		fout_com <= '0';
		gout_com <= '0';
		hout_com <= '0';
		kout_com <= '0';
			    	
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

				-- Generate preliminary output signals for aout .. hout
				nxt_state <= DECODE;


      	  		---------------------- DECODE State -------------------------
	      		when DECODE =>
			
				-- Generate the output data 
				aout_com <= (not(a_cl2) and ain) or
					not(a_cl1) or a_cl3;
				bout_com <= (b_cl1 and ain and cin) or
					b_cl2 or b_cl3;
				cout_com <= not((ein or c_cl2) and not(c_cl1) and not(c_cl3));
				dout_com <= (d_cl3 and din and not(iin)) or
					d_cl1 or d_cl2;
				eout_com <= (ein and e_cl2) or (not(e_cl3) and (din xor iin)) or e_cl1;
				
				if jin = '0' then
					if f_sel1 = '0' then
						fout_com <= gin;
					else 	fout_com <= fin;
					end if;
			
					gout_com <= g_cl1;

				else	-- jin = '1'
					if f_sel2 = '0' then
						fout_com <= not(gin);
					else 	fout_com <= not(fin);
					end if;

					gout_com <= g_cl2;

				end if;				
				
				hout_com <= not((h_cl1 or hin) and not(h_cl2) and
					    not(not(fin) and gin and hin and jin));

				if ein = '0' then
					kout_com <= (gin and hin and jin and k_cl2) or (not(cin or din or iin));
				else   	-- ein = '1'
					kout_com <= not(((jin or hin) or k_cl1 or gin) and 
						    (not(cin and din and iin)));
				end if;

				-- Assert decode done signal
				dec_done <= '1';			
				
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
        
    end process DECFUNC;


end BEHAVIOUR;
































