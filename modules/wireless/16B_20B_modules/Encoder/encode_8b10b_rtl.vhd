---------------------------------------------------------------------------
--
--  Module      : encode_8b10b_rtl.vhd
--
--  Version     : 1.1
--
--  Last Update : 2008-10-31
--
--  Project     : 8b/10b Encoder Reference Design
--
--  Description : Top-level, synthesizable 8b/10b encoder core file
--
--  Company     : Xilinx, Inc.
--
--  DISCLAIMER OF LIABILITY
--
--                This file contains proprietary and confidential information of
--                Xilinx, Inc. ("Xilinx"), that is distributed under a license
--                from Xilinx, and may be used, copied and/or disclosed only
--                pursuant to the terms of a valid license agreement with Xilinx.
--
--                XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
--                ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
--                EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
--                LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
--                MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
--                does not warrant that functions included in the Materials will
--                meet the requirements of Licensee, or that the operation of the
--                Materials will be uninterrupted or error-free, or that defects
--                in the Materials will be corrected.  Furthermore, Xilinx does
--                not warrant or make any representations regarding use, or the
--                results of the use, of the Materials in terms of correctness,
--                accuracy, reliability or otherwise.
--
--                Xilinx products are not designed or intended to be fail-safe,
--                or for use in any application requiring fail-safe performance,
--                such as life-support or safety devices or systems, Class III
--                medical devices, nuclear facilities, applications related to
--                the deployment of airbags, or any other applications that could
--                lead to death, personal injury or severe property or
--                environmental damage (individually and collectively, "critical
--                applications").  Customer assumes the sole risk and liability
--                of any use of Xilinx products in critical applications,
--                subject only to applicable laws and regulations governing
--                limitations on product liability.
--
--                Copyright 2000, 2001, 2002, 2003, 2004, 2008 Xilinx, Inc.
--                All rights reserved.
--
--                This disclaimer and copyright notice must be retained as part
--                of this file at all times.
--
---------------------------------------------------------------------------
--
--  History
--
--  Date        Version   Description
--
--  10/31/2008  1.1       Initial release
--
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.encode_8b10b_pkg.ALL;

ENTITY encode_8b10b_rtl IS
  GENERIC (
    C_ENCODE_TYPE       : INTEGER := 0;
    C_ELABORATION_DIR   : STRING  := "./";
    C_FORCE_CODE_DISP   : INTEGER := 0;
    C_FORCE_CODE_DISP_B : INTEGER := 0;
    C_FORCE_CODE_VAL    : STRING  := "1010101010";
    C_FORCE_CODE_VAL_B  : STRING  := "1010101010";
    C_HAS_BPORTS        : INTEGER := 0;
    C_HAS_CE            : INTEGER := 0;
    C_HAS_CE_B          : INTEGER := 0;
    C_HAS_DISP_IN       : INTEGER := 0;
    C_HAS_DISP_IN_B     : INTEGER := 0;
    C_HAS_DISP_OUT      : INTEGER := 0;
    C_HAS_DISP_OUT_B    : INTEGER := 0;
    C_HAS_FORCE_CODE    : INTEGER := 0;
    C_HAS_FORCE_CODE_B  : INTEGER := 0;
    C_HAS_KERR          : INTEGER := 0;
    C_HAS_KERR_B        : INTEGER := 0;
    C_HAS_ND            : INTEGER := 0;
    C_HAS_ND_B          : INTEGER := 0
    );
  PORT (
    CLK          : IN  STD_LOGIC                    :='0';
    DIN          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
    KIN          : IN  STD_LOGIC                    :='0';
    DOUT         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) ;

    CE           : IN  STD_LOGIC                    :='0';
    FORCE_CODE   : IN  STD_LOGIC                    :='0';
    FORCE_DISP   : IN  STD_LOGIC                    :='0';
    DISP_IN      : IN  STD_LOGIC                    :='0';
    DISP_OUT     : OUT STD_LOGIC                    ;
    ND           : OUT STD_LOGIC                    :='0';
    KERR         : OUT STD_LOGIC                    :='0';

    CLK_B        : IN  STD_LOGIC                    :='0';
    DIN_B        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
    KIN_B        : IN  STD_LOGIC                    :='0';
    DOUT_B       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) ;

    CE_B         : IN  STD_LOGIC                    :='0';
    FORCE_CODE_B : IN  STD_LOGIC                    :='0';
    FORCE_DISP_B : IN  STD_LOGIC                    :='0';
    DISP_IN_B    : IN  STD_LOGIC                    :='0';
    DISP_OUT_B   : OUT STD_LOGIC                    ;
    ND_B         : OUT STD_LOGIC                    :='0';
    KERR_B       : OUT STD_LOGIC                    :='0'
    );
END encode_8b10b_rtl;

------------------------------------------------------------------------
-- Generic Definitions
------------------------------------------------------------------------
--    C_ENCODE_TYPE                     -- 0 slice, 1 blockRAM
--    C_ELABORATION_DIR                 -- Directory path for mif file
--    C_FORCE_CODE_DISP                 -- Force code disparity: 0 neg, 1 pos
--    C_FORCE_CODE_DISP_B               -- Force code disparity port B:
--                                         0 neg, 1 pos
--    C_FORCE_CODE_VAL                  -- Force code value (10 bits)
--    C_FORCE_CODE_VAL_B                -- Force code value B (10 bits)
--    C_HAS_BPORTS                      -- 1 if second encoder
--    C_HAS_CE                          -- 1 if CE port present
--    C_HAS_CE_B                        -- 1 if CE_B port present
--    C_HAS_DISP_OUT                    -- 1 if DISP_OUT port present
--    C_HAS_DISP_OUT_B                  -- 1 if DISP_OUT_B port present
--    C_HAS_DISP_IN                     -- 1 if FORCE_DISP port present
--    C_HAS_DISP_IN_B                   -- 1 if FORCE_DISP_B port present
--    C_HAS_FORCE_CODE                  -- 1 if FORCE_CODE port present
--    C_HAS_FORCE_CODE_B                -- 1 if FORCE_CODE_B port present
--    C_HAS_KERR                        -- 1 if KERR port present
--    C_HAS_KERR_B                      -- 1 if KERR_B port present
--    C_HAS_ND                          -- 1 if ND port present
--    C_HAS_ND_B                        -- 1 if ND_B port present
-------------------------------------------------------------------------------
-- Port Definitions
-------------------------------------------------------------------------------
-- MANDATORY PORTS
--
--   CLK            : Clock input
--   DIN            : Data Input to be encoded
--   KIN            : Command Input, it determines if DIN is encoded as data
--                    (KIN=0) or as a special character (KIN=1)
--   DOUT           : Encoded 10-bit symbol
-------------------------------------------------------------------------------
-- OPTIONAL PORTS
--
--   CLK_B          : Clock input (B port)
--   DIN_B          : Data Input to be encoded (B port)
--   KIN_B          : Command Input, it determines if DIN_B is encoded as data
--                    (KIN_B=0) or as a special character (KIN_B=1) (B port)
--   DOUT_B         : Encoded 10-bit symbol (B port)
--
--   CE[_B]         : Clock Enable
--   FORCE_CODE[_B] : Drives the Encoder data output and disparity to a
--                    predefined initialization value
--   FORCE_DISP[_B] : When active, overrides the current running disparity with
--                    the external DISP_IN[_B] input
--   DISP_IN[_B]    : Sets the running disparity for the current input if
--                    FORCE_DISP[_B] is active, otherwise has no effect
--   DISP_OUT[_B]   : Current Encoder running disparity
--   ND[_B]         : New Data, Registered version of CE[_B]
--   KERR[_B]       : For debugging purposes, KERR[_B] is asserted if KIN is
--                    active and DIN[_B] doesn't map to a defined special
--                    character
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE xilinx OF encode_8b10b_rtl IS

    COMPONENT encode_8b10b_lut IS
      GENERIC (
        C_FORCE_CODE_DISP   :     INTEGER:= 0;
        C_FORCE_CODE_DISP_B :     INTEGER:= 0;
        C_FORCE_CODE_VAL    :     STRING := "1010101010";
        C_FORCE_CODE_VAL_B  :     STRING := "1010101010";
        C_HAS_BPORTS        :     INTEGER:= 0;
        C_HAS_DISP_IN       :     INTEGER:= 0;
        C_HAS_DISP_IN_B     :     INTEGER:= 0;
        C_HAS_FORCE_CODE    :     INTEGER:= 0;
        C_HAS_FORCE_CODE_B  :     INTEGER:= 0;
        C_HAS_KERR          :     INTEGER:= 0;
        C_HAS_KERR_B        :     INTEGER:= 0;
        C_HAS_ND            :     INTEGER:= 0;
        C_HAS_ND_B          :     INTEGER:= 0
        );
      PORT (
        DIN                 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
        KIN                 : IN  STD_LOGIC                    :='0';
        CLK                 : IN  STD_LOGIC                    :='0';
        DOUT                : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) ;
    
        CE                  : IN  STD_LOGIC                    :='0';
        FORCE_CODE          : IN  STD_LOGIC                    :='0';
        FORCE_DISP          : IN  STD_LOGIC                    :='0';
        DISP_IN             : IN  STD_LOGIC                    :='0';
        DISP_OUT            : OUT STD_LOGIC                    ;
        KERR                : OUT STD_LOGIC                    :='0';
        ND                  : OUT STD_LOGIC                    :='0';
        DIN_B               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
        KIN_B               : IN  STD_LOGIC                    :='0';
        CLK_B               : IN  STD_LOGIC                    :='0';
        CE_B                : IN  STD_LOGIC                    :='0';
        FORCE_CODE_B        : IN  STD_LOGIC                    :='0';
        FORCE_DISP_B        : IN  STD_LOGIC                    :='0';
        DISP_IN_B           : IN  STD_LOGIC                    :='0';
        DOUT_B              : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) ;
        DISP_OUT_B          : OUT STD_LOGIC                    ;
        KERR_B              : OUT STD_LOGIC                    :='0';
        ND_B                : OUT STD_LOGIC                    :='0'
        );
    END COMPONENT encode_8b10b_lut;

    COMPONENT encode_8b10b_bram IS
      GENERIC (
        C_ELABORATION_DIR   : STRING  := "./";
        C_FORCE_CODE_DISP   : INTEGER := 0;
        C_FORCE_CODE_DISP_B : INTEGER := 0;
        C_FORCE_CODE_VAL    : STRING  := "1010101010";
        C_FORCE_CODE_VAL_B  : STRING  := "1010101010";
        C_HAS_BPORTS        : INTEGER := 0;
        C_HAS_DISP_IN       : INTEGER := 0;
        C_HAS_DISP_IN_B     : INTEGER := 0;
        C_HAS_ND            : INTEGER := 0;
        C_HAS_ND_B          : INTEGER := 0
        );
      PORT (
        DIN          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        KIN          : IN  STD_LOGIC                    :='0';
        CLK          : IN  STD_LOGIC                    :='0';
        DOUT         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) :=
                       str_to_slv(C_FORCE_CODE_VAL, 10);
    
        CE           : IN  STD_LOGIC                    := '0';
        CE_B         : IN  STD_LOGIC                    := '0';
        DIN_B        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        KIN_B        : IN  STD_LOGIC                    := '0';
        CLK_B        : IN  STD_LOGIC                    := '0';
        DOUT_B       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) :=
                       str_to_slv(C_FORCE_CODE_VAL_B, 10);
        FORCE_CODE   : IN  STD_LOGIC                    := '0';
        FORCE_CODE_B : IN  STD_LOGIC                    := '0';
        FORCE_DISP   : IN  STD_LOGIC                    := '0';
        FORCE_DISP_B : IN  STD_LOGIC                    := '0';
        DISP_IN      : IN  STD_LOGIC                    := '0';
        DISP_IN_B    : IN  STD_LOGIC                    := '0';
        DISP_OUT     : OUT STD_LOGIC                    :=
                       bint_2_sl(C_FORCE_CODE_DISP);
        DISP_OUT_B   : OUT STD_LOGIC                    :=
                       bint_2_sl(C_FORCE_CODE_DISP_B);
        ND           : OUT STD_LOGIC                    := '0';
        ND_B         : OUT STD_LOGIC                    := '0';
        KERR         : OUT STD_LOGIC                    := '0';
        KERR_B       : OUT STD_LOGIC                    := '0'
        );
    END COMPONENT encode_8b10b_bram;

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
  SIGNAL din_i          : STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
  SIGNAL kin_i          : STD_LOGIC                    :='0';
  SIGNAL clk_i          : STD_LOGIC                    :='0';
  SIGNAL dout_i         : STD_LOGIC_VECTOR(9 DOWNTO 0) :=
                          str_to_slv(C_FORCE_CODE_VAL,10);
                          --convert C_FORCE_CODE_VAL string to std_logic_vector
  SIGNAL ce_i           : STD_LOGIC                    :='0';
  SIGNAL ce_b_i         : STD_LOGIC                    :='0';
  SIGNAL din_b_i        : STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
  SIGNAL kin_b_i        : STD_LOGIC                    :='0';
  SIGNAL clk_b_i        : STD_LOGIC                    :='0';
  SIGNAL dout_b_i       : STD_LOGIC_VECTOR(9 DOWNTO 0) :=
                          str_to_slv(C_FORCE_CODE_VAL_B,10);
                          --convert C_FORCE_CODE_VAL_B string to std_logic_vector
  SIGNAL force_code_i   : STD_LOGIC                    :='0';
  SIGNAL force_code_b_i : STD_LOGIC                    :='0';
  SIGNAL force_disp_i   : STD_LOGIC                    :='0';
  SIGNAL force_disp_b_i : STD_LOGIC                    :='0';
  SIGNAL disp_in_i      : STD_LOGIC                    :='0';
  SIGNAL disp_in_b_i    : STD_LOGIC                    :='0';
  SIGNAL disp_out_i     : STD_LOGIC                    :=
                          bint_2_sl(C_FORCE_CODE_DISP);
                          --convert C_FORCE_CODE_DISP integer to std logic
  SIGNAL disp_out_b_i   : STD_LOGIC                    :=
                          bint_2_sl(C_FORCE_CODE_DISP_B);
                          --convert C_FORCE_CODE_DISP integer to std logic
  SIGNAL nd_i           : STD_LOGIC                    :='0';
  SIGNAL nd_b_i         : STD_LOGIC                    :='0';
  SIGNAL kerr_i         : STD_LOGIC                    :='0';
  SIGNAL kerr_b_i       : STD_LOGIC                    :='0';

-------------------------------------------------------------------------------
-- Begin Architecture
-------------------------------------------------------------------------------
BEGIN

 --------------------------------------------------
 --LUT-based Implementation
 --------------------------------------------------
  glut : IF (C_ENCODE_TYPE = 0) GENERATE

    rf : encode_8b10b_lut
      GENERIC MAP (
        C_FORCE_CODE_DISP   => C_FORCE_CODE_DISP,
        C_FORCE_CODE_DISP_B => C_FORCE_CODE_DISP_B,
        C_FORCE_CODE_VAL    => C_FORCE_CODE_VAL,
        C_FORCE_CODE_VAL_B  => C_FORCE_CODE_VAL_B,
        C_HAS_BPORTS        => C_HAS_BPORTS,
        C_HAS_DISP_IN       => C_HAS_DISP_IN,
        C_HAS_DISP_IN_B     => C_HAS_DISP_IN_B,
        C_HAS_FORCE_CODE    => C_HAS_FORCE_CODE,
        C_HAS_FORCE_CODE_B  => C_HAS_FORCE_CODE_B,
        C_HAS_KERR          => C_HAS_KERR,
        C_HAS_KERR_B        => C_HAS_KERR_B,
        C_HAS_ND            => C_HAS_ND,
        C_HAS_ND_B          => C_HAS_ND_B
        )

      PORT MAP (
        DIN          => din_i,
        KIN          => kin_i,
        CLK          => clk_i,
        DOUT         => dout_i,
        CE           => ce_i,
        CE_B         => ce_b_i,
        DIN_B        => din_b_i,
        KIN_B        => kin_b_i,
        CLK_B        => clk_b_i,
        DOUT_B       => dout_b_i,
        FORCE_CODE   => force_code_i,
        FORCE_CODE_B => force_code_b_i,
        FORCE_DISP   => force_disp_i,
        FORCE_DISP_B => force_disp_b_i,
        DISP_IN      => disp_in_i,
        DISP_IN_B    => disp_in_b_i,
        DISP_OUT     => disp_out_i,
        DISP_OUT_B   => disp_out_b_i,
        ND           => nd_i,
        ND_B         => nd_b_i,
        KERR         => kerr_i,
        KERR_B       => kerr_b_i
        );
  END GENERATE glut;

 --------------------------------------------------
 --BRAM-based Implementation
 --------------------------------------------------
  gblk : IF (C_ENCODE_TYPE = 1) GENERATE

    brin : encode_8b10b_bram
      GENERIC MAP (
        C_ELABORATION_DIR   => C_ELABORATION_DIR,
        C_FORCE_CODE_DISP   => C_FORCE_CODE_DISP,
        C_FORCE_CODE_DISP_B => C_FORCE_CODE_DISP_B,
        C_FORCE_CODE_VAL    => C_FORCE_CODE_VAL,
        C_FORCE_CODE_VAL_B  => C_FORCE_CODE_VAL_B,
        C_HAS_BPORTS        => C_HAS_BPORTS,
        C_HAS_DISP_IN       => C_HAS_DISP_IN,
        C_HAS_DISP_IN_B     => C_HAS_DISP_IN_B,
        C_HAS_ND            => C_HAS_ND,
        C_HAS_ND_B          => C_HAS_ND_B
        )

      PORT MAP (
        DIN          => din_i,
        KIN          => kin_i,
        CLK          => clk_i,
        DOUT         => dout_i,
        CE           => ce_i,
        CE_B         => ce_b_i,
        DIN_B        => din_b_i,
        KIN_B        => kin_b_i,
        CLK_B        => clk_b_i,
        DOUT_B       => dout_b_i,
        FORCE_CODE   => force_code_i,
        FORCE_CODE_B => force_code_b_i,
        FORCE_DISP   => force_disp_i,
        FORCE_DISP_B => force_disp_b_i,
        DISP_IN      => disp_in_i,
        DISP_IN_B    => disp_in_b_i,
        DISP_OUT     => disp_out_i,
        DISP_OUT_B   => disp_out_b_i,
        ND           => nd_i,
        ND_B         => nd_b_i,
        KERR         => kerr_i,
        KERR_B       => kerr_b_i
        );

  END GENERATE gblk;

----------------------------------------------------------------
-- Mandatory Ports for Port A
----------------------------------------------------------------
  din_i <= DIN;
  kin_i <= KIN;
  clk_i <= CLK;
  DOUT  <= dout_i;

----------------------------------------------------------------
-- Optional Inputs for Port A
----------------------------------------------------------------
--CE
  gce : IF (C_HAS_CE/=0) GENERATE
    ce_i <= CE;
  END GENERATE gce;
  ngce : IF (C_HAS_CE = 0) GENERATE
    ce_i <= '1';
  END GENERATE ngce;

--DISP_IN, FORCE_DISP
  gdsp : IF (C_HAS_DISP_IN/=0) GENERATE
    disp_in_i    <= DISP_IN;
    force_disp_i <= FORCE_DISP;
  END GENERATE gdsp;
  ngdsp : IF (C_HAS_DISP_IN = 0) GENERATE
    disp_in_i    <= '0';
    force_disp_i <= '0';
  END GENERATE ngdsp;

--FORCE_CODE
  gfc : IF (C_HAS_FORCE_CODE/=0) GENERATE
    force_code_i <= FORCE_CODE;
  END GENERATE gfc;
  ngfc : IF (C_HAS_FORCE_CODE = 0) GENERATE
    force_code_i <= '0';
  END GENERATE ngfc;

-------------------------------------------------------------
--Optional Outputs for Port A
-------------------------------------------------------------

--DISP_OUT
  gdo : IF (C_HAS_DISP_OUT/=0) GENERATE
    DISP_OUT <= disp_out_i;
  END GENERATE gdo;
  ngdo : IF (C_HAS_DISP_OUT = 0) GENERATE
    DISP_OUT <= '0';
  END GENERATE ngdo;

--KERR
  gker : IF (C_HAS_KERR/=0) GENERATE
    KERR <= kerr_i;
  END GENERATE gker;
  ngker : IF (C_HAS_KERR = 0) GENERATE
    KERR <= '0';
  END GENERATE ngker;

--ND
  gnd : IF (C_HAS_ND/=0) GENERATE
    ASSERT (C_HAS_CE /= 0)
      REPORT "Invalid configuration: ND port requires CE port"
      SEVERITY WARNING;
    ND <= nd_i;
  END GENERATE gnd;
  ngnd : IF (C_HAS_ND=0) GENERATE
    ND <= '0';
  END GENERATE ngnd;

-------------------------------------------------------------
--  Mandatory Ports for Port B
-------------------------------------------------------------
--Mandatory B Ports (if B ports are present)
  gbp : IF (C_HAS_BPORTS /= 0) GENERATE
    din_b_i <= DIN_B;
    kin_b_i <= KIN_B;
    clk_b_i <= CLK_B;
    DOUT_B  <= dout_b_i;
  END GENERATE gbp;

  ngbp : IF (C_HAS_BPORTS = 0) GENERATE
    din_b_i <= (OTHERS => '0');
    kin_b_i <= '0';
    clk_b_i <= '0';
    dout_b  <= (OTHERS => '0');
  END GENERATE ngbp;

--------------------------------------------------------------
---Optional Inputs for Port B
--------------------------------------------------------------

--CE
  gceb : IF (C_HAS_CE_B/=0 AND C_HAS_BPORTS /= 0) GENERATE
    ce_b_i <= CE_B;
  END GENERATE gceb;
  ngceb : IF (C_HAS_CE_B = 0 OR C_HAS_BPORTS = 0) GENERATE
    ce_b_i <= '1';
  END GENERATE ngceb;
  ASSERT (NOT(C_HAS_CE_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate CE_B when C_HAS_BPORTS=0"
    SEVERITY WARNING;

--DISP_IN
  gdspb : IF (C_HAS_DISP_IN_B/=0 AND C_HAS_BPORTS /= 0) GENERATE
    disp_in_b_i    <= DISP_IN_B;
    force_disp_b_i <= FORCE_DISP_B;
  END GENERATE gdspb;
  ngdsb : IF (C_HAS_DISP_IN_B = 0 OR C_HAS_BPORTS = 0) GENERATE
    disp_in_b_i    <= '0';
    force_disp_b_i <= '0';
  END GENERATE ngdsb;
  ASSERT (NOT(C_HAS_DISP_IN_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate DISP_IN_B or FORCE_DISP_B" &
    " when C_HAS_BPORTS=0"
    SEVERITY WARNING;

--FORCE_CODE
  gfcb : IF (C_HAS_FORCE_CODE_B/=0 AND C_HAS_BPORTS /= 0) GENERATE
    force_code_b_i <= FORCE_CODE_B;
  END GENERATE gfcb;
  nfcb : IF (C_HAS_FORCE_CODE_B = 0 OR C_HAS_BPORTS = 0) GENERATE
    force_code_b_i <= '0';
  END GENERATE nfcb;
  ASSERT (NOT(C_HAS_FORCE_CODE_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate FORCE_CODE_B when " &
    "C_HAS_BPORTS=0"
    SEVERITY WARNING;

--------------------------------------------------------------
---Optional Outputs for Port B
--------------------------------------------------------------

--DISP_OUT
  gdob : IF (C_HAS_DISP_OUT_B/=0 AND C_HAS_BPORTS /= 0) GENERATE
    DISP_OUT_B <= disp_out_b_i;
  END GENERATE gdob;
  ngdob : IF (C_HAS_DISP_OUT_B = 0 OR C_HAS_BPORTS = 0) GENERATE
    DISP_OUT_B <= '0';
  END GENERATE ngdob;
  ASSERT (NOT(C_HAS_DISP_OUT_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate DISP_OUT_B when " &
    "C_HAS_BPORTS=0"
    SEVERITY WARNING;

--KERR
  gkerb : IF (C_HAS_KERR_B/=0 AND C_HAS_BPORTS /= 0) GENERATE
    KERR_B <= kerr_b_i;
  END GENERATE gkerb;
  ngkrb : IF (C_HAS_KERR_B = 0 OR C_HAS_BPORTS = 0) GENERATE
    KERR_B <= '0';
  END GENERATE ngkrb;
  ASSERT (NOT(C_HAS_KERR_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate KERR_B when C_HAS_BPORTS=0"
    SEVERITY WARNING;

--ND
  gndb : IF (C_HAS_ND_B/=0 AND C_HAS_BPORTS /=0) GENERATE
    ASSERT (C_HAS_CE_B /= 0)
      REPORT "Invalid configuration: ND_B port requires CE_B port"
      SEVERITY WARNING;
    ND_B <= nd_b_i;
  END GENERATE gndb;
  ngbn : IF (C_HAS_ND_B=0 OR C_HAS_BPORTS =0) GENERATE
    ND_B <= '0';
  END GENERATE ngbn;
  ASSERT (NOT(C_HAS_ND_B /= 0 AND C_HAS_BPORTS = 0))
    REPORT "Invalid configuration: Will not generate ND_B when C_HAS_BPORTS=0"
    SEVERITY WARNING;

END xilinx;
