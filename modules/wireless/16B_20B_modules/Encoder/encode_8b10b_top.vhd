-------------------------------------------------------------------------------
--
--  Module      : encode_8b10b_top.vhd
--
--  Version     : 1.1
--
--  Last Update : 2008-10-31
--
--  Project     : 8b/10b Encoder Reference Design
--
--  Description : Core wrapper file
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
--                Copyright 2008 Xilinx, Inc.  All rights reserved.
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
USE IEEE.std_logic_1164.all;

LIBRARY work;
USE work.encode_8b10b_pkg.ALL;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
ENTITY encode_8b10b_top IS
  GENERIC (
    C_ENCODE_TYPE       : INTEGER := 0;
    C_FORCE_CODE_DISP   : INTEGER := 0;
    C_FORCE_CODE_DISP_B : INTEGER := 0;
    C_FORCE_CODE_VAL    : STRING  := "1010101010";
    C_FORCE_CODE_VAL_B  : STRING  := "1010101010";
    C_HAS_BPORTS        : INTEGER := 0;
    C_HAS_CE            : INTEGER := 0;
    C_HAS_DISP_OUT      : INTEGER := 0;
    C_HAS_DISP_IN       : INTEGER := 0;
    C_HAS_FORCE_CODE    : INTEGER := 0;
    C_HAS_KERR          : INTEGER := 0;
    C_HAS_ND            : INTEGER := 0
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

END encode_8b10b_top;
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

-----------------------------------------------------------------------------
-- Architecture
-----------------------------------------------------------------------------
ARCHITECTURE xilinx OF encode_8b10b_top IS

    COMPONENT encode_8b10b_rtl IS
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
    END COMPONENT encode_8b10b_rtl;

-- If C_HAS_BPORTS=1, the optional B ports are configured the same way as the
-- optional A ports.  Otherwise, all the B ports are disabled.
 CONSTANT C_HAS_CE_B        : INTEGER := has_bport(C_HAS_BPORTS,C_HAS_CE);
 CONSTANT C_HAS_DISP_OUT_B  : INTEGER := has_bport(C_HAS_BPORTS,C_HAS_DISP_OUT);
 CONSTANT C_HAS_DISP_IN_B   : INTEGER := has_bport(C_HAS_BPORTS,C_HAS_DISP_IN);
 CONSTANT C_HAS_FORCE_CODE_B: INTEGER := has_bport(C_HAS_BPORTS,C_HAS_FORCE_CODE);
 CONSTANT C_HAS_KERR_B      : INTEGER := has_bport(C_HAS_BPORTS,C_HAS_KERR);
 CONSTANT C_HAS_ND_B        : INTEGER := has_bport(C_HAS_BPORTS,C_HAS_ND);

-----------------------------------------------------------------------------
-- BEGIN ARCHITECTURE
-----------------------------------------------------------------------------
BEGIN

   enc : encode_8b10b_rtl
     GENERIC MAP(
       C_ENCODE_TYPE       => C_ENCODE_TYPE,
       C_ELABORATION_DIR   => "./",
       C_FORCE_CODE_DISP   => C_FORCE_CODE_DISP,
       C_FORCE_CODE_DISP_B => C_FORCE_CODE_DISP_B,
       C_FORCE_CODE_VAL    => C_FORCE_CODE_VAL,
       C_FORCE_CODE_VAL_B  => C_FORCE_CODE_VAL_B,
       C_HAS_BPORTS        => C_HAS_BPORTS,
       C_HAS_CE            => C_HAS_CE,
       C_HAS_CE_B          => C_HAS_CE_B,
       C_HAS_DISP_OUT      => C_HAS_DISP_OUT,
       C_HAS_DISP_OUT_B    => C_HAS_DISP_OUT_B,
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
       CLK           =>    CLK,
       DIN           =>    DIN,
       KIN           =>    KIN,
       DOUT          =>    DOUT,
       CE            =>    CE,
       FORCE_CODE    =>    FORCE_CODE,
       FORCE_DISP    =>    FORCE_DISP,
       DISP_IN       =>    DISP_IN,
       DISP_OUT      =>    DISP_OUT,
       ND            =>    ND,
       KERR          =>    KERR,
       CLK_B         =>    CLK_B,
       DIN_B         =>    DIN_B,
       KIN_B         =>    KIN_B,
       DOUT_B        =>    DOUT_B,
       CE_B          =>    CE_B,
       FORCE_CODE_B  =>    FORCE_CODE_B,
       FORCE_DISP_B  =>    FORCE_DISP_B,
       DISP_IN_B     =>    DISP_IN_B,
       DISP_OUT_B    =>    DISP_OUT_B,
       ND_B          =>    ND_B,
       KERR_B        =>    KERR_B
       );

END xilinx;
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
