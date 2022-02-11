library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_table_2 is
  Port (din  : in  std_logic_vector (1 downto 0);
        dout : out std_logic_vector (1 downto 0));
end count_ones_table_2;

architecture Behavioral of count_ones_table_2 is

begin

  with din select
    dout <= "00" when "00",
            "01" when "01",
            "01" when "10",
            "10" when "11",
            unaffected when others;

end Behavioral;
