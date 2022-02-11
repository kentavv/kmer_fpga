library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity compare6 is
  Port (din1  : in  std_logic_vector (5 DOWNTO 0);
        din2  : in  std_logic_vector (5 DOWNTO 0);
        dout  : out std_logic);
end compare6;

architecture Behavioral of compare6 is

begin

  process(din1, din2)
  begin
    if(din1 <= din2) then
      dout <= '1';
    else
      dout <= '0';
    end if;
  end process;

end Behavioral;
