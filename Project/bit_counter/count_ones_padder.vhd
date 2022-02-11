library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_padder is
  Port (din  : in  std_logic_vector (31 downto 0);
        dout : out std_logic_vector (5 downto 0));
end count_ones_padder;

architecture Behavioral of count_ones_padder is

  type L0_array is array(0 to 15) of std_logic_vector(1 downto 0);
  signal L0 : L0_array;

  type L1_array is array(0 to 7) of std_logic_vector(2 downto 0);
  signal L1 : L1_array;

  type L2_array is array(0 to 3) of std_logic_vector(3 downto 0);
  signal L2 : L2_array;

  type L3_array is array(0 to 1) of std_logic_vector(4 downto 0);
  signal L3 : L3_array;

begin

  g0: for i in 0 to 15 generate
    L0(i) <= ('0' & din(i*2)) + ('0' & din(i*2+1));
  end generate;

  g1: for i in 0 to 7 generate
    L1(i) <= ('0' & L0(i*2)) + ('0' & L0(i*2+1));
  end generate;

  g2: for i in 0 to 3 generate
    L2(i) <= ('0' & L1(i*2)) + ('0' & L1(i*2+1));
  end generate;

  g3: for i in 0 to 1 generate
    L3(i) <= ('0' & L2(i*2)) + ('0' & L2(i*2+1));
  end generate;

  dout <= ('0' & L3(0)) + ('0' & L3(1));
  
end Behavioral;
