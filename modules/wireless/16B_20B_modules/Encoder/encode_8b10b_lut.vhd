---------------------------------------------------------------------------
--
--  Module      : encode_8b10b_lut.vhd
--
--  Version     : 1.1
--
--  Last Update : 2008-10-31
--
--  Project     : 8b/10b Encoder Reference Design
--
--  Description : LUT-based Encoder
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
-------------------------------------------------------------------------------
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

----------------------------------------------------
-- Entity Declaration
----------------------------------------------------
ENTITY encode_8b10b_lut IS
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
END encode_8b10b_lut;

-------------------------------------------------------
-- Architecture
-------------------------------------------------------
ARCHITECTURE xilinx OF encode_8b10b_lut IS

    COMPONENT encode_8b10b_lut_base IS
      GENERIC (
        C_HAS_DISP_IN     :     INTEGER :=0 ;
        C_HAS_FORCE_CODE  :     INTEGER :=0 ;
        C_FORCE_CODE_VAL  :     STRING  :="1010101010" ;
        C_FORCE_CODE_DISP :     INTEGER :=0 ;
        C_HAS_ND          :     INTEGER :=0 ;
        C_HAS_KERR        :     INTEGER :=0
        );
      PORT (
        DIN               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) :=(OTHERS => '0');
        KIN               : IN  STD_LOGIC                    :='0' ;
        CLK               : IN  STD_LOGIC                    :='0' ;
        DOUT              : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) :=
                            str_to_slv(C_FORCE_CODE_VAL, 10) ;
        CE                : IN  STD_LOGIC                    :='0' ;
        FORCE_CODE        : IN  STD_LOGIC                    :='0' ;
        FORCE_DISP        : IN  STD_LOGIC                    :='0' ;
        DISP_IN           : IN  STD_LOGIC                    :='0' ;
        DISP_OUT          : OUT STD_LOGIC                    :=
                            bint_2_sl(C_FORCE_CODE_DISP);
        KERR              : OUT STD_LOGIC                    :='0' ;
        ND                : OUT STD_LOGIC                    :='0'
        );
    END COMPONENT encode_8b10b_lut_base;

------------------------------------------------------
-- Begin Architecture
------------------------------------------------------
BEGIN

  -- Instantiate "A" Encoder
  fe : encode_8b10b_lut_base
    GENERIC MAP (
      C_HAS_DISP_IN     => C_HAS_DISP_IN,
      C_HAS_FORCE_CODE  => C_HAS_FORCE_CODE,
      C_FORCE_CODE_VAL  => C_FORCE_CODE_VAL,
      C_FORCE_CODE_DISP => C_FORCE_CODE_DISP,
      C_HAS_ND          => C_HAS_ND,
      C_HAS_KERR        => C_HAS_KERR
      )
    PORT MAP (
      DIN               => DIN,
      KIN               => KIN,
      FORCE_DISP        => FORCE_DISP,
      FORCE_CODE        => FORCE_CODE,
      DISP_IN           => DISP_IN,
      CE                => CE,
      CLK               => CLK,
      DOUT              => DOUT,
      KERR              => KERR,
      DISP_OUT          => DISP_OUT,
      ND                => ND
      );

  gse : IF (C_HAS_BPORTS = 1) GENERATE
    -- Instantiate "B" Encoder (if bports are present)
    se: encode_8b10b_lut_base
      GENERIC MAP (
        C_HAS_DISP_IN     => C_HAS_DISP_IN_B,
        C_HAS_FORCE_CODE  => C_HAS_FORCE_CODE_B,
        C_FORCE_CODE_VAL  => C_FORCE_CODE_VAL_B,
        C_FORCE_CODE_DISP => C_FORCE_CODE_DISP_B,
        C_HAS_ND          => C_HAS_ND_B,
        C_HAS_KERR        => C_HAS_KERR_B
        )
      PORT MAP (
        DIN               => DIN_B,
        KIN               => KIN_B,
        FORCE_DISP        => FORCE_DISP_B,
        FORCE_CODE        => FORCE_CODE_B,
        DISP_IN           => DISP_IN_B,
        CE                => CE_B,
        CLK               => CLK_B,
        DOUT              => DOUT_B,
        KERR              => KERR_B,
        DISP_OUT          => DISP_OUT_B,
        ND                => ND_B
        );
  END GENERATE gse;

END xilinx ;

