library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_clogic_2 is
  Port (din  : in  std_logic_vector (1 downto 0);
        dout : out std_logic_vector (1 downto 0));
end count_ones_clogic_2;

architecture Behavioral of count_ones_clogic_2 is

begin

  dout(1) <= (din(1) and din(0));

  dout(0) <= (din(1) and not din(0)) or
             (not din(1) and din(0));

end Behavioral;
