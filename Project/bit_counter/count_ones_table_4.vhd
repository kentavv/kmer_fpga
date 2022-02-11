library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_table_4 is
  Port (din  : in  std_logic_vector (3 downto 0);
        dout : out std_logic_vector (2 downto 0));
end count_ones_table_4;

architecture Behavioral of count_ones_table_4 is

  component count_ones_table_2 is
      Port (din  : in  std_logic_vector (1 downto 0);
            dout : out std_logic_vector (1 downto 0));
  end component count_ones_table_2;

  signal A : std_logic_vector(1 downto 0);
  signal B : std_logic_vector(1 downto 0);
  signal C : std_logic_vector(3 downto 0);
  
begin

  cot2a  : count_ones_table_2
    port map (
      din       => din(3 downto 2), -- input
      dout      => A                -- output 
      );

  cot2b  : count_ones_table_2
    port map (
      din       => din(1 downto 0), -- input
      dout      => B                -- output 
      );

  C <= A & B;
  
  with C select
    dout <= "000" when "0000",
            "001" when "0001",
            "010" when "0010",
            "001" when "0100",
            "010" when "0101",
            "011" when "0110",
            "010" when "1000",
            "011" when "1001",
            "100" when "1010",
            unaffected when others;

end Behavioral;
