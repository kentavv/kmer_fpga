library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_clogic_8 is
  Port (din  : in  std_logic_vector (7 downto 0);
        dout : out std_logic_vector (3 downto 0));
end count_ones_clogic_8;

architecture Behavioral of count_ones_clogic_8 is

  component count_ones_clogic_4 is
      Port (din  : in  std_logic_vector (3 downto 0);
            dout : out std_logic_vector (2 downto 0));
  end component count_ones_clogic_4;

  signal A : std_logic_vector(2 downto 0);
  signal B : std_logic_vector(2 downto 0);
  
begin

  coc4a  : count_ones_clogic_4
    port map (
      din       => din(7 downto 4), -- input
      dout      => A                -- output 
      );

  coc4b  : count_ones_clogic_4
    port map (
      din       => din(3 downto 0), -- input
      dout      => B                -- output 
      );

  dout(3) <= (A(2) and B(2));

  dout(2) <= (A(0) and B(1) and B(0)) or
             (A(1) and A(0) and B(0)) or
             (A(2) and not B(2)) or
             (not A(2) and B(2)) or
             (A(1) and B(1));

  dout(1) <= (not A(1) and A(0) and not B(1) and B(0)) or
             (A(1) and A(0) and B(1) and B(0)) or
             (A(1) and not B(1) and not B(0)) or
             (not A(1) and B(1) and not B(0)) or
             (A(1) and not A(0) and not B(1)) or
             (not A(1) and not A(0) and B(1));

  dout(0) <= (A(0) and not B(0)) or
             (not A(0) and B(0));

end Behavioral;
