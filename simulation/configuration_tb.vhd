------------------------------------------------------------------------
-- Title      : Demo testbench
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : configuration_tb.vhd
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
-- Description: Management
--
--              This testbench will control the speed settings of the
--              EMAC block (if required) by driving the Tie-off vector.
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity configuration_tb is
    port(
      reset                       : out std_logic;
      ------------------------------------------------------------------
      -- Host Interface: host_clk is always required
      ------------------------------------------------------------------
      host_clk                    : out std_logic;

      ------------------------------------------------------------------
      -- Test Bench Semaphores
      ------------------------------------------------------------------

      emac0_configuration_busy    : out boolean;
      emac0_monitor_finished_1g   : in  boolean;
      emac0_monitor_finished_100m : in  boolean;
      emac0_monitor_finished_10m  : in  boolean;

      emac1_configuration_busy    : out boolean;
      emac1_monitor_finished_1g   : in  boolean;
      emac1_monitor_finished_100m : in  boolean;
      emac1_monitor_finished_10m  : in  boolean

      );
end configuration_tb;


architecture behavioral of configuration_tb is


  signal hostclk : std_logic;


begin


    --------------------------------------------------------------------
    -- HOSTCLK driver
    --------------------------------------------------------------------

     -- Drive HOSTCLK at one third the frequency of GTX_CLK
     p_hostclk : process
     begin
         hostclk <= '0';
         wait for 2 ns;
         loop
             wait for 12 ns;
             hostclk <= '1';
             wait for 12 ns;
             hostclk <= '0';
         end loop;
     end process P_hostclk;

     host_clk <= hostclk;


    --------------------------------------------------------------------
    -- Testbench Configuration
    --------------------------------------------------------------------
    tb_configuration : process
    begin

      reset <= '0';

      -- test bench semaphores
      emac0_configuration_busy <= false;
      emac1_configuration_busy <= false;

      wait for 200 ns;
      emac0_configuration_busy <= true;
      emac1_configuration_busy <= true;

      -- Reset the core
      assert false
      report "Resetting the design..." & cr
      severity note;

      reset <= '0';
      wait for  4000 ns;
      reset <= '1';
      wait for 200 ns;

      assert false
      report "Timing checks are valid" & cr
      severity note;



      wait for 15 us;


      wait for 100 ns;
      emac0_configuration_busy <= false;


      -- wait for EMAC0 1Gb/s frames to complete
      while (not emac0_monitor_finished_1g) loop
         wait for 8 ns;
      end loop;		   


      wait for 100 ns;

      -- Our work here is done
        assert false
      report "Simulation stopped"
      severity failure;

    end process tb_configuration;



    --------------------------------------------------------------------
    -- If the simulation is still going after 2 ms 
    -- then something has gone wrong
    --------------------------------------------------------------------
    p_timebomb : process
    begin
      wait for 2 ms;
    	assert false
    	report "** ERROR - Simulation running forever!"
    	severity failure;
    end process p_timebomb;



end behavioral;

