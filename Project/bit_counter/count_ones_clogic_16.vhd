library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_clogic_16 is
  Port (din  : in  std_logic_vector (15 downto 0);
        dout : out std_logic_vector ( 4 downto 0));
end count_ones_clogic_16;

architecture Behavioral of count_ones_clogic_16 is

  component count_ones_clogic_8 is
      Port (din  : in  std_logic_vector (7 downto 0);
            dout : out std_logic_vector (3 downto 0));
  end component count_ones_clogic_8;

  signal A : std_logic_vector(3 downto 0);
  signal B : std_logic_vector(3 downto 0);
  
begin

  coc8a  : count_ones_clogic_8
    port map (
      din       => din(15 downto 8), -- input
      dout      => A                 -- output 
      );

  coc8b  : count_ones_clogic_8
    port map (
      din       => din(7 downto 0),  -- input
      dout      => B                 -- output 
      );

  dout(4) <= (A(3) and B(3));

  dout(3) <= (A(0) and B(2) and B(1) and B(0)) or
             (A(2) and A(0) and B(1) and B(0)) or
             (A(1) and A(0) and B(2) and B(0)) or
             (A(2) and A(1) and A(0) and B(0)) or
             (A(3) and not B(3)) or
             (not A(3) and B(3)) or
             (A(1) and B(2) and B(1)) or
             (A(2) and A(1) and B(1)) or
             (A(2) and B(2));

  dout(2) <= (A(2) and not A(0) and not B(2) and not B(1)) or
             (not A(2) and not A(0) and B(2) and not B(1)) or
             (A(2) and not A(1) and not A(0) and not B(2)) or
             (not A(2) and not A(1) and not A(0) and B(2)) or
             (A(2) and not B(2) and not B(1) and not B(0)) or
             (not A(2) and B(2) and not B(1) and not B(0)) or
             (A(2) and not A(1) and not B(2) and not B(0)) or
             (not A(2) and not A(1) and B(2) and not B(0)) or
             (not A(2) and A(0) and not B(2) and B(1) and B(0)) or
             (not A(2) and A(1) and A(0) and not B(2) and B(0)) or
             (A(2) and A(0) and B(2) and B(1) and B(0)) or
             (A(2) and A(1) and A(0) and B(2) and B(0)) or
             (A(2) and not A(1) and not B(2) and not B(1)) or
             (not A(2) and not A(1) and B(2) and not B(1)) or
             (not A(2) and A(1) and not B(2) and B(1)) or
             (A(2) and A(1) and B(2) and B(1));
  
  dout(1) <= (not A(1) and A(0) and not B(1) and B(0)) or
             (A(1) and A(0) and B(1) and B(0)) or
             (A(1) and not B(1) and not B(0)) or
             (not A(1) and B(1) and not B(0)) or
             (A(1) and not A(0) and not B(1)) or
             (not A(1) and not A(0) and B(1));

  dout(0) <= (A(0) and not B(0)) or
             (not A(0) and B(0));

end Behavioral;
