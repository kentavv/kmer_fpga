library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_multi_adders is
  Port (din0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  din9 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  dout0 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout1 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout2 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout3 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout4 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout5 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout6 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout7 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout8 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout9 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));
end test_multi_adders;

architecture Behavioral of test_multi_adders is

  component count_ones is
    Port (din   : in  std_logic_vector (31 downto 0);
          dout  : out std_logic_vector (5 downto 0));
  end component count_ones;

begin

    co0 : count_ones
    port map (
      din       => din0,           -- input
      dout      => dout0           -- output 
      );
    co1 : count_ones
    port map (
      din       => din1,           -- input
      dout      => dout1           -- output 
      );
    co2 : count_ones
    port map (
      din       => din2,           -- input
      dout      => dout2           -- output 
      );
    co3 : count_ones
    port map (
      din       => din3,           -- input
      dout      => dout3           -- output 
      );
    co4 : count_ones
    port map (
      din       => din4,           -- input
      dout      => dout4           -- output 
      );
    co5 : count_ones
    port map (
      din       => din5,           -- input
      dout      => dout5           -- output 
      );
    co6 : count_ones
    port map (
      din       => din6,           -- input
      dout      => dout6           -- output 
      );
    co7 : count_ones
    port map (
      din       => din7,           -- input
      dout      => dout7           -- output 
      );
    co8 : count_ones
    port map (
      din       => din8,           -- input
      dout      => dout8           -- output 
      );
    co9 : count_ones
    port map (
      din       => din9,           -- input
      dout      => dout9           -- output 
      );
  
end Behavioral;
