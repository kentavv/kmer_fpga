library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_multi_adders is
end test_multi_adders;

architecture Behavioral of test_multi_adders is

  type Array_32bit is array(0 to 9) of std_logic_vector(31 downto 0);
  signal din : Array_32bit;

  type Array_6bit is array(0 to 9) of std_logic_vector(5 downto 0);
  signal dout : Array_6bit;

  component count_ones is
    Port (din   : in  std_logic_vector (31 downto 0);
          dout  : out std_logic_vector (5 downto 0));
  end component count_ones;

begin

  g0: for i in 0 to 9 generate
    coi : count_ones
    port map (
      din       => din(i),           -- input
      dout      => dout(i)           -- output 
      );
  end generate;
  
end Behavioral;
