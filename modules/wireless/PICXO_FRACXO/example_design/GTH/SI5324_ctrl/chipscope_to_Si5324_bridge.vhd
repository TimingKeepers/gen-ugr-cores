--
-------------------------------------------------------------------------------------------
-- Copyright © 2010-2011, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Definition of a program memory for KCPSM6 including generic parameters for the 
-- convenient selection of device family, program memory size and the ability to include 
-- the JTAG Loader hardware for rapid software development.
--
-- This file is primarily for use during code development and it is recommended that the 
-- appropriate simplified program memory definition be used in a final production design. 
--
--    Generic                  Values             Comments
--    Parameter                Supported
--  
--    C_FAMILY                 "S6"               Spartan-6 device
--                             "V6"               Virtex-6 device
--                             "7S"               7-Series device 
--                                                   (Artix-7, Kintex-7 or Virtex-7)
--
--    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
--                                                 '4' is not supported for 'S6'.
--
--    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
--
-- Notes
--
-- If your design contains MULTIPLE KCPSM6 instances then only one should have the 
-- JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
-- '1' on one instance of the program memory). Advanced users may be interested to know 
-- that it is possible to connect JTAG Loader to multiple memories and then to use the 
-- JTAG Loader utility to specify which memory contents are to be modified. However, 
-- this scheme does require some effort to set up and the additional connectivity of the 
-- multiple BRAMs can impact the placement, routing and performance of the complete 
-- design. Please contact the author at Xilinx for more detailed information. 
--
-- Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
-- 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
-- without requiring changes to the fundamental hardware definition. However, when the 
-- program memory is 1K then only the lower 10-bits of the address are actually used and 
-- the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
-- 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
--
-- Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
-- size of the program and the device family. 
--
-- In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
-- will require 2 BRAMs to be used. Whilst it is possible to implement a 4K program in a 
-- Spartan-6 device this is a less natural fit within the architecture and either requires 
-- 4 BRAMs and a small amount of logic resulting in a lower performance or 5 BRAMs when 
-- performance is a critical factor. Due to these additional considerations this file 
-- does not support the selection of 4K when using Spartan-6. If one of these special 
-- cases is required then please contact the author at Xilinx to discuss and request a 
-- specific 'ROM_form' template that will meet your requirements. Note that whilst it 
-- it is possible to divide a Spartan-6 BRAM into 2 smaller memories which would each hold
-- a program up to only 512 instructions there is a silicon errata which makes unsuitable. 
--
-- In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
-- obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
-- 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally reported 
-- as being an 18k-bit BRAM). For a program of 4K instructions 2 BRAMs are required.
--
--
-- Program defined by 'C:\Projects\pixo\Chipscope_Ctrl_Of_Si5324_Using_PicoBlaze\chipscope_to_Si5324_bridge.psm'.
--
-- Generated by KCPSM6 Assembler: 31 Jan 2013 - 12:15:22. 
--
-- Assembler used ROM_form template: 16th August 2011
--
-- Standard IEEE libraries
--
--
package jtag_loader_pkg is
 function addr_width_calc (size_in_k: integer) return integer;
end jtag_loader_pkg;
--
package body jtag_loader_pkg is
  function addr_width_calc (size_in_k: integer) return integer is
   begin
    if (size_in_k = 1) then return 10;
      elsif (size_in_k = 2) then return 11;
      elsif (size_in_k = 4) then return 12;
      else report "Invalid BlockRAM size. Please set to 1, 2 or 4 K words." severity FAILURE;
    end if;
    return 0;
  end function addr_width_calc;
end package body;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.jtag_loader_pkg.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity chipscope_to_Si5324_bridge is
  generic(             C_FAMILY : string := "S6"; 
              C_RAM_SIZE_KWORDS : integer := 1;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end chipscope_to_Si5324_bridge;
--
architecture low_level_definition of chipscope_to_Si5324_bridge is
--
signal       address_a : std_logic_vector(15 downto 0);
signal       data_in_a : std_logic_vector(35 downto 0);
signal      data_out_a : std_logic_vector(35 downto 0);
signal    data_out_a_l : std_logic_vector(35 downto 0);
signal    data_out_a_h : std_logic_vector(35 downto 0);
signal       address_b : std_logic_vector(15 downto 0);
signal       data_in_b : std_logic_vector(35 downto 0);
signal     data_in_b_l : std_logic_vector(35 downto 0);
signal      data_out_b : std_logic_vector(35 downto 0);
signal    data_out_b_l : std_logic_vector(35 downto 0);
signal     data_in_b_h : std_logic_vector(35 downto 0);
signal    data_out_b_h : std_logic_vector(35 downto 0);
signal        enable_b : std_logic;
signal           clk_b : std_logic;
signal            we_b : std_logic_vector(7 downto 0);
-- 
signal       jtag_addr : std_logic_vector(11 downto 0);
signal         jtag_we : std_logic;
signal        jtag_clk : std_logic;
signal        jtag_din : std_logic_vector(17 downto 0);
signal       jtag_dout : std_logic_vector(17 downto 0);
signal     jtag_dout_1 : std_logic_vector(17 downto 0);
signal         jtag_en : std_logic_vector(0 downto 0);
-- 
signal picoblaze_reset : std_logic_vector(0 downto 0);
signal         rdl_bus : std_logic_vector(0 downto 0);
--
constant BRAM_ADDRESS_WIDTH  : integer := addr_width_calc(C_RAM_SIZE_KWORDS);
--
--
component jtag_loader_6
generic(                C_JTAG_LOADER_ENABLE : integer := 1;
                                    C_FAMILY : string  := "V6";
                             C_NUM_PICOBLAZE : integer := 1;
                       C_BRAM_MAX_ADDR_WIDTH : integer := 10;
          C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                                C_JTAG_CHAIN : integer := 2;
                              C_ADDR_WIDTH_0 : integer := 10;
                              C_ADDR_WIDTH_1 : integer := 10;
                              C_ADDR_WIDTH_2 : integer := 10;
                              C_ADDR_WIDTH_3 : integer := 10;
                              C_ADDR_WIDTH_4 : integer := 10;
                              C_ADDR_WIDTH_5 : integer := 10;
                              C_ADDR_WIDTH_6 : integer := 10;
                              C_ADDR_WIDTH_7 : integer := 10);
port(              picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                           jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                          jtag_din : out STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                         jtag_addr : out STD_LOGIC_VECTOR(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
                          jtag_clk : out std_logic;
                           jtag_we : out std_logic;
                       jtag_dout_0 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_1 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_2 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_3 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_4 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_5 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_6 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_7 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end component;
--
begin
  --
  --  
  ram_1k_generate : if (C_RAM_SIZE_KWORDS = 1) generate
 
    s6: if (C_FAMILY = "S6") generate 
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "0000000000000000000000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB16BWER
      generic map ( DATA_WIDTH_A => 18,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 18,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"110B110A1109110811071106110511041103110211011100000000000000210C",
                    INIT_01 => X"112A1129112811241123112211211120111F1119111811171116111511141113",
                    INIT_02 => X"11FF1188118F118E118B118A11891184118311371130112F112E112D112C112B",
                    INIT_03 => X"11DF11FE113E11291140110811C01100112A112D11ED11921155112211E11154",
                    INIT_04 => X"110011481159110011FF11AF11A11103110011001103110011001180113F111F",
                    INIT_05 => X"1155114211E51154110011401100110011FF110F11011102111F110011481159",
                    INIT_06 => X"11001180113F111F11DF11FE113E11291140110811C01100112A112D11ED1192",
                    INIT_07 => X"111F110011FA1115110011FA1115110011AB118D116011031100110011031100",
                    INIT_08 => X"112A112D11ED11921155115211E51154110011401100110011FF110F11011102",
                    INIT_09 => X"110011001107110011001100113F111F11DF11FE113E11291140110811C01100",
                    INIT_0A => X"11FF110F11011102111F110011B5110C110011B5110C1100111B117711201107",
                    INIT_0B => X"1140110811C01100112A112D11ED11921155114211E511541100114011001100",
                    INIT_0C => X"114B11F411201105110011001105110011001120113F111F11DF11FE113E1129",
                    INIT_0D => X"110011401100110011FF110F11011102111F110011D6111A110011D6111A1100",
                    INIT_0E => X"11DF11FE113E11291140110811C01100112A112D11ED11921155114211E51154",
                    INIT_0F => X"110011A9110F1100114D114111E01105110011001105110011001120113F111F",
                    INIT_10 => X"B012BFE2065E0654110011401100110011FF110F11011102111F110011A9110F",
                    INIT_11 => X"05771A6F1B0105866133DD0806BAA13306AD1D0805771A531B0105771A381B01",
                    INIT_12 => X"A133072A6133DD8006BAA13306AD1D8005771A531B010586A13306DA17001800",
                    INIT_13 => X"1567156E15691574157315651554150D213705771A8B1B0105ED07FD07F52131",
                    INIT_14 => X"15691574156115631569156E1575156D156D156F156315201543153215491520",
                    INIT_15 => X"156815631574156915771553152015731575154215201520150D1500156E156F",
                    INIT_16 => X"150D15001520152E152E152E1529153815341535153915411543155015281520",
                    INIT_17 => X"1532154D15281520154D154F155215501545154515201542154B153115201520",
                    INIT_18 => X"155215521545150D150D15001520152E152E152E152E15291538153015431534",
                    INIT_19 => X"15201565156C15621561156E157515201543153215491520152D15201552154F",
                    INIT_1A => X"150D152115651574156115631569156E1575156D156D156F15631520156F1574",
                    INIT_1B => X"157415201565157315611565156C155015201520152015201520152015201520",
                    INIT_1C => X"156F15701520156515741565156C1570156D156F156315201561152015791572",
                    INIT_1D => X"15651568157415201566156F15201565156C1563157915631520157215651577",
                    INIT_1E => X"150D1500150D152E156415721561156F156215201535153015371543154B1520",
                    INIT_1F => X"1548154D153115361531150D150D1500150D157A1548154D153515351531150D",
                    INIT_20 => X"1531150D150D1500150D157A1548154D153715361531150D150D1500150D157A",
                    INIT_21 => X"150D157A1548154D153415371531150D150D1500150D157A1548154D15331537",
                    INIT_22 => X"D5522221D54805C705A0222905CC058D05C7153E057E057E05F6052905F61500",
                    INIT_23 => X"058D6247D80F1800057E05EAA13306AD1D08222305C705C7153F228AD5572237",
                    INIT_24 => X"D820180105C7059B350F058005C7152B058D058D058D058D058D058D058D058D",
                    INIT_25 => X"059B058005EA058D058D058D058D057E6259F801D700057E18001700057E623D",
                    INIT_26 => X"17F06266D70F38001701058D058F04D0A13306DA05F9058D058D058F047005C7",
                    INIT_27 => X"04D0A13306DA05F9058D058D058F047005C7059B058005EA058D058D058D3801",
                    INIT_28 => X"06C603210294A13306AD1D08225498022223D804627DD70F38001701058D058F",
                    INIT_29 => X"500007A008B062A0DBFCA2A005B21E0305771AA51B0205EA2223058005F0A133",
                    INIT_2A => X"156E156515201565157315611565156C1550150D150D229405771ADF1B0205ED",
                    INIT_2B => X"152D153315281520157415691562152D15301531152015611520157215651574",
                    INIT_2C => X"1561156D15691563156515641561157815651568152015741569156715691564",
                    INIT_2D => X"150D15001520153E15201520157315731565157215641564156115201529156C",
                    INIT_2E => X"1520157315611577152015741561156815741520152C157915721572156F1553",
                    INIT_2F => X"1572156415641561152015641569156C156115761520156115201574156F156E",
                    INIT_30 => X"15651567156E1561157215201565156815741520156E15691520157315731565",
                    INIT_31 => X"152115781565156815201546154615331520156F157415201530153015301520",
                    INIT_32 => X"150D232105771A6B1B0305ED50000DA0A32A05B21E0205771A2F1B0305EA1500",
                    INIT_33 => X"156E15611520157215651574156E156515201565157315611565156C1550150D",
                    INIT_34 => X"1564152D15321528152015611574156115641520157415691562152D15381520",
                    INIT_35 => X"156C1561156D1569156315651564156115781565156815201574156915671569",
                    INIT_36 => X"15721572156F1553150D15001520153E152015651575156C1561157615201529",
                    INIT_37 => X"15201574156F156E1520157315611577152015741561156815741520152C1579",
                    INIT_38 => X"152015741569156715691564152D1532152015641569156C1561157615201561",
                    INIT_39 => X"1575156C156115761520156C1561156D15691563156515641561157815651568",
                    INIT_3A => X"155F15201520155F152015205000057E05C7458005771AAA1B03150015211565",
                    INIT_3B => X"155F155F155F155F15201520155F155F155F155F1520155F155F155F155F155F",
                    INIT_3C => X"1520157C1520150D155F155F15201520155F155F15201520155F155F15201520",
                    INIT_3D => X"1520152F155C1520155F15201520157C155F155F155F1520152F1520152F157C",
                    INIT_3E => X"155F152F1520152F157C15201520152F155C15201520157C157C155F155F155F",
                    INIT_3F => X"155F157C1520157C152015201520157C1520152F152015271520157C1520150D",
                   INITP_00 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA02",
                   INITP_01 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAEDB882E082DB8820AAAAAAAA",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_04 => X"3AA8A2A97168EAA28AAAD60B5A08AAAAB0AE2A3776BA8AAAAAAAAAAAAAAAAAAA",
                   INITP_05 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82833882ABAB89DC5A",
                   INITP_06 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA828E20AAAAAAAAAAAAAAAAA",
                   INITP_07 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA982AAAAAAAAAAAAAAAAA")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a(31 downto 0),
                  DOPA => data_out_a(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b(31 downto 0),
                  DOPB => data_out_b(35 downto 32), 
                   DIB => data_in_b(31 downto 0),
                  DIPB => data_in_b(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --               
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"110B110A1109110811071106110511041103110211011100000000000000210C",
                    INIT_01 => X"112A1129112811241123112211211120111F1119111811171116111511141113",
                    INIT_02 => X"11FF1188118F118E118B118A11891184118311371130112F112E112D112C112B",
                    INIT_03 => X"11DF11FE113E11291140110811C01100112A112D11ED11921155112211E11154",
                    INIT_04 => X"110011481159110011FF11AF11A11103110011001103110011001180113F111F",
                    INIT_05 => X"1155114211E51154110011401100110011FF110F11011102111F110011481159",
                    INIT_06 => X"11001180113F111F11DF11FE113E11291140110811C01100112A112D11ED1192",
                    INIT_07 => X"111F110011FA1115110011FA1115110011AB118D116011031100110011031100",
                    INIT_08 => X"112A112D11ED11921155115211E51154110011401100110011FF110F11011102",
                    INIT_09 => X"110011001107110011001100113F111F11DF11FE113E11291140110811C01100",
                    INIT_0A => X"11FF110F11011102111F110011B5110C110011B5110C1100111B117711201107",
                    INIT_0B => X"1140110811C01100112A112D11ED11921155114211E511541100114011001100",
                    INIT_0C => X"114B11F411201105110011001105110011001120113F111F11DF11FE113E1129",
                    INIT_0D => X"110011401100110011FF110F11011102111F110011D6111A110011D6111A1100",
                    INIT_0E => X"11DF11FE113E11291140110811C01100112A112D11ED11921155114211E51154",
                    INIT_0F => X"110011A9110F1100114D114111E01105110011001105110011001120113F111F",
                    INIT_10 => X"B012BFE2065E0654110011401100110011FF110F11011102111F110011A9110F",
                    INIT_11 => X"05771A6F1B0105866133DD0806BAA13306AD1D0805771A531B0105771A381B01",
                    INIT_12 => X"A133072A6133DD8006BAA13306AD1D8005771A531B010586A13306DA17001800",
                    INIT_13 => X"1567156E15691574157315651554150D213705771A8B1B0105ED07FD07F52131",
                    INIT_14 => X"15691574156115631569156E1575156D156D156F156315201543153215491520",
                    INIT_15 => X"156815631574156915771553152015731575154215201520150D1500156E156F",
                    INIT_16 => X"150D15001520152E152E152E1529153815341535153915411543155015281520",
                    INIT_17 => X"1532154D15281520154D154F155215501545154515201542154B153115201520",
                    INIT_18 => X"155215521545150D150D15001520152E152E152E152E15291538153015431534",
                    INIT_19 => X"15201565156C15621561156E157515201543153215491520152D15201552154F",
                    INIT_1A => X"150D152115651574156115631569156E1575156D156D156F15631520156F1574",
                    INIT_1B => X"157415201565157315611565156C155015201520152015201520152015201520",
                    INIT_1C => X"156F15701520156515741565156C1570156D156F156315201561152015791572",
                    INIT_1D => X"15651568157415201566156F15201565156C1563157915631520157215651577",
                    INIT_1E => X"150D1500150D152E156415721561156F156215201535153015371543154B1520",
                    INIT_1F => X"1548154D153115361531150D150D1500150D157A1548154D153515351531150D",
                    INIT_20 => X"1531150D150D1500150D157A1548154D153715361531150D150D1500150D157A",
                    INIT_21 => X"150D157A1548154D153415371531150D150D1500150D157A1548154D15331537",
                    INIT_22 => X"D5522221D54805C705A0222905CC058D05C7153E057E057E05F6052905F61500",
                    INIT_23 => X"058D6247D80F1800057E05EAA13306AD1D08222305C705C7153F228AD5572237",
                    INIT_24 => X"D820180105C7059B350F058005C7152B058D058D058D058D058D058D058D058D",
                    INIT_25 => X"059B058005EA058D058D058D058D057E6259F801D700057E18001700057E623D",
                    INIT_26 => X"17F06266D70F38001701058D058F04D0A13306DA05F9058D058D058F047005C7",
                    INIT_27 => X"04D0A13306DA05F9058D058D058F047005C7059B058005EA058D058D058D3801",
                    INIT_28 => X"06C603210294A13306AD1D08225498022223D804627DD70F38001701058D058F",
                    INIT_29 => X"500007A008B062A0DBFCA2A005B21E0305771AA51B0205EA2223058005F0A133",
                    INIT_2A => X"156E156515201565157315611565156C1550150D150D229405771ADF1B0205ED",
                    INIT_2B => X"152D153315281520157415691562152D15301531152015611520157215651574",
                    INIT_2C => X"1561156D15691563156515641561157815651568152015741569156715691564",
                    INIT_2D => X"150D15001520153E15201520157315731565157215641564156115201529156C",
                    INIT_2E => X"1520157315611577152015741561156815741520152C157915721572156F1553",
                    INIT_2F => X"1572156415641561152015641569156C156115761520156115201574156F156E",
                    INIT_30 => X"15651567156E1561157215201565156815741520156E15691520157315731565",
                    INIT_31 => X"152115781565156815201546154615331520156F157415201530153015301520",
                    INIT_32 => X"150D232105771A6B1B0305ED50000DA0A32A05B21E0205771A2F1B0305EA1500",
                    INIT_33 => X"156E15611520157215651574156E156515201565157315611565156C1550150D",
                    INIT_34 => X"1564152D15321528152015611574156115641520157415691562152D15381520",
                    INIT_35 => X"156C1561156D1569156315651564156115781565156815201574156915671569",
                    INIT_36 => X"15721572156F1553150D15001520153E152015651575156C1561157615201529",
                    INIT_37 => X"15201574156F156E1520157315611577152015741561156815741520152C1579",
                    INIT_38 => X"152015741569156715691564152D1532152015641569156C1561157615201561",
                    INIT_39 => X"1575156C156115761520156C1561156D15691563156515641561157815651568",
                    INIT_3A => X"155F15201520155F152015205000057E05C7458005771AAA1B03150015211565",
                    INIT_3B => X"155F155F155F155F15201520155F155F155F155F1520155F155F155F155F155F",
                    INIT_3C => X"1520157C1520150D155F155F15201520155F155F15201520155F155F15201520",
                    INIT_3D => X"1520152F155C1520155F15201520157C155F155F155F1520152F1520152F157C",
                    INIT_3E => X"155F152F1520152F157C15201520152F155C15201520157C157C155F155F155F",
                    INIT_3F => X"155F157C1520157C152015201520157C1520152F152015271520157C1520150D",
                   INITP_00 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA02",
                   INITP_01 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAEDB882E082DB8820AAAAAAAA",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_04 => X"3AA8A2A97168EAA28AAAD60B5A08AAAAB0AE2A3776BA8AAAAAAAAAAAAAAAAAAA",
                   INITP_05 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82833882ABAB89DC5A",
                   INITP_06 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA828E20AAAAAAAAAAAAAAAAA",
                   INITP_07 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA982AAAAAAAAAAAAAAAAA")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"110B110A1109110811071106110511041103110211011100000000000000210C",
                    INIT_01 => X"112A1129112811241123112211211120111F1119111811171116111511141113",
                    INIT_02 => X"11FF1188118F118E118B118A11891184118311371130112F112E112D112C112B",
                    INIT_03 => X"11DF11FE113E11291140110811C01100112A112D11ED11921155112211E11154",
                    INIT_04 => X"110011481159110011FF11AF11A11103110011001103110011001180113F111F",
                    INIT_05 => X"1155114211E51154110011401100110011FF110F11011102111F110011481159",
                    INIT_06 => X"11001180113F111F11DF11FE113E11291140110811C01100112A112D11ED1192",
                    INIT_07 => X"111F110011FA1115110011FA1115110011AB118D116011031100110011031100",
                    INIT_08 => X"112A112D11ED11921155115211E51154110011401100110011FF110F11011102",
                    INIT_09 => X"110011001107110011001100113F111F11DF11FE113E11291140110811C01100",
                    INIT_0A => X"11FF110F11011102111F110011B5110C110011B5110C1100111B117711201107",
                    INIT_0B => X"1140110811C01100112A112D11ED11921155114211E511541100114011001100",
                    INIT_0C => X"114B11F411201105110011001105110011001120113F111F11DF11FE113E1129",
                    INIT_0D => X"110011401100110011FF110F11011102111F110011D6111A110011D6111A1100",
                    INIT_0E => X"11DF11FE113E11291140110811C01100112A112D11ED11921155114211E51154",
                    INIT_0F => X"110011A9110F1100114D114111E01105110011001105110011001120113F111F",
                    INIT_10 => X"B012BFE2065E0654110011401100110011FF110F11011102111F110011A9110F",
                    INIT_11 => X"05771A6F1B0105866133DD0806BAA13306AD1D0805771A531B0105771A381B01",
                    INIT_12 => X"A133072A6133DD8006BAA13306AD1D8005771A531B010586A13306DA17001800",
                    INIT_13 => X"1567156E15691574157315651554150D213705771A8B1B0105ED07FD07F52131",
                    INIT_14 => X"15691574156115631569156E1575156D156D156F156315201543153215491520",
                    INIT_15 => X"156815631574156915771553152015731575154215201520150D1500156E156F",
                    INIT_16 => X"150D15001520152E152E152E1529153815341535153915411543155015281520",
                    INIT_17 => X"1532154D15281520154D154F155215501545154515201542154B153115201520",
                    INIT_18 => X"155215521545150D150D15001520152E152E152E152E15291538153015431534",
                    INIT_19 => X"15201565156C15621561156E157515201543153215491520152D15201552154F",
                    INIT_1A => X"150D152115651574156115631569156E1575156D156D156F15631520156F1574",
                    INIT_1B => X"157415201565157315611565156C155015201520152015201520152015201520",
                    INIT_1C => X"156F15701520156515741565156C1570156D156F156315201561152015791572",
                    INIT_1D => X"15651568157415201566156F15201565156C1563157915631520157215651577",
                    INIT_1E => X"150D1500150D152E156415721561156F156215201535153015371543154B1520",
                    INIT_1F => X"1548154D153115361531150D150D1500150D157A1548154D153515351531150D",
                    INIT_20 => X"1531150D150D1500150D157A1548154D153715361531150D150D1500150D157A",
                    INIT_21 => X"150D157A1548154D153415371531150D150D1500150D157A1548154D15331537",
                    INIT_22 => X"D5522221D54805C705A0222905CC058D05C7153E057E057E05F6052905F61500",
                    INIT_23 => X"058D6247D80F1800057E05EAA13306AD1D08222305C705C7153F228AD5572237",
                    INIT_24 => X"D820180105C7059B350F058005C7152B058D058D058D058D058D058D058D058D",
                    INIT_25 => X"059B058005EA058D058D058D058D057E6259F801D700057E18001700057E623D",
                    INIT_26 => X"17F06266D70F38001701058D058F04D0A13306DA05F9058D058D058F047005C7",
                    INIT_27 => X"04D0A13306DA05F9058D058D058F047005C7059B058005EA058D058D058D3801",
                    INIT_28 => X"06C603210294A13306AD1D08225498022223D804627DD70F38001701058D058F",
                    INIT_29 => X"500007A008B062A0DBFCA2A005B21E0305771AA51B0205EA2223058005F0A133",
                    INIT_2A => X"156E156515201565157315611565156C1550150D150D229405771ADF1B0205ED",
                    INIT_2B => X"152D153315281520157415691562152D15301531152015611520157215651574",
                    INIT_2C => X"1561156D15691563156515641561157815651568152015741569156715691564",
                    INIT_2D => X"150D15001520153E15201520157315731565157215641564156115201529156C",
                    INIT_2E => X"1520157315611577152015741561156815741520152C157915721572156F1553",
                    INIT_2F => X"1572156415641561152015641569156C156115761520156115201574156F156E",
                    INIT_30 => X"15651567156E1561157215201565156815741520156E15691520157315731565",
                    INIT_31 => X"152115781565156815201546154615331520156F157415201530153015301520",
                    INIT_32 => X"150D232105771A6B1B0305ED50000DA0A32A05B21E0205771A2F1B0305EA1500",
                    INIT_33 => X"156E15611520157215651574156E156515201565157315611565156C1550150D",
                    INIT_34 => X"1564152D15321528152015611574156115641520157415691562152D15381520",
                    INIT_35 => X"156C1561156D1569156315651564156115781565156815201574156915671569",
                    INIT_36 => X"15721572156F1553150D15001520153E152015651575156C1561157615201529",
                    INIT_37 => X"15201574156F156E1520157315611577152015741561156815741520152C1579",
                    INIT_38 => X"152015741569156715691564152D1532152015641569156C1561157615201561",
                    INIT_39 => X"1575156C156115761520156C1561156D15691563156515641561157815651568",
                    INIT_3A => X"155F15201520155F152015205000057E05C7458005771AAA1B03150015211565",
                    INIT_3B => X"155F155F155F155F15201520155F155F155F155F1520155F155F155F155F155F",
                    INIT_3C => X"1520157C1520150D155F155F15201520155F155F15201520155F155F15201520",
                    INIT_3D => X"1520152F155C1520155F15201520157C155F155F155F1520152F1520152F157C",
                    INIT_3E => X"155F152F1520152F157C15201520152F155C15201520157C157C155F155F155F",
                    INIT_3F => X"155F157C1520157C152015201520157C1520152F152015271520157C1520150D",
                   INITP_00 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA02",
                   INITP_01 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAEDB882E082DB8820AAAAAAAA",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_04 => X"3AA8A2A97168EAA28AAAD60B5A08AAAAB0AE2A3776BA8AAAAAAAAAAAAAAAAAAA",
                   INITP_05 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82833882ABAB89DC5A",
                   INITP_06 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA828E20AAAAAAAAAAAAAAAAA",
                   INITP_07 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA982AAAAAAAAAAAAAAAAA")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate akv7;
    --
  end generate ram_1k_generate;
  --
  --
  --
  ram_2k_generate : if (C_RAM_SIZE_KWORDS = 2) generate
    --
    --
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"2A292824232221201F191817161514130B0A090807060504030201000000000C",
                    INIT_01 => X"DFFE3E294008C0002A2DED925522E154FF888F8E8B8A89848337302F2E2D2C2B",
                    INIT_02 => X"5542E55400400000FF0F01021F00485900485900FFAFA1030000030000803F1F",
                    INIT_03 => X"1F00FA1500FA1500AB8D60030000030000803F1FDFFE3E294008C0002A2DED92",
                    INIT_04 => X"0000070000003F1FDFFE3E294008C0002A2DED925552E55400400000FF0F0102",
                    INIT_05 => X"4008C0002A2DED925542E55400400000FF0F01021F00B50C00B50C001B772007",
                    INIT_06 => X"00400000FF0F01021F00D61A00D61A004BF420050000050000203F1FDFFE3E29",
                    INIT_07 => X"00A90F004D41E0050000050000203F1FDFFE3E294008C0002A2DED925542E554",
                    INIT_08 => X"776F01863308BA33AD0877530177380112E25E5400400000FF0F01021F00A90F",
                    INIT_09 => X"676E69747365540D37778B01EDFDF531332A3380BA33AD807753018633DA0000",
                    INIT_0A => X"6863746977532073754220200D006E6F69746163696E756D6D6F632043324920",
                    INIT_0B => X"324D28204D4F5250454520424B3120200D00202E2E2E29383435394143502820",
                    INIT_0C => X"20656C62616E7520433249202D20524F5252450D0D00202E2E2E2E2938304334",
                    INIT_0D => X"7420657361656C5020202020202020200D2165746163696E756D6D6F63206F74",
                    INIT_0E => X"65687420666F20656C637963207265776F70206574656C706D6F632061207972",
                    INIT_0F => X"484D3136310D0D000D7A484D3535310D0D000D2E6472616F6220353037434B20",
                    INIT_10 => X"0D7A484D3437310D0D000D7A484D3337310D0D000D7A484D3736310D0D000D7A",
                    INIT_11 => X"8D470F007EEA33AD0823C7C73F8A5737522148C7A029CC8DC73E7E7EF629F600",
                    INIT_12 => X"9B80EA8D8D8D8D7E5901007E00007E3D2001C79B0F80C72B8D8D8D8D8D8D8D8D",
                    INIT_13 => X"D033DAF98D8D8F70C79B80EA8D8D8D01F0660F00018D8FD033DAF98D8D8F70C7",
                    INIT_14 => X"00A0B0A0FCA0B20377A502EA2380F033C6219433AD08540223047D0F00018D8F",
                    INIT_15 => X"2D3328207469622D30312061207265746E6520657361656C500D0D9477DF02ED",
                    INIT_16 => X"0D00203E20207373657264646120296C616D6963656461786568207469676964",
                    INIT_17 => X"726464612064696C6176206120746F6E207361772074616874202C7972726F53",
                    INIT_18 => X"2178656820464633206F74203030302065676E617220656874206E6920737365",
                    INIT_19 => X"6E61207265746E6520657361656C500D0D21776B03ED00A02AB202772F03EA00",
                    INIT_1A => X"6C616D69636564617865682074696769642D32282061746164207469622D3820",
                    INIT_1B => X"20746F6E207361772074616874202C7972726F530D00203E2065756C61762029",
                    INIT_1C => X"756C6176206C616D69636564617865682074696769642D322064696C61762061",
                    INIT_1D => X"5F5F5F5F20205F5F5F5F205F5F5F5F5F5F20205F2020007EC78077AA03002165",
                    INIT_1E => X"202F5C205F20207C5F5F5F202F202F7C207C200D5F5F20205F5F20205F5F2020",
                    INIT_1F => X"5F7C207C2020207C202F2027207C200D5F2F202F7C20202F5C20207C7C5F5F5F",
                    INIT_20 => X"5F5F7C205C202E207C200D5C205F27207C207C2F5C7C207C5C205F5F5F5C2029",
                    INIT_21 => X"7C5F7C200D2920295F28207C207C20207C207C20295F5F5F202F5F5F20207C5F",
                    INIT_22 => X"2F5F5F5F5C7C5F7C20207C5F7C2F5F5F5F5F7C2020207C5F7C5F5F5F5F5C5F5C",
                    INIT_23 => X"4F525045452038304334324D203A6E67697365442065636E6572656665520D0D",
                    INIT_24 => X"2020200D6472616F4220353037434B20726F662072656C6C6F72746E6F43204D",
                    INIT_25 => X"73746E656D656C706D6920364D5350434B202020202020202020202020202020",
                    INIT_26 => X"3A6574614420796C626D657373410D0D2772657473614D2720433249206E6120",
                    INIT_27 => X"73410D32323A35313A3231203A656D695420202033313032206E614A20313320",
                    INIT_28 => X"2065726177647261480D31332E3276203A6E6F69737265562072656C626D6573",
                    INIT_29 => X"79616C70736944202D2048200D756E654D0D0D00772D0500203A6E6769736544",
                    INIT_2A => X"747942204B31206C6C61282064616552202D2052200D756E656D207369687420",
                    INIT_2B => X"C70D770001C70000A0000D296574794228206574697257202D2057200D297365",
                    INIT_2C => X"003A079E0A00C79B0F40C79B0E0E0E0E40C720C7C773C761C7507EC76BC74F7E",
                    INIT_2D => X"BA01000000060400A6A0C7B3CC00000A00F60007B01100E900B900DF007B0061",
                    INIT_2E => X"10CC9C01D90800070008D89001CD0001D30800A70001C7040000013100B30150",
                    INIT_2F => X"43C72443C72343C72243C72143C72043C71F43C71E43C74843C74AC73243D901",
                    INIT_30 => X"3F00A000001F060F4AC703C702C701C700C737484AC706C705C704C74C48C725",
                    INIT_31 => X"484AC744484AC774484AC754484AC7704871795E397C776F7F077D6D664F5B06",
                    INIT_32 => X"02010058000001005880969858400D0358102700C79CC79000C75BC71B4AC764",
                    INIT_33 => X"A393007A01990870000E7F9675937410800096A48DA3930089A493A38D960008",
                    INIT_34 => X"000202A68DA3960008020008FD008F0102080100A308FE0001997F960089A48D",
                    INIT_35 => X"866F0774625E006900866FD000866F0674625E00AA011800A9A9A9A9A90089A6",
                    INIT_36 => X"6F068054625E00FF506900866FD000866F7000866F068054625E006984507900",
                    INIT_37 => X"866FD000866FB000866F065D625E006984507900866F0780546200866F700086",
                    INIT_38 => X"00866F0668625E006984507900866F075D6200866FB000866F065D625E006900",
                    INIT_39 => X"006984507900866F07686200866FB000866F0668625E006900866FD000866FB0",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"C74C0F00018D8F7EA00300000103000000000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFF5BABD6D4FFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFEB4AB754175EFEAEBDFF363FFF8EBABBFFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFDEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDD7FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"6DB6DB7BF93D9604A8F95D557BFFFFFFF5FFFFFFFFFFFFFFFFFFEBFFFFFFFFFF",
                   INITP_06 => X"22304384700447043011800080D866800A418001C4222F7B33330000327FE7FB",
                   INITP_07 => X"C7000000000000000000000000000000000000000000000010C2301118218460")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_l(31 downto 0),
                  DOPA => data_out_a_l(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_l(31 downto 0),
                  DOPB => data_out_b_l(35 downto 32), 
                   DIB => data_in_b_l(31 downto 0),
                  DIPB => data_in_b_l(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_h: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0808080808080808080808080808080808080808080808080808080800000010",
                    INIT_01 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_02 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_03 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_04 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_05 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_06 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_07 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_08 => X"020D0D02B0EE03D0030E020D0D020D0D585F0303080808080808080808080808",
                    INIT_09 => X"0A0A0A0A0A0A0A0A10020D0D02030310D003B0EE03D0030E020D0D02D0030B0C",
                    INIT_0A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_10 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_11 => X"02B16C0C0202D0030E1102020A91EA91EA91EA0202910202020A02020202020A",
                    INIT_12 => X"0202020202020202B1FCEB020C0B02B1EC8C02021A02020A0202020202020202",
                    INIT_13 => X"02D0030202020202020202020202029C8BB16B9C8B020202D003020202020202",
                    INIT_14 => X"280304B16DD1020F020D0D02110202D0030101D0030E11CC91ECB16B9C8B0202",
                    INIT_15 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D02",
                    INIT_16 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_17 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_18 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_19 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D022806D1020F020D0D020A",
                    INIT_1A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A280202A2020D0D0A0A0A",
                    INIT_1E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_20 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_21 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_22 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_23 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_24 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_25 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_26 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_27 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_28 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_29 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28020D0D0A0A0A0A0A0A0A0A0A",
                    INIT_2A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2B => X"120A129D8D0288EA250A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2C => X"288A8AD2CA2802021A020202A2A2A2A202120A12020A020A020A12020A020A02",
                    INIT_2D => X"B2C8A6A6A5A508C802020292020D288A28CAC88AF2CAC8CAC88A281AE8EAC8EA",
                    INIT_2E => X"7292EA4A92684808286892EA4A1288C8B2684808286AB2684828585828B2CF25",
                    INIT_2F => X"03120A03120A03120A03120A03120A03120A03120A03120A03120A020A031288",
                    INIT_30 => X"0828259D850D0D1813025A025A025A025A020A0313025A025A025A020A03120A",
                    INIT_31 => X"0313020A0313020A0313020A0313020A03080808080808080808080808080808",
                    INIT_32 => X"2F0F28B3D9D8C800130808091308080913080809120A120A28020A020A13020A",
                    INIT_33 => X"030328B3C8030813C8A003031303B3620828030303030328030303030303286F",
                    INIT_34 => X"A2684803030303286F2F286F1F289368486F2F28036F1F286A03130328030303",
                    INIT_35 => X"0303A20A03032803C8030302C80303A20A030328B3C808280303030303280303",
                    INIT_36 => X"03A2220A030328180303C8030302C8030302C80303A2220A03032803030603C8",
                    INIT_37 => X"030302C8030302C80303A20A03032803030603C80303A2220A03C8030302C803",
                    INIT_38 => X"C80303A20A03032803030603C80303A20A03C8030302C80303A20A03032803C8",
                    INIT_39 => X"2803030603C80303A20A03C8030302C80303A20A03032803C8030302C8030302",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"020A1D2840020202024D4028406D404800000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFEE9C9BA4FFFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFF9969FFAA37EDE46FDBF9332FFCF755FBFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFA7FFFFFFFFFFFFFFFFFFFFFFFFFFFFE6D3FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"DB6DB6D6C8A68E7C81FAAAAA97305AB5A6FFFFFFFFFFFFFFFFFFF9FFFFFFFFFF",
                   INITP_06 => X"DDCFBC7B8EFBB8FBCFEE79FF1FB65D7FF5BE7FFF30888AD6EEEEFFFFE0D55D56",
                   INITP_07 => X"9F3F00000000000000000000000000000000000000000000EF3DCFEEE7DE7B9F")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_h(31 downto 0),
                  DOPA => data_out_a_h(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_h(31 downto 0),
                  DOPB => data_out_b_h(35 downto 32), 
                   DIB => data_in_b_h(31 downto 0),
                  DIPB => data_in_b_h(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '0' & address(10 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "0000000000000000";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '0' & jtag_addr(10 downto 0) & "0000";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"110B110A1109110811071106110511041103110211011100000000000000210C",
                    INIT_01 => X"112A1129112811241123112211211120111F1119111811171116111511141113",
                    INIT_02 => X"11FF1188118F118E118B118A11891184118311371130112F112E112D112C112B",
                    INIT_03 => X"11DF11FE113E11291140110811C01100112A112D11ED11921155112211E11154",
                    INIT_04 => X"110011481159110011FF11AF11A11103110011001103110011001180113F111F",
                    INIT_05 => X"1155114211E51154110011401100110011FF110F11011102111F110011481159",
                    INIT_06 => X"11001180113F111F11DF11FE113E11291140110811C01100112A112D11ED1192",
                    INIT_07 => X"111F110011FA1115110011FA1115110011AB118D116011031100110011031100",
                    INIT_08 => X"112A112D11ED11921155115211E51154110011401100110011FF110F11011102",
                    INIT_09 => X"110011001107110011001100113F111F11DF11FE113E11291140110811C01100",
                    INIT_0A => X"11FF110F11011102111F110011B5110C110011B5110C1100111B117711201107",
                    INIT_0B => X"1140110811C01100112A112D11ED11921155114211E511541100114011001100",
                    INIT_0C => X"114B11F411201105110011001105110011001120113F111F11DF11FE113E1129",
                    INIT_0D => X"110011401100110011FF110F11011102111F110011D6111A110011D6111A1100",
                    INIT_0E => X"11DF11FE113E11291140110811C01100112A112D11ED11921155114211E51154",
                    INIT_0F => X"110011A9110F1100114D114111E01105110011001105110011001120113F111F",
                    INIT_10 => X"B012BFE2065E0654110011401100110011FF110F11011102111F110011A9110F",
                    INIT_11 => X"05771A6F1B0105866133DD0806BAA13306AD1D0805771A531B0105771A381B01",
                    INIT_12 => X"A133072A6133DD8006BAA13306AD1D8005771A531B010586A13306DA17001800",
                    INIT_13 => X"1567156E15691574157315651554150D213705771A8B1B0105ED07FD07F52131",
                    INIT_14 => X"15691574156115631569156E1575156D156D156F156315201543153215491520",
                    INIT_15 => X"156815631574156915771553152015731575154215201520150D1500156E156F",
                    INIT_16 => X"150D15001520152E152E152E1529153815341535153915411543155015281520",
                    INIT_17 => X"1532154D15281520154D154F155215501545154515201542154B153115201520",
                    INIT_18 => X"155215521545150D150D15001520152E152E152E152E15291538153015431534",
                    INIT_19 => X"15201565156C15621561156E157515201543153215491520152D15201552154F",
                    INIT_1A => X"150D152115651574156115631569156E1575156D156D156F15631520156F1574",
                    INIT_1B => X"157415201565157315611565156C155015201520152015201520152015201520",
                    INIT_1C => X"156F15701520156515741565156C1570156D156F156315201561152015791572",
                    INIT_1D => X"15651568157415201566156F15201565156C1563157915631520157215651577",
                    INIT_1E => X"150D1500150D152E156415721561156F156215201535153015371543154B1520",
                    INIT_1F => X"1548154D153115361531150D150D1500150D157A1548154D153515351531150D",
                    INIT_20 => X"1531150D150D1500150D157A1548154D153715361531150D150D1500150D157A",
                    INIT_21 => X"150D157A1548154D153415371531150D150D1500150D157A1548154D15331537",
                    INIT_22 => X"D5522221D54805C705A0222905CC058D05C7153E057E057E05F6052905F61500",
                    INIT_23 => X"058D6247D80F1800057E05EAA13306AD1D08222305C705C7153F228AD5572237",
                    INIT_24 => X"D820180105C7059B350F058005C7152B058D058D058D058D058D058D058D058D",
                    INIT_25 => X"059B058005EA058D058D058D058D057E6259F801D700057E18001700057E623D",
                    INIT_26 => X"17F06266D70F38001701058D058F04D0A13306DA05F9058D058D058F047005C7",
                    INIT_27 => X"04D0A13306DA05F9058D058D058F047005C7059B058005EA058D058D058D3801",
                    INIT_28 => X"06C603210294A13306AD1D08225498022223D804627DD70F38001701058D058F",
                    INIT_29 => X"500007A008B062A0DBFCA2A005B21E0305771AA51B0205EA2223058005F0A133",
                    INIT_2A => X"156E156515201565157315611565156C1550150D150D229405771ADF1B0205ED",
                    INIT_2B => X"152D153315281520157415691562152D15301531152015611520157215651574",
                    INIT_2C => X"1561156D15691563156515641561157815651568152015741569156715691564",
                    INIT_2D => X"150D15001520153E15201520157315731565157215641564156115201529156C",
                    INIT_2E => X"1520157315611577152015741561156815741520152C157915721572156F1553",
                    INIT_2F => X"1572156415641561152015641569156C156115761520156115201574156F156E",
                    INIT_30 => X"15651567156E1561157215201565156815741520156E15691520157315731565",
                    INIT_31 => X"152115781565156815201546154615331520156F157415201530153015301520",
                    INIT_32 => X"150D232105771A6B1B0305ED50000DA0A32A05B21E0205771A2F1B0305EA1500",
                    INIT_33 => X"156E15611520157215651574156E156515201565157315611565156C1550150D",
                    INIT_34 => X"1564152D15321528152015611574156115641520157415691562152D15381520",
                    INIT_35 => X"156C1561156D1569156315651564156115781565156815201574156915671569",
                    INIT_36 => X"15721572156F1553150D15001520153E152015651575156C1561157615201529",
                    INIT_37 => X"15201574156F156E1520157315611577152015741561156815741520152C1579",
                    INIT_38 => X"152015741569156715691564152D1532152015641569156C1561157615201561",
                    INIT_39 => X"1575156C156115761520156C1561156D15691563156515641561157815651568",
                    INIT_3A => X"155F15201520155F152015205000057E05C7458005771AAA1B03150015211565",
                    INIT_3B => X"155F155F155F155F15201520155F155F155F155F1520155F155F155F155F155F",
                    INIT_3C => X"1520157C1520150D155F155F15201520155F155F15201520155F155F15201520",
                    INIT_3D => X"1520152F155C1520155F15201520157C155F155F155F1520152F1520152F157C",
                    INIT_3E => X"155F152F1520152F157C15201520152F155C15201520157C157C155F155F155F",
                    INIT_3F => X"155F157C1520157C152015201520157C1520152F152015271520157C1520150D",
                    INIT_40 => X"157C1520157C152F155C157C1520157C155C1520155F155F155F155C15201529",
                    INIT_41 => X"155F155F157C1520155C1520152E1520157C1520150D155C1520155F15271520",
                    INIT_42 => X"157C1520157C15201529155F155F155F1520152F155F155F15201520157C155F",
                    INIT_43 => X"157C155F157C1520150D152915201529155F15281520157C1520157C15201520",
                    INIT_44 => X"155F155F157C152015201520157C155F157C155F155F155F155F155C155F155C",
                    INIT_45 => X"152F155F155F155F155C157C155F157C15201520157C155F157C152F155F155F",
                    INIT_46 => X"1569157315651544152015651563156E156515721565156615651552150D150D",
                    INIT_47 => X"154F1552155015451545152015381530154315341532154D1520153A156E1567",
                    INIT_48 => X"1572156F1566152015721565156C156C156F15721574156E156F15431520154D",
                    INIT_49 => X"152015201520150D156415721561156F154215201535153015371543154B1520",
                    INIT_4A => X"154B152015201520152015201520152015201520152015201520152015201520",
                    INIT_4B => X"15731574156E1565156D1565156C1570156D156915201536154D155315501543",
                    INIT_4C => X"152715721565157415731561154D152715201543153215491520156E15611520",
                    INIT_4D => X"153A156515741561154415201579156C1562156D1565157315731541150D150D",
                    INIT_4E => X"155415201520152015331531153015321520156E1561154A1520153115331520",
                    INIT_4F => X"15731541150D15321532153A15351531153A153215311520153A1565156D1569",
                    INIT_50 => X"153A156E156F15691573157215651556152015721565156C1562156D15651573",
                    INIT_51 => X"152015651572156115771564157215611548150D15311533152E153215761520",
                    INIT_52 => X"154D150D150D500005771A2D1B0515001520153A156E15671569157315651544",
                    INIT_53 => X"15791561156C15701573156915441520152D152015481520150D1575156E1565",
                    INIT_54 => X"1520152D152015521520150D1575156E1565156D152015731569156815741520",
                    INIT_55 => X"1574157915421520154B15311520156C156C1561152815201564156115651552",
                    INIT_56 => X"15281520156515741569157215571520152D152015571520150D152915731565",
                    INIT_57 => X"25C7150D25773B001A0105C71000D5004BA01500150D15291565157415791542",
                    INIT_58 => X"054025C7152025C705C7157305C7156105C71550257E05C7156B05C7154F057E",
                    INIT_59 => X"5000153A1507A59E950A500005C7059B350F054005C7059B450E450E450E450E",
                    INIT_5A => X"500095F690001507E5B09511900095E9900015B9500035DFD000D57B9000D561",
                    INIT_5B => X"65BA90014D004C004B004A061004900005A605A005C725B305CC1A005000150A",
                    INIT_5C => X"65D3D008900011A75000D50165C7D00490005000B001B031500065B39E014A50",
                    INIT_5D => X"E51025CCD59C950125D9D008900011075000D00825D8D590950125CD10009101",
                    INIT_5E => X"25C7151F064325C7151E064325C71548064325C7154A05C71532064325D91101",
                    INIT_5F => X"064325C71524064325C71523064325C71522064325C71521064325C715200643",
                    INIT_60 => X"B50005C715370648264A05C7B50605C7B50505C7B50405C7154C064825C71525",
                    INIT_61 => X"103F50004BA03B000A001A1F1B06300F264A05C7B50305C7B50205C7B50105C7",
                    INIT_62 => X"064810711079105E1039107C1077106F107F1007107D106D1066104F105B1006",
                    INIT_63 => X"0648264A05C715440648264A05C715740648264A05C715540648264A05C71570",
                    INIT_64 => X"265810101127120025C7159C25C71590500005C7155B05C7151B264A05C71564",
                    INIT_65 => X"5F021F0150006658B200B10090010000265810801196129826581040110D1203",
                    INIT_66 => X"11805000069606A4068D06A306935000068906A4069306A3068D06965000DF08",
                    INIT_67 => X"06A306935000667A91010699110826709000410E067F0696267506936674C510",
                    INIT_68 => X"9002DF085F01500006A3DF083FFE5000D5010699267F06965000068906A4068D",
                    INIT_69 => X"4500D002900206A6068D06A306965000DF085F025000DF083FFD5000268FD001",
                    INIT_6A => X"15740662065E500066AA90011018500006A906A906A906A906A95000068906A6",
                    INIT_6B => X"0686066F450715740662065E5000066990000686066F05D090000686066F4506",
                    INIT_6C => X"066F057090000686066F4506458015540662065E5000066906840D5006799000",
                    INIT_6D => X"066F4506458015540662065E500030FF0650066990000686066F05D090000686",
                    INIT_6E => X"06840D50067990000686066F450745801554066290000686066F057090000686",
                    INIT_6F => X"0686066F05D090000686066F05B090000686066F4506155D0662065E50000669",
                    INIT_70 => X"155D066290000686066F05B090000686066F4506155D0662065E500006699000",
                    INIT_71 => X"90000686066F450615680662065E5000066906840D50067990000686066F4507",
                    INIT_72 => X"0686066F450615680662065E5000066990000686066F05D090000686066F05B0",
                    INIT_73 => X"5000066906840D50067990000686066F45071568066290000686066F05B09000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"05C7154C3A0F50008001058D058F057E04A09A03800050008001DA0380009000",
                   INITP_00 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA02",
                   INITP_01 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAEDB882E082DB8820AAAAAAAA",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_04 => X"3AA8A2A97168EAA28AAAD60B5A08AAAAB0AE2A3776BA8AAAAAAAAAAAAAAAAAAA",
                   INITP_05 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82833882ABAB89DC5A",
                   INITP_06 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA828E20AAAAAAAAAAAAAAAAA",
                   INITP_07 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA982AAAAAAAAAAAAAAAAA",
                   INITP_08 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0A => X"896DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82AAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"A28A28A28A28A229B4C08D2DC0AC2AB4D553AB899DDDD8DD976A0A5522888A22",
                   INITP_0C => X"AB62DAAC2AAAAAAA0B5480808088A228A8A8A8A8AAAAAAAAA940A22222A22228",
                   INITP_0D => X"A3A3A4AA8BA42E8E90A8AE8E8E90AA8BA4AAE8E92AD2AAAA42AA8A2C22A22AAA",
                   INITP_0E => X"00000000000000000000000000000000A8BA4BA3A4AAE8E8E92AA2E92E8E92AB",
                   INITP_0F => X"82AA0AAA00000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '0' & address(10 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "0000000000000000";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '0' & jtag_addr(10 downto 0) & "0000";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"110B110A1109110811071106110511041103110211011100000000000000210C",
                    INIT_01 => X"112A1129112811241123112211211120111F1119111811171116111511141113",
                    INIT_02 => X"11FF1188118F118E118B118A11891184118311371130112F112E112D112C112B",
                    INIT_03 => X"11DF11FE113E11291140110811C01100112A112D11ED11921155112211E11154",
                    INIT_04 => X"110011481159110011FF11AF11A11103110011001103110011001180113F111F",
                    INIT_05 => X"1155114211E51154110011401100110011FF110F11011102111F110011481159",
                    INIT_06 => X"11001180113F111F11DF11FE113E11291140110811C01100112A112D11ED1192",
                    INIT_07 => X"111F110011FA1115110011FA1115110011AB118D116011031100110011031100",
                    INIT_08 => X"112A112D11ED11921155115211E51154110011401100110011FF110F11011102",
                    INIT_09 => X"110011001107110011001100113F111F11DF11FE113E11291140110811C01100",
                    INIT_0A => X"11FF110F11011102111F110011B5110C110011B5110C1100111B117711201107",
                    INIT_0B => X"1140110811C01100112A112D11ED11921155114211E511541100114011001100",
                    INIT_0C => X"114B11F411201105110011001105110011001120113F111F11DF11FE113E1129",
                    INIT_0D => X"110011401100110011FF110F11011102111F110011D6111A110011D6111A1100",
                    INIT_0E => X"11DF11FE113E11291140110811C01100112A112D11ED11921155114211E51154",
                    INIT_0F => X"110011A9110F1100114D114111E01105110011001105110011001120113F111F",
                    INIT_10 => X"B012BFE2065E0654110011401100110011FF110F11011102111F110011A9110F",
                    INIT_11 => X"05771A6F1B0105866133DD0806BAA13306AD1D0805771A531B0105771A381B01",
                    INIT_12 => X"A133072A6133DD8006BAA13306AD1D8005771A531B010586A13306DA17001800",
                    INIT_13 => X"1567156E15691574157315651554150D213705771A8B1B0105ED07FD07F52131",
                    INIT_14 => X"15691574156115631569156E1575156D156D156F156315201543153215491520",
                    INIT_15 => X"156815631574156915771553152015731575154215201520150D1500156E156F",
                    INIT_16 => X"150D15001520152E152E152E1529153815341535153915411543155015281520",
                    INIT_17 => X"1532154D15281520154D154F155215501545154515201542154B153115201520",
                    INIT_18 => X"155215521545150D150D15001520152E152E152E152E15291538153015431534",
                    INIT_19 => X"15201565156C15621561156E157515201543153215491520152D15201552154F",
                    INIT_1A => X"150D152115651574156115631569156E1575156D156D156F15631520156F1574",
                    INIT_1B => X"157415201565157315611565156C155015201520152015201520152015201520",
                    INIT_1C => X"156F15701520156515741565156C1570156D156F156315201561152015791572",
                    INIT_1D => X"15651568157415201566156F15201565156C1563157915631520157215651577",
                    INIT_1E => X"150D1500150D152E156415721561156F156215201535153015371543154B1520",
                    INIT_1F => X"1548154D153115361531150D150D1500150D157A1548154D153515351531150D",
                    INIT_20 => X"1531150D150D1500150D157A1548154D153715361531150D150D1500150D157A",
                    INIT_21 => X"150D157A1548154D153415371531150D150D1500150D157A1548154D15331537",
                    INIT_22 => X"D5522221D54805C705A0222905CC058D05C7153E057E057E05F6052905F61500",
                    INIT_23 => X"058D6247D80F1800057E05EAA13306AD1D08222305C705C7153F228AD5572237",
                    INIT_24 => X"D820180105C7059B350F058005C7152B058D058D058D058D058D058D058D058D",
                    INIT_25 => X"059B058005EA058D058D058D058D057E6259F801D700057E18001700057E623D",
                    INIT_26 => X"17F06266D70F38001701058D058F04D0A13306DA05F9058D058D058F047005C7",
                    INIT_27 => X"04D0A13306DA05F9058D058D058F047005C7059B058005EA058D058D058D3801",
                    INIT_28 => X"06C603210294A13306AD1D08225498022223D804627DD70F38001701058D058F",
                    INIT_29 => X"500007A008B062A0DBFCA2A005B21E0305771AA51B0205EA2223058005F0A133",
                    INIT_2A => X"156E156515201565157315611565156C1550150D150D229405771ADF1B0205ED",
                    INIT_2B => X"152D153315281520157415691562152D15301531152015611520157215651574",
                    INIT_2C => X"1561156D15691563156515641561157815651568152015741569156715691564",
                    INIT_2D => X"150D15001520153E15201520157315731565157215641564156115201529156C",
                    INIT_2E => X"1520157315611577152015741561156815741520152C157915721572156F1553",
                    INIT_2F => X"1572156415641561152015641569156C156115761520156115201574156F156E",
                    INIT_30 => X"15651567156E1561157215201565156815741520156E15691520157315731565",
                    INIT_31 => X"152115781565156815201546154615331520156F157415201530153015301520",
                    INIT_32 => X"150D232105771A6B1B0305ED50000DA0A32A05B21E0205771A2F1B0305EA1500",
                    INIT_33 => X"156E15611520157215651574156E156515201565157315611565156C1550150D",
                    INIT_34 => X"1564152D15321528152015611574156115641520157415691562152D15381520",
                    INIT_35 => X"156C1561156D1569156315651564156115781565156815201574156915671569",
                    INIT_36 => X"15721572156F1553150D15001520153E152015651575156C1561157615201529",
                    INIT_37 => X"15201574156F156E1520157315611577152015741561156815741520152C1579",
                    INIT_38 => X"152015741569156715691564152D1532152015641569156C1561157615201561",
                    INIT_39 => X"1575156C156115761520156C1561156D15691563156515641561157815651568",
                    INIT_3A => X"155F15201520155F152015205000057E05C7458005771AAA1B03150015211565",
                    INIT_3B => X"155F155F155F155F15201520155F155F155F155F1520155F155F155F155F155F",
                    INIT_3C => X"1520157C1520150D155F155F15201520155F155F15201520155F155F15201520",
                    INIT_3D => X"1520152F155C1520155F15201520157C155F155F155F1520152F1520152F157C",
                    INIT_3E => X"155F152F1520152F157C15201520152F155C15201520157C157C155F155F155F",
                    INIT_3F => X"155F157C1520157C152015201520157C1520152F152015271520157C1520150D",
                    INIT_40 => X"157C1520157C152F155C157C1520157C155C1520155F155F155F155C15201529",
                    INIT_41 => X"155F155F157C1520155C1520152E1520157C1520150D155C1520155F15271520",
                    INIT_42 => X"157C1520157C15201529155F155F155F1520152F155F155F15201520157C155F",
                    INIT_43 => X"157C155F157C1520150D152915201529155F15281520157C1520157C15201520",
                    INIT_44 => X"155F155F157C152015201520157C155F157C155F155F155F155F155C155F155C",
                    INIT_45 => X"152F155F155F155F155C157C155F157C15201520157C155F157C152F155F155F",
                    INIT_46 => X"1569157315651544152015651563156E156515721565156615651552150D150D",
                    INIT_47 => X"154F1552155015451545152015381530154315341532154D1520153A156E1567",
                    INIT_48 => X"1572156F1566152015721565156C156C156F15721574156E156F15431520154D",
                    INIT_49 => X"152015201520150D156415721561156F154215201535153015371543154B1520",
                    INIT_4A => X"154B152015201520152015201520152015201520152015201520152015201520",
                    INIT_4B => X"15731574156E1565156D1565156C1570156D156915201536154D155315501543",
                    INIT_4C => X"152715721565157415731561154D152715201543153215491520156E15611520",
                    INIT_4D => X"153A156515741561154415201579156C1562156D1565157315731541150D150D",
                    INIT_4E => X"155415201520152015331531153015321520156E1561154A1520153115331520",
                    INIT_4F => X"15731541150D15321532153A15351531153A153215311520153A1565156D1569",
                    INIT_50 => X"153A156E156F15691573157215651556152015721565156C1562156D15651573",
                    INIT_51 => X"152015651572156115771564157215611548150D15311533152E153215761520",
                    INIT_52 => X"154D150D150D500005771A2D1B0515001520153A156E15671569157315651544",
                    INIT_53 => X"15791561156C15701573156915441520152D152015481520150D1575156E1565",
                    INIT_54 => X"1520152D152015521520150D1575156E1565156D152015731569156815741520",
                    INIT_55 => X"1574157915421520154B15311520156C156C1561152815201564156115651552",
                    INIT_56 => X"15281520156515741569157215571520152D152015571520150D152915731565",
                    INIT_57 => X"25C7150D25773B001A0105C71000D5004BA01500150D15291565157415791542",
                    INIT_58 => X"054025C7152025C705C7157305C7156105C71550257E05C7156B05C7154F057E",
                    INIT_59 => X"5000153A1507A59E950A500005C7059B350F054005C7059B450E450E450E450E",
                    INIT_5A => X"500095F690001507E5B09511900095E9900015B9500035DFD000D57B9000D561",
                    INIT_5B => X"65BA90014D004C004B004A061004900005A605A005C725B305CC1A005000150A",
                    INIT_5C => X"65D3D008900011A75000D50165C7D00490005000B001B031500065B39E014A50",
                    INIT_5D => X"E51025CCD59C950125D9D008900011075000D00825D8D590950125CD10009101",
                    INIT_5E => X"25C7151F064325C7151E064325C71548064325C7154A05C71532064325D91101",
                    INIT_5F => X"064325C71524064325C71523064325C71522064325C71521064325C715200643",
                    INIT_60 => X"B50005C715370648264A05C7B50605C7B50505C7B50405C7154C064825C71525",
                    INIT_61 => X"103F50004BA03B000A001A1F1B06300F264A05C7B50305C7B50205C7B50105C7",
                    INIT_62 => X"064810711079105E1039107C1077106F107F1007107D106D1066104F105B1006",
                    INIT_63 => X"0648264A05C715440648264A05C715740648264A05C715540648264A05C71570",
                    INIT_64 => X"265810101127120025C7159C25C71590500005C7155B05C7151B264A05C71564",
                    INIT_65 => X"5F021F0150006658B200B10090010000265810801196129826581040110D1203",
                    INIT_66 => X"11805000069606A4068D06A306935000068906A4069306A3068D06965000DF08",
                    INIT_67 => X"06A306935000667A91010699110826709000410E067F0696267506936674C510",
                    INIT_68 => X"9002DF085F01500006A3DF083FFE5000D5010699267F06965000068906A4068D",
                    INIT_69 => X"4500D002900206A6068D06A306965000DF085F025000DF083FFD5000268FD001",
                    INIT_6A => X"15740662065E500066AA90011018500006A906A906A906A906A95000068906A6",
                    INIT_6B => X"0686066F450715740662065E5000066990000686066F05D090000686066F4506",
                    INIT_6C => X"066F057090000686066F4506458015540662065E5000066906840D5006799000",
                    INIT_6D => X"066F4506458015540662065E500030FF0650066990000686066F05D090000686",
                    INIT_6E => X"06840D50067990000686066F450745801554066290000686066F057090000686",
                    INIT_6F => X"0686066F05D090000686066F05B090000686066F4506155D0662065E50000669",
                    INIT_70 => X"155D066290000686066F05B090000686066F4506155D0662065E500006699000",
                    INIT_71 => X"90000686066F450615680662065E5000066906840D50067990000686066F4507",
                    INIT_72 => X"0686066F450615680662065E5000066990000686066F05D090000686066F05B0",
                    INIT_73 => X"5000066906840D50067990000686066F45071568066290000686066F05B09000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"05C7154C3A0F50008001058D058F057E04A09A03800050008001DA0380009000",
                   INITP_00 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA02",
                   INITP_01 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0AAEDB882E082DB8820AAAAAAAA",
                   INITP_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_04 => X"3AA8A2A97168EAA28AAAD60B5A08AAAAB0AE2A3776BA8AAAAAAAAAAAAAAAAAAA",
                   INITP_05 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82833882ABAB89DC5A",
                   INITP_06 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA828E20AAAAAAAAAAAAAAAAA",
                   INITP_07 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA982AAAAAAAAAAAAAAAAA",
                   INITP_08 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_09 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                   INITP_0A => X"896DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA82AAAAAAAAAAAAAAAAAAAA",
                   INITP_0B => X"A28A28A28A28A229B4C08D2DC0AC2AB4D553AB899DDDD8DD976A0A5522888A22",
                   INITP_0C => X"AB62DAAC2AAAAAAA0B5480808088A228A8A8A8A8AAAAAAAAA940A22222A22228",
                   INITP_0D => X"A3A3A4AA8BA42E8E90A8AE8E8E90AA8BA4AAE8E92AD2AAAA42AA8A2C22A22AAA",
                   INITP_0E => X"00000000000000000000000000000000A8BA4BA3A4AAE8E8E92AA2E92E8E92AB",
                   INITP_0F => X"82AA0AAA00000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_2k_generate;
  --
  --	
  ram_4k_generate : if (C_RAM_SIZE_KWORDS = 4) generate
    s6: if (C_FAMILY = "S6") generate
      assert(1=0) report "4K BRAM in Spartan-6 is a special case not supported by this template." severity FAILURE;
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '0' & address(11 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "0000000000000000";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '0' & jtag_addr(11 downto 0) & "000";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"2A292824232221201F191817161514130B0A090807060504030201000000000C",
                    INIT_01 => X"DFFE3E294008C0002A2DED925522E154FF888F8E8B8A89848337302F2E2D2C2B",
                    INIT_02 => X"5542E55400400000FF0F01021F00485900485900FFAFA1030000030000803F1F",
                    INIT_03 => X"1F00FA1500FA1500AB8D60030000030000803F1FDFFE3E294008C0002A2DED92",
                    INIT_04 => X"0000070000003F1FDFFE3E294008C0002A2DED925552E55400400000FF0F0102",
                    INIT_05 => X"4008C0002A2DED925542E55400400000FF0F01021F00B50C00B50C001B772007",
                    INIT_06 => X"00400000FF0F01021F00D61A00D61A004BF420050000050000203F1FDFFE3E29",
                    INIT_07 => X"00A90F004D41E0050000050000203F1FDFFE3E294008C0002A2DED925542E554",
                    INIT_08 => X"776F01863308BA33AD0877530177380112E25E5400400000FF0F01021F00A90F",
                    INIT_09 => X"676E69747365540D37778B01EDFDF531332A3380BA33AD807753018633DA0000",
                    INIT_0A => X"6863746977532073754220200D006E6F69746163696E756D6D6F632043324920",
                    INIT_0B => X"324D28204D4F5250454520424B3120200D00202E2E2E29383435394143502820",
                    INIT_0C => X"20656C62616E7520433249202D20524F5252450D0D00202E2E2E2E2938304334",
                    INIT_0D => X"7420657361656C5020202020202020200D2165746163696E756D6D6F63206F74",
                    INIT_0E => X"65687420666F20656C637963207265776F70206574656C706D6F632061207972",
                    INIT_0F => X"484D3136310D0D000D7A484D3535310D0D000D2E6472616F6220353037434B20",
                    INIT_10 => X"0D7A484D3437310D0D000D7A484D3337310D0D000D7A484D3736310D0D000D7A",
                    INIT_11 => X"8D470F007EEA33AD0823C7C73F8A5737522148C7A029CC8DC73E7E7EF629F600",
                    INIT_12 => X"9B80EA8D8D8D8D7E5901007E00007E3D2001C79B0F80C72B8D8D8D8D8D8D8D8D",
                    INIT_13 => X"D033DAF98D8D8F70C79B80EA8D8D8D01F0660F00018D8FD033DAF98D8D8F70C7",
                    INIT_14 => X"00A0B0A0FCA0B20377A502EA2380F033C6219433AD08540223047D0F00018D8F",
                    INIT_15 => X"2D3328207469622D30312061207265746E6520657361656C500D0D9477DF02ED",
                    INIT_16 => X"0D00203E20207373657264646120296C616D6963656461786568207469676964",
                    INIT_17 => X"726464612064696C6176206120746F6E207361772074616874202C7972726F53",
                    INIT_18 => X"2178656820464633206F74203030302065676E617220656874206E6920737365",
                    INIT_19 => X"6E61207265746E6520657361656C500D0D21776B03ED00A02AB202772F03EA00",
                    INIT_1A => X"6C616D69636564617865682074696769642D32282061746164207469622D3820",
                    INIT_1B => X"20746F6E207361772074616874202C7972726F530D00203E2065756C61762029",
                    INIT_1C => X"756C6176206C616D69636564617865682074696769642D322064696C61762061",
                    INIT_1D => X"5F5F5F5F20205F5F5F5F205F5F5F5F5F5F20205F2020007EC78077AA03002165",
                    INIT_1E => X"202F5C205F20207C5F5F5F202F202F7C207C200D5F5F20205F5F20205F5F2020",
                    INIT_1F => X"5F7C207C2020207C202F2027207C200D5F2F202F7C20202F5C20207C7C5F5F5F",
                    INIT_20 => X"5F5F7C205C202E207C200D5C205F27207C207C2F5C7C207C5C205F5F5F5C2029",
                    INIT_21 => X"7C5F7C200D2920295F28207C207C20207C207C20295F5F5F202F5F5F20207C5F",
                    INIT_22 => X"2F5F5F5F5C7C5F7C20207C5F7C2F5F5F5F5F7C2020207C5F7C5F5F5F5F5C5F5C",
                    INIT_23 => X"4F525045452038304334324D203A6E67697365442065636E6572656665520D0D",
                    INIT_24 => X"2020200D6472616F4220353037434B20726F662072656C6C6F72746E6F43204D",
                    INIT_25 => X"73746E656D656C706D6920364D5350434B202020202020202020202020202020",
                    INIT_26 => X"3A6574614420796C626D657373410D0D2772657473614D2720433249206E6120",
                    INIT_27 => X"73410D32323A35313A3231203A656D695420202033313032206E614A20313320",
                    INIT_28 => X"2065726177647261480D31332E3276203A6E6F69737265562072656C626D6573",
                    INIT_29 => X"79616C70736944202D2048200D756E654D0D0D00772D0500203A6E6769736544",
                    INIT_2A => X"747942204B31206C6C61282064616552202D2052200D756E656D207369687420",
                    INIT_2B => X"C70D770001C70000A0000D296574794228206574697257202D2057200D297365",
                    INIT_2C => X"003A079E0A00C79B0F40C79B0E0E0E0E40C720C7C773C761C7507EC76BC74F7E",
                    INIT_2D => X"BA01000000060400A6A0C7B3CC00000A00F60007B01100E900B900DF007B0061",
                    INIT_2E => X"10CC9C01D90800070008D89001CD0001D30800A70001C7040000013100B30150",
                    INIT_2F => X"43C72443C72343C72243C72143C72043C71F43C71E43C74843C74AC73243D901",
                    INIT_30 => X"3F00A000001F060F4AC703C702C701C700C737484AC706C705C704C74C48C725",
                    INIT_31 => X"484AC744484AC774484AC754484AC7704871795E397C776F7F077D6D664F5B06",
                    INIT_32 => X"02010058000001005880969858400D0358102700C79CC79000C75BC71B4AC764",
                    INIT_33 => X"A393007A01990870000E7F9675937410800096A48DA3930089A493A38D960008",
                    INIT_34 => X"000202A68DA3960008020008FD008F0102080100A308FE0001997F960089A48D",
                    INIT_35 => X"866F0774625E006900866FD000866F0674625E00AA011800A9A9A9A9A90089A6",
                    INIT_36 => X"6F068054625E00FF506900866FD000866F7000866F068054625E006984507900",
                    INIT_37 => X"866FD000866FB000866F065D625E006984507900866F0780546200866F700086",
                    INIT_38 => X"00866F0668625E006984507900866F075D6200866FB000866F065D625E006900",
                    INIT_39 => X"006984507900866F07686200866FB000866F0668625E006900866FD000866FB0",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"C74C0F00018D8F7EA00300000103000000000000000000000000000000000000",
                    INIT_40 => X"420077F9010104005C0060420077EF010104003000FD37042C03210216010B00",
                    INIT_41 => X"00771702010400E000604200770D02010400B400604200770302010400880060",
                    INIT_42 => X"0033E000008FD08D8FB07E01D0B04200010001522A00331900FF106010806042",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000060",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFF5BABD6D4FFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFEB4AB754175EFEAEBDFF363FFF8EBABBFFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFDEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDD7FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"6DB6DB7BF93D9604A8F95D557BFFFFFFF5FFFFFFFFFFFFFFFFFFEBFFFFFFFFFF",
                   INITP_06 => X"22304384700447043011800080D866800A418001C4222F7B33330000327FE7FB",
                   INITP_07 => X"C7000000000000000000000000000000000000000000000010C2301118218460",
                   INITP_08 => X"000000000000000000000000000000000000000065AD4F7C528A514A29452C00",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"0808080808080808080808080808080808080808080808080808080800000010",
                    INIT_01 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_02 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_03 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_04 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_05 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_06 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_07 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_08 => X"020D0D02B0EE03D0030E020D0D020D0D585F0303080808080808080808080808",
                    INIT_09 => X"0A0A0A0A0A0A0A0A10020D0D02030310D003B0EE03D0030E020D0D02D0030B0C",
                    INIT_0A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_10 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_11 => X"02B16C0C0202D0030E1102020A91EA91EA91EA0202910202020A02020202020A",
                    INIT_12 => X"0202020202020202B1FCEB020C0B02B1EC8C02021A02020A0202020202020202",
                    INIT_13 => X"02D0030202020202020202020202029C8BB16B9C8B020202D003020202020202",
                    INIT_14 => X"280304B16DD1020F020D0D02110202D0030101D0030E11CC91ECB16B9C8B0202",
                    INIT_15 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D02",
                    INIT_16 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_17 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_18 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_19 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D022806D1020F020D0D020A",
                    INIT_1A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A280202A2020D0D0A0A0A",
                    INIT_1E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_20 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_21 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_22 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_23 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_24 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_25 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_26 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_27 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_28 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_29 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28020D0D0A0A0A0A0A0A0A0A0A",
                    INIT_2A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2B => X"120A129D8D0288EA250A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2C => X"288A8AD2CA2802021A020202A2A2A2A202120A12020A020A020A12020A020A02",
                    INIT_2D => X"B2C8A6A6A5A508C802020292020D288A28CAC88AF2CAC8CAC88A281AE8EAC8EA",
                    INIT_2E => X"7292EA4A92684808286892EA4A1288C8B2684808286AB2684828585828B2CF25",
                    INIT_2F => X"03120A03120A03120A03120A03120A03120A03120A03120A03120A020A031288",
                    INIT_30 => X"0828259D850D0D1813025A025A025A025A020A0313025A025A025A020A03120A",
                    INIT_31 => X"0313020A0313020A0313020A0313020A03080808080808080808080808080808",
                    INIT_32 => X"2F0F28B3D9D8C800130808091308080913080809120A120A28020A020A13020A",
                    INIT_33 => X"030328B3C8030813C8A003031303B3620828030303030328030303030303286F",
                    INIT_34 => X"A2684803030303286F2F286F1F289368486F2F28036F1F286A03130328030303",
                    INIT_35 => X"0303A20A03032803C8030302C80303A20A030328B3C808280303030303280303",
                    INIT_36 => X"03A2220A030328180303C8030302C8030302C80303A2220A03032803030603C8",
                    INIT_37 => X"030302C8030302C80303A20A03032803030603C80303A2220A03C8030302C803",
                    INIT_38 => X"C80303A20A03032803030603C80303A20A03C8030302C80303A20A03032803C8",
                    INIT_39 => X"2803030603C80303A20A03C8030302C80303A20A03032803C8030302C8030302",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"020A1D2840020202024D4028406D404800000000000000000000000000000000",
                    INIT_40 => X"04B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0CB394ED94ED94ED94ED94ED",
                    INIT_41 => X"B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0C14",
                    INIT_42 => X"28B0E628B8020202020202B8B6B5149B8B9C8C04030ED00388ED052306241404",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000014",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFEE9C9BA4FFFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFF9969FFAA37EDE46FDBF9332FFCF755FBFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFA7FFFFFFFFFFFFFFFFFFFFFFFFFFFFE6D3FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"DB6DB6D6C8A68E7C81FAAAAA97305AB5A6FFFFFFFFFFFFFFFFFFF9FFFFFFFFFF",
                   INITP_06 => X"DDCFBC7B8EFBB8FBCFEE79FF1FB65D7FF5BE7FFF30888AD6EEEEFFFFE0D55D56",
                   INITP_07 => X"9F3F00000000000000000000000000000000000000000000EF3DCFEEE7DE7B9F",
                   INITP_08 => X"0000000000000000000000000000000000000001DDB21B97C8790F21E43C86AA",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '0' & address(11 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "0000000000000000";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '0' & jtag_addr(11 downto 0) & "000";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"2A292824232221201F191817161514130B0A090807060504030201000000000C",
                    INIT_01 => X"DFFE3E294008C0002A2DED925522E154FF888F8E8B8A89848337302F2E2D2C2B",
                    INIT_02 => X"5542E55400400000FF0F01021F00485900485900FFAFA1030000030000803F1F",
                    INIT_03 => X"1F00FA1500FA1500AB8D60030000030000803F1FDFFE3E294008C0002A2DED92",
                    INIT_04 => X"0000070000003F1FDFFE3E294008C0002A2DED925552E55400400000FF0F0102",
                    INIT_05 => X"4008C0002A2DED925542E55400400000FF0F01021F00B50C00B50C001B772007",
                    INIT_06 => X"00400000FF0F01021F00D61A00D61A004BF420050000050000203F1FDFFE3E29",
                    INIT_07 => X"00A90F004D41E0050000050000203F1FDFFE3E294008C0002A2DED925542E554",
                    INIT_08 => X"776F01863308BA33AD0877530177380112E25E5400400000FF0F01021F00A90F",
                    INIT_09 => X"676E69747365540D37778B01EDFDF531332A3380BA33AD807753018633DA0000",
                    INIT_0A => X"6863746977532073754220200D006E6F69746163696E756D6D6F632043324920",
                    INIT_0B => X"324D28204D4F5250454520424B3120200D00202E2E2E29383435394143502820",
                    INIT_0C => X"20656C62616E7520433249202D20524F5252450D0D00202E2E2E2E2938304334",
                    INIT_0D => X"7420657361656C5020202020202020200D2165746163696E756D6D6F63206F74",
                    INIT_0E => X"65687420666F20656C637963207265776F70206574656C706D6F632061207972",
                    INIT_0F => X"484D3136310D0D000D7A484D3535310D0D000D2E6472616F6220353037434B20",
                    INIT_10 => X"0D7A484D3437310D0D000D7A484D3337310D0D000D7A484D3736310D0D000D7A",
                    INIT_11 => X"8D470F007EEA33AD0823C7C73F8A5737522148C7A029CC8DC73E7E7EF629F600",
                    INIT_12 => X"9B80EA8D8D8D8D7E5901007E00007E3D2001C79B0F80C72B8D8D8D8D8D8D8D8D",
                    INIT_13 => X"D033DAF98D8D8F70C79B80EA8D8D8D01F0660F00018D8FD033DAF98D8D8F70C7",
                    INIT_14 => X"00A0B0A0FCA0B20377A502EA2380F033C6219433AD08540223047D0F00018D8F",
                    INIT_15 => X"2D3328207469622D30312061207265746E6520657361656C500D0D9477DF02ED",
                    INIT_16 => X"0D00203E20207373657264646120296C616D6963656461786568207469676964",
                    INIT_17 => X"726464612064696C6176206120746F6E207361772074616874202C7972726F53",
                    INIT_18 => X"2178656820464633206F74203030302065676E617220656874206E6920737365",
                    INIT_19 => X"6E61207265746E6520657361656C500D0D21776B03ED00A02AB202772F03EA00",
                    INIT_1A => X"6C616D69636564617865682074696769642D32282061746164207469622D3820",
                    INIT_1B => X"20746F6E207361772074616874202C7972726F530D00203E2065756C61762029",
                    INIT_1C => X"756C6176206C616D69636564617865682074696769642D322064696C61762061",
                    INIT_1D => X"5F5F5F5F20205F5F5F5F205F5F5F5F5F5F20205F2020007EC78077AA03002165",
                    INIT_1E => X"202F5C205F20207C5F5F5F202F202F7C207C200D5F5F20205F5F20205F5F2020",
                    INIT_1F => X"5F7C207C2020207C202F2027207C200D5F2F202F7C20202F5C20207C7C5F5F5F",
                    INIT_20 => X"5F5F7C205C202E207C200D5C205F27207C207C2F5C7C207C5C205F5F5F5C2029",
                    INIT_21 => X"7C5F7C200D2920295F28207C207C20207C207C20295F5F5F202F5F5F20207C5F",
                    INIT_22 => X"2F5F5F5F5C7C5F7C20207C5F7C2F5F5F5F5F7C2020207C5F7C5F5F5F5F5C5F5C",
                    INIT_23 => X"4F525045452038304334324D203A6E67697365442065636E6572656665520D0D",
                    INIT_24 => X"2020200D6472616F4220353037434B20726F662072656C6C6F72746E6F43204D",
                    INIT_25 => X"73746E656D656C706D6920364D5350434B202020202020202020202020202020",
                    INIT_26 => X"3A6574614420796C626D657373410D0D2772657473614D2720433249206E6120",
                    INIT_27 => X"73410D32323A35313A3231203A656D695420202033313032206E614A20313320",
                    INIT_28 => X"2065726177647261480D31332E3276203A6E6F69737265562072656C626D6573",
                    INIT_29 => X"79616C70736944202D2048200D756E654D0D0D00772D0500203A6E6769736544",
                    INIT_2A => X"747942204B31206C6C61282064616552202D2052200D756E656D207369687420",
                    INIT_2B => X"C70D770001C70000A0000D296574794228206574697257202D2057200D297365",
                    INIT_2C => X"003A079E0A00C79B0F40C79B0E0E0E0E40C720C7C773C761C7507EC76BC74F7E",
                    INIT_2D => X"BA01000000060400A6A0C7B3CC00000A00F60007B01100E900B900DF007B0061",
                    INIT_2E => X"10CC9C01D90800070008D89001CD0001D30800A70001C7040000013100B30150",
                    INIT_2F => X"43C72443C72343C72243C72143C72043C71F43C71E43C74843C74AC73243D901",
                    INIT_30 => X"3F00A000001F060F4AC703C702C701C700C737484AC706C705C704C74C48C725",
                    INIT_31 => X"484AC744484AC774484AC754484AC7704871795E397C776F7F077D6D664F5B06",
                    INIT_32 => X"02010058000001005880969858400D0358102700C79CC79000C75BC71B4AC764",
                    INIT_33 => X"A393007A01990870000E7F9675937410800096A48DA3930089A493A38D960008",
                    INIT_34 => X"000202A68DA3960008020008FD008F0102080100A308FE0001997F960089A48D",
                    INIT_35 => X"866F0774625E006900866FD000866F0674625E00AA011800A9A9A9A9A90089A6",
                    INIT_36 => X"6F068054625E00FF506900866FD000866F7000866F068054625E006984507900",
                    INIT_37 => X"866FD000866FB000866F065D625E006984507900866F0780546200866F700086",
                    INIT_38 => X"00866F0668625E006984507900866F075D6200866FB000866F065D625E006900",
                    INIT_39 => X"006984507900866F07686200866FB000866F0668625E006900866FD000866FB0",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"C74C0F00018D8F7EA00300000103000000000000000000000000000000000000",
                    INIT_40 => X"420077F9010104005C0060420077EF010104003000FD37042C03210216010B00",
                    INIT_41 => X"00771702010400E000604200770D02010400B400604200770302010400880060",
                    INIT_42 => X"0033E000008FD08D8FB07E01D0B04200010001522A00331900FF106010806042",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000060",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFF5BABD6D4FFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFEB4AB754175EFEAEBDFF363FFF8EBABBFFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFDEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDD7FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"6DB6DB7BF93D9604A8F95D557BFFFFFFF5FFFFFFFFFFFFFFFFFFEBFFFFFFFFFF",
                   INITP_06 => X"22304384700447043011800080D866800A418001C4222F7B33330000327FE7FB",
                   INITP_07 => X"C7000000000000000000000000000000000000000000000010C2301118218460",
                   INITP_08 => X"000000000000000000000000000000000000000065AD4F7C528A514A29452C00",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"0808080808080808080808080808080808080808080808080808080800000010",
                    INIT_01 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_02 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_03 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_04 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_05 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_06 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_07 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_08 => X"020D0D02B0EE03D0030E020D0D020D0D585F0303080808080808080808080808",
                    INIT_09 => X"0A0A0A0A0A0A0A0A10020D0D02030310D003B0EE03D0030E020D0D02D0030B0C",
                    INIT_0A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_0F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_10 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_11 => X"02B16C0C0202D0030E1102020A91EA91EA91EA0202910202020A02020202020A",
                    INIT_12 => X"0202020202020202B1FCEB020C0B02B1EC8C02021A02020A0202020202020202",
                    INIT_13 => X"02D0030202020202020202020202029C8BB16B9C8B020202D003020202020202",
                    INIT_14 => X"280304B16DD1020F020D0D02110202D0030101D0030E11CC91ECB16B9C8B0202",
                    INIT_15 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D02",
                    INIT_16 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_17 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_18 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_19 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A11020D0D022806D1020F020D0D020A",
                    INIT_1A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1C => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1D => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A280202A2020D0D0A0A0A",
                    INIT_1E => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_1F => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_20 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_21 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_22 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_23 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_24 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_25 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_26 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_27 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_28 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_29 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28020D0D0A0A0A0A0A0A0A0A0A",
                    INIT_2A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2B => X"120A129D8D0288EA250A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_2C => X"288A8AD2CA2802021A020202A2A2A2A202120A12020A020A020A12020A020A02",
                    INIT_2D => X"B2C8A6A6A5A508C802020292020D288A28CAC88AF2CAC8CAC88A281AE8EAC8EA",
                    INIT_2E => X"7292EA4A92684808286892EA4A1288C8B2684808286AB2684828585828B2CF25",
                    INIT_2F => X"03120A03120A03120A03120A03120A03120A03120A03120A03120A020A031288",
                    INIT_30 => X"0828259D850D0D1813025A025A025A025A020A0313025A025A025A020A03120A",
                    INIT_31 => X"0313020A0313020A0313020A0313020A03080808080808080808080808080808",
                    INIT_32 => X"2F0F28B3D9D8C800130808091308080913080809120A120A28020A020A13020A",
                    INIT_33 => X"030328B3C8030813C8A003031303B3620828030303030328030303030303286F",
                    INIT_34 => X"A2684803030303286F2F286F1F289368486F2F28036F1F286A03130328030303",
                    INIT_35 => X"0303A20A03032803C8030302C80303A20A030328B3C808280303030303280303",
                    INIT_36 => X"03A2220A030328180303C8030302C8030302C80303A2220A03032803030603C8",
                    INIT_37 => X"030302C8030302C80303A20A03032803030603C80303A2220A03C8030302C803",
                    INIT_38 => X"C80303A20A03032803030603C80303A20A03C8030302C80303A20A03032803C8",
                    INIT_39 => X"2803030603C80303A20A03C8030302C80303A20A03032803C8030302C8030302",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"020A1D2840020202024D4028406D404800000000000000000000000000000000",
                    INIT_40 => X"04B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0CB394ED94ED94ED94ED94ED",
                    INIT_41 => X"B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0C1404B8020D0DB80B0B0C0C14",
                    INIT_42 => X"28B0E628B8020202020202B8B6B5149B8B9C8C04030ED00388ED052306241404",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000014",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1",
                   INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFEE9C9BA4FFFF",
                   INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFF9969FFAA37EDE46FDBF9332FFCF755FBFFFFFFFFF",
                   INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFA7FFFFFFFFFFFFFFFFFFFFFFFFFFFFE6D3FFFFFFFF",
                   INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
                   INITP_05 => X"DB6DB6D6C8A68E7C81FAAAAA97305AB5A6FFFFFFFFFFFFFFFFFFF9FFFFFFFFFF",
                   INITP_06 => X"DDCFBC7B8EFBB8FBCFEE79FF1FB65D7FF5BE7FFF30888AD6EEEEFFFFE0D55D56",
                   INITP_07 => X"9F3F00000000000000000000000000000000000000000000EF3DCFEEE7DE7B9F",
                   INITP_08 => X"0000000000000000000000000000000000000001DDB21B97C8790F21E43C86AA",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_4k_generate;	              
  --
  --
  --
  --
  -- JTAG Loader
  --
  instantiate_loader : if (C_JTAG_LOADER_ENABLE = 1) generate
  --
    jtag_loader_6_inst : jtag_loader_6
    generic map(              C_FAMILY => C_FAMILY,
                       C_NUM_PICOBLAZE => 1,
                  C_JTAG_LOADER_ENABLE => C_JTAG_LOADER_ENABLE,
                 C_BRAM_MAX_ADDR_WIDTH => BRAM_ADDRESS_WIDTH,
	                  C_ADDR_WIDTH_0 => BRAM_ADDRESS_WIDTH)
    port map( picoblaze_reset => rdl_bus,
                      jtag_en => jtag_en,
                     jtag_din => jtag_din,
                    jtag_addr => jtag_addr(BRAM_ADDRESS_WIDTH-1 downto 0),
                     jtag_clk => jtag_clk,
                      jtag_we => jtag_we,
                  jtag_dout_0 => jtag_dout,
                  jtag_dout_1 => jtag_dout, -- ports 1-7 are not used
                  jtag_dout_2 => jtag_dout, -- in a 1 device debug 
                  jtag_dout_3 => jtag_dout, -- session.  However, Synplify
                  jtag_dout_4 => jtag_dout, -- etc require all ports to
                  jtag_dout_5 => jtag_dout, -- be connected
                  jtag_dout_6 => jtag_dout,
                  jtag_dout_7 => jtag_dout);
    --  
  end generate instantiate_loader;
  --
end low_level_definition;
--
--
-------------------------------------------------------------------------------------------
--
-- JTAG Loader 
--
-------------------------------------------------------------------------------------------
--
--
-- JTAG Loader 6 - Version 6.00
-- Kris Chaplin 4 February 2010
-- Ken Chapman 15 August 2011 - Revised coding style
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
library unisim;
use unisim.vcomponents.all;
--
entity jtag_loader_6 is
generic(              C_JTAG_LOADER_ENABLE : integer := 1;
                                  C_FAMILY : string := "V6";
                           C_NUM_PICOBLAZE : integer := 1;
                     C_BRAM_MAX_ADDR_WIDTH : integer := 10;
        C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                              C_JTAG_CHAIN : integer := 2;
                            C_ADDR_WIDTH_0 : integer := 10;
                            C_ADDR_WIDTH_1 : integer := 10;
                            C_ADDR_WIDTH_2 : integer := 10;
                            C_ADDR_WIDTH_3 : integer := 10;
                            C_ADDR_WIDTH_4 : integer := 10;
                            C_ADDR_WIDTH_5 : integer := 10;
                            C_ADDR_WIDTH_6 : integer := 10;
                            C_ADDR_WIDTH_7 : integer := 10);
port(   picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
               jtag_din : out std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
              jtag_addr : out std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0) := (others => '0');
               jtag_clk : out std_logic := '0';
                jtag_we : out std_logic := '0';
            jtag_dout_0 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_1 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_2 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_3 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_4 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_5 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_6 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_7 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end jtag_loader_6;
--
architecture Behavioral of jtag_loader_6 is
  --
  signal num_picoblaze       : std_logic_vector(2 downto 0);
  signal picoblaze_instruction_data_width : std_logic_vector(4 downto 0);
  --
  signal drck                : std_logic;
  signal shift_clk           : std_logic;
  signal shift_din           : std_logic;
  signal shift_dout          : std_logic;
  signal shift               : std_logic;
  signal capture             : std_logic;
  --
  signal control_reg_ce      : std_logic;
  signal bram_ce             : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal bus_zero            : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  signal jtag_en_int         : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal jtag_en_expanded    : std_logic_vector(7 downto 0) := (others => '0');
  signal jtag_addr_int       : std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
  signal jtag_din_int        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal control_din         : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout_int    : std_logic_vector(7 downto 0):= (others => '0');
  signal bram_dout_int       : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
  signal jtag_we_int         : std_logic;
  signal jtag_clk_int        : std_logic;
  signal bram_ce_valid       : std_logic;
  signal din_load            : std_logic;
  --
  signal jtag_dout_0_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_1_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_2_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_3_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_4_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_5_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_6_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_7_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal picoblaze_reset_int : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  --        
begin
  bus_zero <= (others => '0');
  --
  jtag_loader_gen: if (C_JTAG_LOADER_ENABLE = 1) generate
    --
    -- Insert BSCAN primitive for target device architecture.
    --
    BSCAN_SPARTAN6_gen: if (C_FAMILY="S6") generate
    begin
      BSCAN_BLOCK_inst : BSCAN_SPARTAN6
      generic map ( JTAG_CHAIN => C_JTAG_CHAIN)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_SPARTAN6_gen;   
    --
    BSCAN_VIRTEX6_gen: if (C_FAMILY="V6") generate
    begin
      BSCAN_BLOCK_inst: BSCAN_VIRTEX6
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => FALSE)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_VIRTEX6_gen;   
    --
    BSCAN_7SERIES_gen: if (C_FAMILY="7S") generate
    begin
      BSCAN_BLOCK_inst: BSCANE2
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => "FALSE")
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_7SERIES_gen;   
    --
    --
    -- Insert clock buffer to ensure reliable shift operations.
    --
    upload_clock: BUFG
    port map( I => drck,
              O => shift_clk);
    --        
    --        
    --  Shift Register      
    --        
    --
    control_reg_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk = '1' then
        if (shift = '1') then
          control_reg_ce <= shift_din;
        end if;
      end if;
    end process control_reg_ce_shift;
    --        
    bram_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          if(C_NUM_PICOBLAZE > 1) then
            for i in 0 to C_NUM_PICOBLAZE-2 loop
              bram_ce(i+1) <= bram_ce(i);
            end loop;
          end if;
          bram_ce(0) <= control_reg_ce;
        end if;
      end if;
    end process bram_ce_shift;
    --        
    bram_we_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          jtag_we_int <= bram_ce(C_NUM_PICOBLAZE-1);
        end if;
      end if;
    end process bram_we_shift;
    --        
    bram_a_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          for i in 0 to C_BRAM_MAX_ADDR_WIDTH-2 loop
            jtag_addr_int(i+1) <= jtag_addr_int(i);
          end loop;
          jtag_addr_int(0) <= jtag_we_int;
        end if;
      end if;
    end process bram_a_shift;
    --        
    bram_d_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (din_load = '1') then
          jtag_din_int <= bram_dout_int;
         elsif (shift = '1') then
          for i in 0 to C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2 loop
            jtag_din_int(i+1) <= jtag_din_int(i);
          end loop;
          jtag_din_int(0) <= jtag_addr_int(C_BRAM_MAX_ADDR_WIDTH-1);
        end if;
      end if;
    end process bram_d_shift;
    --
    shift_dout <= jtag_din_int(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1);
    --
    --
    din_load_select:process (bram_ce, din_load, capture, bus_zero, control_reg_ce) 
    begin
      if ( bram_ce = bus_zero ) then
        din_load <= capture and control_reg_ce;
       else
        din_load <= capture;
      end if;
    end process din_load_select;
    --
    --
    -- Control Registers 
    --
    num_picoblaze <= conv_std_logic_vector(C_NUM_PICOBLAZE-1,3);
    picoblaze_instruction_data_width <= conv_std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1,5);
    --	
    control_registers: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '0') and (control_reg_ce = '1') then
          case (jtag_addr_int(3 downto 0)) is 
            when "0000" => -- 0 = version - returns (7 downto 4) illustrating number of PB
                           --               and (3 downto 0) picoblaze instruction data width
                           control_dout_int <= num_picoblaze & picoblaze_instruction_data_width;
            when "0001" => -- 1 = PicoBlaze 0 reset / status
                           if (C_NUM_PICOBLAZE >= 1) then 
                            control_dout_int <= picoblaze_reset_int(0) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_0-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0010" => -- 2 = PicoBlaze 1 reset / status
                           if (C_NUM_PICOBLAZE >= 2) then 
                             control_dout_int <= picoblaze_reset_int(1) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_1-1,5) );
                            else 
                             control_dout_int <= (others => '0');
                           end if;
            when "0011" => -- 3 = PicoBlaze 2 reset / status
                           if (C_NUM_PICOBLAZE >= 3) then 
                            control_dout_int <= picoblaze_reset_int(2) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_2-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0100" => -- 4 = PicoBlaze 3 reset / status
                           if (C_NUM_PICOBLAZE >= 4) then 
                            control_dout_int <= picoblaze_reset_int(3) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_3-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0101" => -- 5 = PicoBlaze 4 reset / status
                           if (C_NUM_PICOBLAZE >= 5) then 
                            control_dout_int <= picoblaze_reset_int(4) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_4-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0110" => -- 6 = PicoBlaze 5 reset / status
                           if (C_NUM_PICOBLAZE >= 6) then 
                            control_dout_int <= picoblaze_reset_int(5) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_5-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0111" => -- 7 = PicoBlaze 6 reset / status
                           if (C_NUM_PICOBLAZE >= 7) then 
                            control_dout_int <= picoblaze_reset_int(6) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_6-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1000" => -- 8 = PicoBlaze 7 reset / status
                           if (C_NUM_PICOBLAZE >= 8) then 
                            control_dout_int <= picoblaze_reset_int(7) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_7-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1111" => control_dout_int <= conv_std_logic_vector(C_BRAM_MAX_ADDR_WIDTH -1,8);
            when others => control_dout_int <= (others => '1');
          end case;
        else 
          control_dout_int <= (others => '0');
        end if;
      end if;
    end process control_registers;
    -- 
    control_dout(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8) <= control_dout_int;
    --
    pb_reset: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '1') and (control_reg_ce = '1') then
          picoblaze_reset_int(C_NUM_PICOBLAZE-1 downto 0) <= control_din(C_NUM_PICOBLAZE-1 downto 0);
        end if;
      end if;
    end process pb_reset;    
    --
    --
    -- Assignments 
    --
    control_dout (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9 downto 0) <= (others => '0') when (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8);
    --
    -- Qualify the blockram CS signal with bscan select output
    jtag_en_int <= bram_ce when bram_ce_valid = '1' else (others => '0');
    --      
    jtag_en_expanded(C_NUM_PICOBLAZE-1 downto 0) <= jtag_en_int;
    jtag_en_expanded(7 downto C_NUM_PICOBLAZE) <= (others => '0') when (C_NUM_PICOBLAZE < 8);
    --        
    bram_dout_int <= control_dout or jtag_dout_0_masked or jtag_dout_1_masked or jtag_dout_2_masked or jtag_dout_3_masked or jtag_dout_4_masked or jtag_dout_5_masked or jtag_dout_6_masked or jtag_dout_7_masked;
    --
    control_din <= jtag_din_int;
    --        
    jtag_dout_0_masked <= jtag_dout_0 when jtag_en_expanded(0) = '1' else (others => '0');
    jtag_dout_1_masked <= jtag_dout_1 when jtag_en_expanded(1) = '1' else (others => '0');
    jtag_dout_2_masked <= jtag_dout_2 when jtag_en_expanded(2) = '1' else (others => '0');
    jtag_dout_3_masked <= jtag_dout_3 when jtag_en_expanded(3) = '1' else (others => '0');
    jtag_dout_4_masked <= jtag_dout_4 when jtag_en_expanded(4) = '1' else (others => '0');
    jtag_dout_5_masked <= jtag_dout_5 when jtag_en_expanded(5) = '1' else (others => '0');
    jtag_dout_6_masked <= jtag_dout_6 when jtag_en_expanded(6) = '1' else (others => '0');
    jtag_dout_7_masked <= jtag_dout_7 when jtag_en_expanded(7) = '1' else (others => '0');
    --
    jtag_en <= jtag_en_int;
    jtag_din <= jtag_din_int;
    jtag_addr <= jtag_addr_int;
    jtag_clk <= jtag_clk_int;
    jtag_we <= jtag_we_int;
    picoblaze_reset <= picoblaze_reset_int;
    --        
  end generate jtag_loader_gen;
--
end Behavioral;
--
--
------------------------------------------------------------------------------------
--
-- END OF FILE chipscope_to_Si5324_bridge.vhd
--
------------------------------------------------------------------------------------
