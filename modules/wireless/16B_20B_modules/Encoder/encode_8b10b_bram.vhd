---------------------------------------------------------------------------
--
--  Module      : encode_8b10b_bram.vhd
--
--  Version     : 1.1
--
--  Last Update : 2008-10-31
--
--  Project     : 8b/10b Encoder Reference Design
--
--  Description : Block memory-based 8B/10B Encoder
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
USE IEEE.std_logic_unsigned.All;
USE STD.textio.ALL;

LIBRARY work;
USE work.encode_8b10b_pkg.ALL;

----------------------------------------------------
-- Entity Declaration
----------------------------------------------------
ENTITY encode_8b10b_bram IS
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
END encode_8b10b_bram;


-----------------------------------------------------------------------------
-- Architecture
-----------------------------------------------------------------------------
ARCHITECTURE xilinx OF encode_8b10b_bram IS

----------------------------------------------------
--Constant Declarations
----------------------------------------------------
 CONSTANT SINIT_A_VALUE : STRING :=
   concat_force_code(C_FORCE_CODE_DISP, C_FORCE_CODE_VAL);
 CONSTANT SINIT_B_VALUE : STRING :=
   concat_force_code(C_FORCE_CODE_DISP_B, C_FORCE_CODE_VAL_B);
 CONSTANT MIF_FILE_NAME : STRING := C_ELABORATION_DIR & "enc.mif";

-----------------------------------------------------------------------------
-- .MIF file support
-----------------------------------------------------------------------------
 -- Initialize inferred ROM from mif file
 TYPE RomType IS ARRAY(0 TO 1023) OF BIT_VECTOR(11 DOWNTO 0);
 IMPURE FUNCTION InitRomFromFile (RomFileName : STRING) RETURN RomType IS
    FILE RomFile : TEXT OPEN READ_MODE IS RomFileName;
    VARIABLE RomFileLine : LINE;
    VARIABLE ROM : RomType;
  BEGIN
    FOR I IN RomType'range LOOP
      READLINE (RomFile, RomFileLine);
      READ (RomFileLine, ROM(I));
    END LOOP;
    RETURN ROM;
  END FUNCTION;
  SIGNAL ROM : RomType := InitRomFromFile(MIF_FILE_NAME);

----------------------------------------------------
--Signal Declarations
----------------------------------------------------
  SIGNAL ROM_data      : STD_LOGIC_VECTOR(11 DOWNTO 0) :=
                         str_to_slv(SINIT_A_VALUE, 12);
  SIGNAL ROM_data_b    : STD_LOGIC_VECTOR(11 DOWNTO 0) :=
                         str_to_slv(SINIT_B_VALUE, 12);
  SIGNAL ROM_address   : STD_LOGIC_VECTOR(9 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL ROM_address_b : STD_LOGIC_VECTOR(9 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL mem_disp_in   : STD_LOGIC                     := '0';
  SIGNAL mem_disp_in_b : STD_LOGIC                     := '0';
  SIGNAL mem_disp_out  : STD_LOGIC                     := '0';
  SIGNAL mem_disp_out_b: STD_LOGIC                     := '0';

-----------------------------------------------------------------------------
-- BEGIN ARCHITECTURE
-----------------------------------------------------------------------------
BEGIN

  -- Signal assignments (PORT A)
  ROM_address(9)            <= KIN;
  ROM_address(8)            <= mem_disp_in;
  ROM_address(7 DOWNTO 0)   <= DIN(7 DOWNTO 0);
  mem_disp_out              <= ROM_data(10);

  -- Signal assignments (PORT B)
  ROM_address_b(9)          <= KIN_B;
  ROM_address_b(8)          <= mem_disp_in_b;
  ROM_address_b(7 DOWNTO 0) <= DIN_B (7 DOWNTO 0);
  mem_disp_out_b            <= ROM_data_b(10);


  -- Map internal signals (from ROM) to outputs
  DOUT(9)     <= ROM_data(0);
  DOUT(8)     <= ROM_data(1);
  DOUT(7)     <= ROM_data(2);
  DOUT(6)     <= ROM_data(3);
  DOUT(5)     <= ROM_data(4);
  DOUT(4)     <= ROM_data(5);
  DOUT(3)     <= ROM_data(6);
  DOUT(2)     <= ROM_data(7);
  DOUT(1)     <= ROM_data(8);
  DOUT(0)     <= ROM_data(9);
  KERR     <= ROM_data(11);
  DISP_OUT <= ROM_data(10);

---------------------------------------------------------------------------------
-- Override the internal running disparity with the disparity input if the
-- DISP_IN pin exists and FORCE_DISP is asserted
---------------------------------------------------------------------------------
  gfda: IF (C_HAS_DISP_IN=1) GENERATE
    PROCESS (FORCE_DISP, mem_disp_out, DISP_IN)
    BEGIN
      IF (FORCE_DISP = '1') THEN
        mem_disp_in <= DISP_IN ;
      ELSE
        mem_disp_in <= mem_disp_out ;
      END IF ;
    END PROCESS ;
  END GENERATE gfda;

  ngfda: IF (C_HAS_DISP_IN /=1) GENERATE
    mem_disp_in <= mem_disp_out;
  END GENERATE ngfda;

---------------------------------------------------------------------------------
-- If FORCE_CODE is asserted, set ND to zero indicating that the new data is
-- not valid, otherwise set it to CE.
-- ND is tied to 0 in the top-level if C_HAS_ND=0.
---------------------------------------------------------------------------------
  gnd: IF (C_HAS_ND=1)  GENERATE
    PROCESS (CLK)
    BEGIN
      IF (CLK'event AND CLK = '1') THEN
        IF (FORCE_CODE = '1') THEN
          ND <= '0' AFTER TFF;
        ELSE
          ND <= CE AFTER TFF;
        END IF;
      END IF;
    END PROCESS ;
  END GENERATE gnd;

---------------------------------------------------------
-- Update Memory output(PORT A)
---------------------------------------------------------
  PROCESS (CLK)
  BEGIN
    IF (CLK'event AND CLK = '1') THEN
      IF (CE = '1') THEN
        IF (FORCE_CODE = '1') THEN
          ROM_data <= str_to_slv(SINIT_A_VALUE,12) AFTER TFF;
        ELSE
          ROM_data <= to_stdlogicvector(ROM(conv_integer(ROM_address)))
                      AFTER TFF;
        END IF;
      END IF;
    END IF;
  END PROCESS;

----------------------------------------------------
-- PORT B - Connect the B ports as required
----------------------------------------------------
  gdp : IF (C_HAS_BPORTS=1) GENERATE

    -- Map internal signals to outputs
    DOUT_B(9)     <= ROM_data_b(0);
    DOUT_B(8)     <= ROM_data_b(1);
    DOUT_B(7)     <= ROM_data_b(2);
    DOUT_B(6)     <= ROM_data_b(3);
    DOUT_B(5)     <= ROM_data_b(4);
    DOUT_B(4)     <= ROM_data_b(5);
    DOUT_B(3)     <= ROM_data_b(6);
    DOUT_B(2)     <= ROM_data_b(7);
    DOUT_B(1)     <= ROM_data_b(8);
    DOUT_B(0)     <= ROM_data_b(9);
    KERR_B     <= ROM_data_b(11);
    DISP_OUT_B <= ROM_data_b(10);

---------------------------------------------------------------------------------
-- Override the internal running disparity (port B) with the disparity input if
-- the DISP_IN_B pin exists and FORCE_DISP_B is asserted
---------------------------------------------------------------------------------
    gfdb: IF (C_HAS_DISP_IN_B=1) GENERATE
      PROCESS (FORCE_DISP_B, mem_disp_out_b, DISP_IN_B)
      BEGIN
        IF (FORCE_DISP_B = '1') THEN
          mem_disp_in_b <= DISP_IN_B ;
        ELSE
          mem_disp_in_b <= mem_disp_out_b ;
        END IF ;
      END PROCESS ;
    END GENERATE gfdb;

    ngfdb: IF (C_HAS_DISP_IN_B /=1) GENERATE
      mem_disp_in_b <= mem_disp_out_b;
    END GENERATE ngfdb;

---------------------------------------------------------------------------------
-- If FORCE_CODE_B is asserted, set ND_B to zero indicating that the new data is
-- not valid, otherwise set it to CE_B.
-- ND_B is tied to 0 in the top-level if C_HAS_ND_B=0.
---------------------------------------------------------------------------------
    gndb: IF (C_HAS_ND_B=1)  GENERATE
      PROCESS (CLK_B)
      BEGIN
        IF  (CLK_B'event AND CLK_B = '1') THEN
          IF (FORCE_CODE_B = '1') THEN
            ND_B <= '0' AFTER TFF;
          ELSE
            ND_B <= CE_B AFTER TFF;
          END IF;
        END IF;
      END PROCESS ;
    END GENERATE gndb;

---------------------------------------------------------
-- Update Memory output(PORT B)
---------------------------------------------------------
    PROCESS (CLK_B)
    BEGIN
      IF (CLK_B'event AND CLK_B = '1') THEN
        IF (CE_B = '1') THEN
          IF (FORCE_CODE_B = '1') THEN
            ROM_data_b <= (str_to_slv(SINIT_B_VALUE,12)) AFTER TFF;
          ELSE
            ROM_data_B <= to_stdlogicvector(ROM(conv_integer(ROM_address_b)))
                          AFTER TFF;
          END IF;
        END IF;
      END IF;
    END PROCESS;

  END GENERATE gdp;

END xilinx ;

