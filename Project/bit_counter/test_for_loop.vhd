--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:26:04 10/25/2008
-- Design Name:   
-- Module Name:   /home/graphix/classes/counter/sum16_test.vhd
-- Project Name:  test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sum16
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY sum16_test IS
END sum16_test;
 
 signal clk;
 
ARCHITECTURE behavior OF sum16_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sum16
    PORT(
         a : IN  std_logic_vector(1 to 16);
         sum : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(1 to 16) := (others => '0');

 	--Outputs
   signal sum : std_logic_vector(4 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sum16 PORT MAP (
          a => a,
          sum => sum
        );
 
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
   constant clk_period := 1ns;
 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;

