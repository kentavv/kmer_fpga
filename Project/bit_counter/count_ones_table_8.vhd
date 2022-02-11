library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_table_8 is
  Port (din  : in  std_logic_vector (7 downto 0);
        dout : out std_logic_vector (3 downto 0));
end count_ones_table_8;

architecture Behavioral of count_ones_table_8 is

  component count_ones_table_4 is
      Port (din  : in  std_logic_vector (3 downto 0);
            dout : out std_logic_vector (2 downto 0));
  end component count_ones_table_4;

  signal A : std_logic_vector(2 downto 0);
  signal B : std_logic_vector(2 downto 0);
  signal C : std_logic_vector(5 downto 0);
  
begin

  cot4a  : count_ones_table_4
    port map (
      din       => din(7 downto 4), -- input
      dout      => A                -- output 
      );

  cot4b  : count_ones_table_4
    port map (
      din       => din(3 downto 0), -- input
      dout      => B                -- output 
      );

  C <= A & B;
  
  with C select
    dout <= "0000" when "000000",
            "0001" when "000001",
            "0010" when "000010",
            "0011" when "000011",
            "0100" when "000100",
            "0001" when "001000",
            "0010" when "001001",
            "0011" when "001010",
            "0100" when "001011",
            "0101" when "001100",
            "0010" when "010000",
            "0011" when "010001",
            "0100" when "010010",
            "0101" when "010011",
            "0110" when "010100",
            "0011" when "011000",
            "0100" when "011001",
            "0101" when "011010",
            "0110" when "011011",
            "0111" when "011100",
            "0100" when "100000",
            "0101" when "100001",
            "0110" when "100010",
            "0111" when "100011",
            "1000" when "100100",
            unaffected when others;

end Behavioral;
