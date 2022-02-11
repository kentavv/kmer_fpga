library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bi_or_8 is
  Port (din  : in   std_logic_vector (7 downto 0);
        dout : out  std_logic_vector (1 downto 0));
end bi_or_8;

architecture Behavioral of bi_or_8 is

  component bi_or_4 is
    port (din      : in  std_logic_vector(3 downto 0);
          dout     : in  std_logic_vector(1 downto 0));
  end component bi_or_4;

  signal bo4_1 : std_logic_vector(1 downto 0);
  signal bo4_0 : std_logic_vector(1 downto 0);
  
begin

  bi_or_4_1 : bi_or_4
    port map (
      din  => din(7 downto 4), -- input
      dout => bo4_1             -- output
      );

  bi_or_4_0 : bi_or_4
    port map (
      din  => din(3 downto 0), -- input
      dout => bo4_0            -- output
      );
      
  dout(1) <= bo4_1(1) or bo4_1(0);
  dout(0) <= bo4_0(1) or bo4_0(0);

end Behavioral;
