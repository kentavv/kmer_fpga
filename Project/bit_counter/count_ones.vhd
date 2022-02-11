library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones is
  Port (din  : in  std_logic_vector (31 downto 0);
        dout : out std_logic_vector ( 5 downto 0));
end count_ones;

architecture Behavioral of count_ones is

  component count_ones_cadder is
      Port (din  : in  std_logic_vector (31 downto 0);
            dout : out std_logic_vector ( 5 downto 0));
  end component count_ones_cadder;

  component count_ones_clogic_32 is
      Port (din  : in  std_logic_vector (31 downto 0);
            dout : out std_logic_vector ( 5 downto 0));
  end component count_ones_clogic_32;

  component count_ones_padder is
      Port (din  : in  std_logic_vector (31 downto 0);
            dout : out std_logic_vector ( 5 downto 0));
  end component count_ones_padder;

  component count_ones_table is
      Port (din  : in  std_logic_vector (31 downto 0);
            dout : out std_logic_vector ( 5 downto 0));
  end component count_ones_table;

begin
 
--  cof1  : count_ones_cadder
--    port map (
--      din       => din,           -- input
--      dout      => dout           -- output 
--      );

--  cof1  : count_ones_clogic_32
--   port map (
--      din       => din,           -- input
--      dout      => dout           -- output 
--      );

  cof1  : count_ones_padder
   port map (
      din       => din,           -- input
      dout      => dout           -- output 
      );

--  cof1  : count_ones_table
--   port map (
--      din       => din,           -- input
--      dout      => dout           -- output 
--      );

end Behavioral;
