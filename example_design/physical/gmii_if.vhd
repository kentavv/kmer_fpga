------------------------------------------------------------------------
-- Title      : Gigabit Media Independent Interface (GMII) Physical I/F
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : gmii_if.vhd
------------------------------------------------------------------------
-- Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you 
-- a license to use this text/file solely for design, simulation, 
-- implementation and creation of design files limited 
-- to Xilinx devices or technologies. Use with non-Xilinx 
-- devices or technologies is expressly prohibited and 
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information 
-- "as is" solely for use in developing programs and 
-- solutions for Xilinx devices. By providing this design, 
-- code, or information as one possible implementation of 
-- this feature, application or standard, Xilinx is making no 
-- representation that this implementation is free from any 
-- claims of infringement. You are responsible for 
-- obtaining any rights you may require for your implementation. 
-- Xilinx expressly disclaims any warranty whatsoever with 
-- respect to the adequacy of the implementation, including 
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied 
-- warranties of merchantability or fitness for a particular 
-- purpose. 
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications are
-- expressly prohibited.
-- 
-- This copyright and support notice must be retained as part 
-- of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
-- All rights reserved.

------------------------------------------------------------------------
-- Description:  This module creates a Gigabit Media Independent 
--               Interface (GMII) by instantiating Input/Output buffers  
--               and Input/Output flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external 1000Mb/s (or Tri-speed) Ethernet PHY.
------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------
-- The entity declaration for the PHY IF design.
------------------------------------------------------------------------------
entity gmii_if is
    port(
        RESET                         : in  std_logic;
        -- GMII Interface
        GMII_TXD                      : out std_logic_vector(7 downto 0);
        GMII_TX_EN                    : out std_logic;
        GMII_TX_ER                    : out std_logic;
        GMII_TX_CLK                   : out std_logic;
        GMII_RXD                      : in  std_logic_vector(7 downto 0);
        GMII_RX_DV                    : in  std_logic;
        GMII_RX_ER                    : in  std_logic;
        -- MAC Interface
        TXD_FROM_MAC                  : in  std_logic_vector(7 downto 0);
        TX_EN_FROM_MAC                : in  std_logic;
        TX_ER_FROM_MAC                : in  std_logic;
        TX_CLK                        : in  std_logic;
        RXD_TO_MAC                    : out std_logic_vector(7 downto 0);
        RX_DV_TO_MAC                  : out std_logic;
        RX_ER_TO_MAC                  : out std_logic;
        RX_CLK                        : in  std_logic);
end gmii_if;

architecture PHY_IF of gmii_if is

  signal vcc_i              : std_logic;
  signal gnd_i              : std_logic;

  signal  GMII_RXD_DLY                      : std_logic_vector(7 downto 0);
  signal  GMII_RX_DV_DLY                    : std_logic;
  signal  GMII_RX_ER_DLY                    : std_logic;

begin

  vcc_i <= '1';
  gnd_i <= '0';

  --------------------------------------------------------------------------
  -- GMII Transmitter Clock Management
  --------------------------------------------------------------------------
  -- Instantiate a DDR output register.  This is a good way to drive
  -- GMII_TX_CLK since the clock-to-PAD delay will be the same as that for
  -- data driven from IOB Ouput flip-flops eg GMII_TXD[7:0].
  gmii_tx_clk_oddr : ODDR
  port map (
      Q => GMII_TX_CLK,
      C => TX_CLK,
      CE => vcc_i,
      D1 => gnd_i,
      D2 => vcc_i,
      R => RESET,
      S => gnd_i
  );

  --------------------------------------------------------------------------
  -- GMII Transmitter Logic : Drive TX signals through IOBs onto GMII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Output flip-flops.
  gmii_output_ffs : process (TX_CLK, RESET)
  begin
      if RESET = '1' then
          GMII_TX_EN <= '0';
          GMII_TX_ER <= '0';
          GMII_TXD   <= (others => '0');
      elsif TX_CLK'event and TX_CLK = '1' then
          GMII_TX_EN <= TX_EN_FROM_MAC;
          GMII_TX_ER <= TX_ER_FROM_MAC;
          GMII_TXD   <= TXD_FROM_MAC;
      end if;
  end process gmii_output_ffs;

  -- Route GMII inputs through IO delays
  ideld0 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(0), O => GMII_RXD_DLY(0), C => '0', CE => '0', INC => '0', RST => '0');

  ideld1 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(1), O => GMII_RXD_DLY(1), C => '0', CE => '0', INC => '0', RST => '0');

  ideld2 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(2), O => GMII_RXD_DLY(2), C => '0', CE => '0', INC => '0', RST => '0');

  ideld3 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(3), O => GMII_RXD_DLY(3), C => '0', CE => '0', INC => '0', RST => '0');

  ideld4 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(4), O => GMII_RXD_DLY(4), C => '0', CE => '0', INC => '0', RST => '0');

  ideld5 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(5), O => GMII_RXD_DLY(5), C => '0', CE => '0', INC => '0', RST => '0');

  ideld6 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(6), O => GMII_RXD_DLY(6), C => '0', CE => '0', INC => '0', RST => '0');

  ideld7 : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map(I => GMII_RXD(7), O => GMII_RXD_DLY(7), C => '0', CE => '0', INC => '0', RST => '0');

  ideldv : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map (I => GMII_RX_DV, O => GMII_RX_DV_DLY, C => '0', CE => '0', INC => '0', RST => '0');

  ideler : IDELAY generic map (
    IOBDELAY_TYPE   => "FIXED",
    IOBDELAY_VALUE  => 0
    )
    port map (I => GMII_RX_ER, O => GMII_RX_ER_DLY, C => '0', CE => '0', INC => '0', RST => '0');

  --------------------------------------------------------------------------
  -- GMII Receiver Logic : Receive RX signals through IOBs from GMII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Input flip-flops
  gmii_input_ffs : process (RX_CLK, RESET)
  begin
      if RESET = '1' then
          RX_DV_TO_MAC <= '0';
          RX_ER_TO_MAC <= '0';
          RXD_TO_MAC   <= (others => '0');
      elsif RX_CLK'event and RX_CLK = '1' then
          RX_DV_TO_MAC <= GMII_RX_DV_DLY;
          RX_ER_TO_MAC <= GMII_RX_ER_DLY;
          RXD_TO_MAC   <= GMII_RXD_DLY;
      end if;
  end process gmii_input_ffs;

end PHY_IF;
