library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bi_or_16 is
  Port (din  : in   std_logic_vector (15 downto 0);
        dout : out  std_logic_vector ( 1 downto 0));
end bi_or_16;

architecture Behavioral of bi_or_16 is

  component bi_or_8 is
    port (din      : in  std_logic_vector(7 downto 0);
          dout     : in  std_logic_vector(1 downto 0));
  end component bi_or_8;

  signal bo8_1 : std_logic_vector(1 downto 0);
  signal bo8_0 : std_logic_vector(1 downto 0);
  
begin

  bi_or_8_1 : bi_or_8
    port map (
      din  => din(15 downto 8), -- input
      dout => bo8_1             -- output
      );

  bi_or_8_0 : bi_or_8
    port map (
      din  => din(7 downto 0), -- input
      dout => bo8_0            -- output
      );
      
  dout(1) <= bo8_1(1) or bo8_1(0);
  dout(0) <= bo8_0(1) or bo8_0(0);

end Behavioral;
