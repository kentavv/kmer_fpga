library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reverse is
  Port (din  : in   std_logic_vector (63 downto 0);
        dout : out  std_logic_vector (63 downto 0));
end reverse;

architecture Behavioral of reverse is

begin

  g1: for i in 0 to 63 generate
    dout(63-i) <= din(i);
  end generate;

end Behavioral;
