library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_clogic is
  Port (din  : in  std_logic_vector (31 DOWNTO 0);
        dout : out std_logic_vector (5 downto 0));
end count_ones_clogic;

architecture Behavioral of count_ones_clogic is

  component count_ones_clogic_32 is
      Port (din  : in  std_logic_vector (31 DOWNTO 0);
            dout : out std_logic_vector (5 downto 0));
  end component count_ones_clogic_32;

begin

  coc32  : count_ones_clogic_32
    port map (
      din       => din,            -- input
      dout      => dout           -- output 
      );

end Behavioral;
