library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity fq is
	PORT (
        rst_i       : in   STD_LOGIC;
        ref_status  : in   STD_LOGIC;
        phase_error : in   STD_LOGIC_VECTOR(20 downto 0);
        rstcnt      : in   STD_LOGIC;
        vcoclk      : in   STD_LOGIC; 
        vc          : out  STD_LOGIC_VECTOR(21 downto 0)
        );
end fq;
 
architecture Behavioral of fq is

    signal phase_error_prev   : std_logic;
    signal vco_ref            : signed(21 downto 0) := to_signed(2097152, 22);
    signal vco_o              : signed(21 downto 0) := to_signed(2097152, 22);
    signal vco_ref_bis        : signed(21 downto 0) := to_signed(2097152, 22);
    signal vco_min            : signed(21 downto 0) := to_signed(-2097150, 22);
    signal vco_max            : signed(21 downto 0) := to_signed(2097152, 22);
    signal lock_cntr          : unsigned(19 downto 0) := to_unsigned(0, 20);
    signal lock_ref           : unsigned(19 downto 0) := to_unsigned(0, 20);
    signal lock_ref_bis       : unsigned(19 downto 0) := to_unsigned(0, 20);
    signal locked             : std_logic;
    signal locked_cntr        : unsigned(6 downto 0) := to_unsigned(0, 7);
    signal locked_ref         : unsigned(6 downto 0) := to_unsigned(0, 7);
    
    attribute mark_debug : string;
    attribute mark_debug of vco_ref: signal is "true";
    attribute mark_debug of vco_o: signal is "true";
    attribute mark_debug of lock_ref: signal is "true";
    attribute mark_debug of vco_min: signal is "true";
    attribute mark_debug of vco_max: signal is "true";
    attribute mark_debug of lock_cntr: signal is "true";
    attribute mark_debug of locked: signal is "true";
    attribute mark_debug of vco_ref_bis: signal is "true";
    attribute mark_debug of lock_ref_bis: signal is "true";
    attribute mark_debug of phase_error_prev: signal is "true";
 
begin
 
    main_adjust : process(rstcnt, rst_i)
    begin
      if(rst_i = '0' or ref_status = '1') then
        phase_error_prev <= '0';
        vco_ref          <= to_signed(2097151, 22);
        vco_o            <= to_signed(2097151, 22);
        vco_ref_bis      <= to_signed(2097151, 22);
        lock_cntr        <= to_unsigned(0, 20);
        lock_ref         <= to_unsigned(0, 20);
        lock_ref_bis     <= to_unsigned(0, 20);
        locked           <= '0';
        vco_min          <= to_signed(-2097150, 22);
        vco_max          <= to_signed(2097151, 22);
        locked_cntr      <= to_unsigned(0, 7);
        locked_ref       <= to_unsigned(0, 7);
      -- each phase comparation value
      elsif rising_edge(rstcnt) then
        -- The phase interpolator starts with the lowest frequency
        if (locked = '0') then
            -- We check transition from positive to negative, 0º shift between ref and vco clocks
            if (phase_error(20) = '1' and phase_error_prev = '0') then
                if (lock_cntr >= lock_ref) then
                    vco_ref <= vco_o;
                    lock_ref <= lock_cntr;
                elsif (lock_cntr > lock_ref) then
                    vco_ref_bis <= vco_o;
                    lock_ref_bis <= lock_cntr;
                end if;
                if ((vco_o - to_signed(1000, 22)) > to_signed(-2096150, 22)) then
                    vco_o <= vco_o - to_signed(1000, 22);
                else
                    vco_o <= vco_ref;
                    locked <= '1';
                    vco_min <= vco_ref - to_signed(20000, 22);
                    vco_max <= vco_ref + to_signed(20000, 22);
                end if;
                lock_cntr <= to_unsigned(0, 20);
            -- Phases match
            else
                lock_cntr <= lock_cntr + to_unsigned(1, 10);
                if (lock_ref > to_unsigned(1048570, 20)) then
                    locked <= '1';
                end if;
            end if;
        else
            -- After locked, if the vco clock delays
            if (phase_error(20) = '1') then
--                if (vco_o > vco_ref) then
--                    vco_o <= vco_ref;
--                else
                    -- Hysteresis to converge to a central value
                    if (vco_o > vco_min + to_signed(6000, 22)) then
                        vco_o <= vco_o - to_signed(6000, 22);
                    end if;
--                end if;
                locked_cntr <= to_unsigned(0, 7);
            -- After locked, if the vco clock anticipates
            elsif (phase_error /= "000000000000000000000") then
--                if (vco_o < vco_ref) then
--                    vco_o <= vco_ref;
--                else
                    -- Hysteresis to converge to a central value
                    if (vco_o < vco_max - to_signed(6000, 22)) then
                        vco_o <= vco_o + to_signed(6000, 22);
                    end if;
--                end if;
                locked_cntr <= to_unsigned(0, 7);
            else
--                if (phase_error_prev = '1') then 
--                    vco_min <= vco_o;
--                else
--                    vco_max <= vco_o;
--                end if;
                locked_cntr <= locked_cntr + to_unsigned(1, 7);
                if (locked_cntr > locked_ref) then
                    locked_ref <= locked_cntr;
                end if;
            end if;    
        end if;
        phase_error_prev <= phase_error(20);
      end if;
    end process;
    
    vc <= std_logic_vector(vco_o);
		
end Behavioral;