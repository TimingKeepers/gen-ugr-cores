---------------------------------------------------------------------------
--
--  Module      : encode_8b10b_pkg.vhd
--
--  Version     : 1.1
--
--  Last Update : 2008-10-31
--
--  Project     : 8b/10b Encoder Reference Design
--
--  Description : 8b/10b Encoder package file
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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_misc.ALL;
USE STD.textio.ALL;

-------------------------------------------------------------------------------
-- Package Declaration
-------------------------------------------------------------------------------
PACKAGE encode_8b10b_pkg IS

-------------------------------------------------------------------------------
-- Constant Declaration
-------------------------------------------------------------------------------
  CONSTANT TFF : time := 2 ns;

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
  FUNCTION concat_force_code(
    force_code_disp : INTEGER; force_code_val : STRING)
    RETURN STRING;
  FUNCTION str_to_slv(
    bitsin : STRING; nbits : INTEGER)
    RETURN STD_LOGIC_VECTOR;
  FUNCTION boolean_to_std_logic(
    value : BOOLEAN)
    RETURN STD_LOGIC;
  FUNCTION bint_2_sl (
    X : INTEGER)
    RETURN STD_LOGIC;
  FUNCTION has_bport (
    C_HAS_BPORTS : INTEGER; has_aport : INTEGER
    ) RETURN INTEGER;

END encode_8b10b_pkg;

-------------------------------------------------------------------------------
-- Package Body
-------------------------------------------------------------------------------
PACKAGE BODY encode_8b10b_pkg IS

-------------------------------------------------------------------------------
-- Determine initial value of DOUT based on C_FORCE_CODE_DISP and
-- C_FORCE_CODE_VAL
-------------------------------------------------------------------------------
  FUNCTION concat_force_code(
    force_code_disp : INTEGER;
    force_code_val  : STRING)
    RETURN STRING IS
    VARIABLE tmp  : STRING (1 TO 12);
  BEGIN
    IF (force_code_disp = 1) THEN
      tmp := "01" & force_code_val;
    ELSE
      tmp := "00" & force_code_val;
    END IF;
    RETURN tmp;
  END concat_force_code;

-------------------------------------------------------------------------------
-- Converts a STRING containing 1's and 0's into a STD_LOGIC_VECTOR of
--  width nbits.
-------------------------------------------------------------------------------
  FUNCTION str_to_slv(bitsin : STRING; nbits : INTEGER)
    RETURN STD_LOGIC_VECTOR IS
    VARIABLE ret       : STD_LOGIC_VECTOR(bitsin'range);
    VARIABLE ret0s     : STD_LOGIC_VECTOR(1 TO nbits) := (OTHERS => '0');
    VARIABLE retpadded : STD_LOGIC_VECTOR(1 TO nbits) := (OTHERS => '0');
    VARIABLE offset    : INTEGER := 0;
  BEGIN
    IF(bitsin'length = 0) THEN -- Make all '0's
      RETURN ret0s;
    END IF;
    IF(bitsin'length < nbits) THEN -- pad MSBs with '0's
      offset := nbits - bitsin'length;
      FOR i IN bitsin'range LOOP
        IF bitsin(i) = '1' THEN
          retpadded(i+offset) := '1';
        ELSIF (bitsin(i) = 'X' OR bitsin(i) = 'x') THEN
          retpadded(i+offset) := 'X';
        ELSIF (bitsin(i) = 'Z' OR bitsin(i) = 'z') THEN
          retpadded(i+offset) := 'Z';
        ELSIF (bitsin(i) = '0') THEN
          retpadded(i+offset) := '0';
        END IF;
      END LOOP;
      retpadded(1 TO offset) := (OTHERS => '0');
      RETURN retpadded;
    END IF;
    FOR i IN bitsin'range LOOP
      IF bitsin(i) = '1' THEN
        ret(i) := '1';
      ELSIF (bitsin(i) = 'X' OR bitsin(i) = 'x') THEN
        ret(i) := 'X';
      ELSIF (bitsin(i) = 'Z' OR bitsin(i) = 'z') THEN
        ret(i) := 'Z';
      ELSIF (bitsin(i) = '0') THEN
        ret(i) := '0';
      END IF;
    END LOOP;

    RETURN ret;
  END str_to_slv;

-------------------------------------------------------------------------------
  -- This function takes in a boolean value and returns
  -- a STD_LOGIC '0' or '1'
-------------------------------------------------------------------------------
  FUNCTION boolean_to_std_logic(value : BOOLEAN) RETURN STD_LOGIC IS
  BEGIN
    IF (value=TRUE) THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END boolean_to_std_logic;

-------------------------------------------------------------------------------
-- Converts a binary integer (0 or 1) to a std_logic binary value.
-------------------------------------------------------------------------------
  FUNCTION bint_2_sl (X : INTEGER) RETURN STD_LOGIC IS
  BEGIN
    IF (X = 0) THEN
      RETURN '0';
    ELSE
      RETURN '1';
    END IF;
  END bint_2_sl;

-----------------------------------------------------------------------------
-- If C_HAS_BPORTS = 1, then the optional B ports are configured the
-- same as the optional A ports
-- If C_HAS_BPORTS = 0, then the optional B ports are disabled (= 0)
-----------------------------------------------------------------------------
  FUNCTION has_bport (
    C_HAS_BPORTS : INTEGER;
    has_aport    : INTEGER)
    RETURN INTEGER IS
    VARIABLE has_bport : INTEGER;
  BEGIN
    IF (C_HAS_BPORTS = 1) THEN
      has_bport := has_aport;
    ELSE
      has_bport := 0;
    END IF;
    RETURN has_bport;
  END has_bport;

END encode_8b10b_pkg;

