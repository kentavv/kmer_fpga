library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bi_or_4 is
  Port (din  : in   std_logic_vector (3 downto 0);
        dout : out  std_logic_vector (1 downto 0));
end bi_or_4;

architecture Behavioral of bi_or_4 is

begin

  dout(1) <= din(3) or din(2);
  dout(0) <= din(1) or din(0);

end Behavioral;
