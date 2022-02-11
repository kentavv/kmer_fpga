library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mash is
  Port (din  : in  std_logic_vector (63 DOWNTO 0);
        dout : out std_logic_vector (31 downto 0));
end mash;

architecture Behavioral of mash is

  signal even_bits  : std_logic_vector(31 downto 0);
  signal odd_bits   : std_logic_vector(31 downto 0);

begin

  g1: for i in 0 to 31 generate
    even_bits(i) <= din(i*2);
    odd_bits(i)  <= din(i*2+1);
  end generate;

  dout <= even_bits or odd_bits;

end Behavioral;
