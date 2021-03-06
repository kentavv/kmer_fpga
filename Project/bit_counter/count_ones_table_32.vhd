library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_table_32 is
  Port (din  : in  std_logic_vector (31 downto 0);
        dout : out std_logic_vector ( 5 downto 0));
end count_ones_table_32;

architecture Behavioral of count_ones_table_32 is

  component count_ones_table_16 is
      Port (din  : in  std_logic_vector (15 downto 0);
            dout : out std_logic_vector ( 4 downto 0));
  end component count_ones_table_16;

  signal A : std_logic_vector(4 downto 0);
  signal B : std_logic_vector(4 downto 0);
  signal C : std_logic_vector(9 downto 0);
  
begin

  cot16a  : count_ones_table_16
    port map (
      din       => din(31 downto 16), -- input
      dout      => A                -- output 
      );

  cot16b  : count_ones_table_16
    port map (
      din       => din(15 downto 0), -- input
      dout      => B                -- output 
      );

  C <= A & B;
  
  with C select
    dout <= "000000" when "0000000000",
            "000001" when "0000000001",
            "000010" when "0000000010",
            "000011" when "0000000011",
            "000100" when "0000000100",
            "000101" when "0000000101",
            "000110" when "0000000110",
            "000111" when "0000000111",
            "001000" when "0000001000",
            "001001" when "0000001001",
            "001010" when "0000001010",
            "001011" when "0000001011",
            "001100" when "0000001100",
            "001101" when "0000001101",
            "001110" when "0000001110",
            "001111" when "0000001111",
            "010000" when "0000010000",
            "000001" when "0000100000",
            "000010" when "0000100001",
            "000011" when "0000100010",
            "000100" when "0000100011",
            "000101" when "0000100100",
            "000110" when "0000100101",
            "000111" when "0000100110",
            "001000" when "0000100111",
            "001001" when "0000101000",
            "001010" when "0000101001",
            "001011" when "0000101010",
            "001100" when "0000101011",
            "001101" when "0000101100",
            "001110" when "0000101101",
            "001111" when "0000101110",
            "010000" when "0000101111",
            "010001" when "0000110000",
            "000010" when "0001000000",
            "000011" when "0001000001",
            "000100" when "0001000010",
            "000101" when "0001000011",
            "000110" when "0001000100",
            "000111" when "0001000101",
            "001000" when "0001000110",
            "001001" when "0001000111",
            "001010" when "0001001000",
            "001011" when "0001001001",
            "001100" when "0001001010",
            "001101" when "0001001011",
            "001110" when "0001001100",
            "001111" when "0001001101",
            "010000" when "0001001110",
            "010001" when "0001001111",
            "010010" when "0001010000",
            "000011" when "0001100000",
            "000100" when "0001100001",
            "000101" when "0001100010",
            "000110" when "0001100011",
            "000111" when "0001100100",
            "001000" when "0001100101",
            "001001" when "0001100110",
            "001010" when "0001100111",
            "001011" when "0001101000",
            "001100" when "0001101001",
            "001101" when "0001101010",
            "001110" when "0001101011",
            "001111" when "0001101100",
            "010000" when "0001101101",
            "010001" when "0001101110",
            "010010" when "0001101111",
            "010011" when "0001110000",
            "000100" when "0010000000",
            "000101" when "0010000001",
            "000110" when "0010000010",
            "000111" when "0010000011",
            "001000" when "0010000100",
            "001001" when "0010000101",
            "001010" when "0010000110",
            "001011" when "0010000111",
            "001100" when "0010001000",
            "001101" when "0010001001",
            "001110" when "0010001010",
            "001111" when "0010001011",
            "010000" when "0010001100",
            "010001" when "0010001101",
            "010010" when "0010001110",
            "010011" when "0010001111",
            "010100" when "0010010000",
            "000101" when "0010100000",
            "000110" when "0010100001",
            "000111" when "0010100010",
            "001000" when "0010100011",
            "001001" when "0010100100",
            "001010" when "0010100101",
            "001011" when "0010100110",
            "001100" when "0010100111",
            "001101" when "0010101000",
            "001110" when "0010101001",
            "001111" when "0010101010",
            "010000" when "0010101011",
            "010001" when "0010101100",
            "010010" when "0010101101",
            "010011" when "0010101110",
            "010100" when "0010101111",
            "010101" when "0010110000",
            "000110" when "0011000000",
            "000111" when "0011000001",
            "001000" when "0011000010",
            "001001" when "0011000011",
            "001010" when "0011000100",
            "001011" when "0011000101",
            "001100" when "0011000110",
            "001101" when "0011000111",
            "001110" when "0011001000",
            "001111" when "0011001001",
            "010000" when "0011001010",
            "010001" when "0011001011",
            "010010" when "0011001100",
            "010011" when "0011001101",
            "010100" when "0011001110",
            "010101" when "0011001111",
            "010110" when "0011010000",
            "000111" when "0011100000",
            "001000" when "0011100001",
            "001001" when "0011100010",
            "001010" when "0011100011",
            "001011" when "0011100100",
            "001100" when "0011100101",
            "001101" when "0011100110",
            "001110" when "0011100111",
            "001111" when "0011101000",
            "010000" when "0011101001",
            "010001" when "0011101010",
            "010010" when "0011101011",
            "010011" when "0011101100",
            "010100" when "0011101101",
            "010101" when "0011101110",
            "010110" when "0011101111",
            "010111" when "0011110000",
            "001000" when "0100000000",
            "001001" when "0100000001",
            "001010" when "0100000010",
            "001011" when "0100000011",
            "001100" when "0100000100",
            "001101" when "0100000101",
            "001110" when "0100000110",
            "001111" when "0100000111",
            "010000" when "0100001000",
            "010001" when "0100001001",
            "010010" when "0100001010",
            "010011" when "0100001011",
            "010100" when "0100001100",
            "010101" when "0100001101",
            "010110" when "0100001110",
            "010111" when "0100001111",
            "011000" when "0100010000",
            "001001" when "0100100000",
            "001010" when "0100100001",
            "001011" when "0100100010",
            "001100" when "0100100011",
            "001101" when "0100100100",
            "001110" when "0100100101",
            "001111" when "0100100110",
            "010000" when "0100100111",
            "010001" when "0100101000",
            "010010" when "0100101001",
            "010011" when "0100101010",
            "010100" when "0100101011",
            "010101" when "0100101100",
            "010110" when "0100101101",
            "010111" when "0100101110",
            "011000" when "0100101111",
            "011001" when "0100110000",
            "001010" when "0101000000",
            "001011" when "0101000001",
            "001100" when "0101000010",
            "001101" when "0101000011",
            "001110" when "0101000100",
            "001111" when "0101000101",
            "010000" when "0101000110",
            "010001" when "0101000111",
            "010010" when "0101001000",
            "010011" when "0101001001",
            "010100" when "0101001010",
            "010101" when "0101001011",
            "010110" when "0101001100",
            "010111" when "0101001101",
            "011000" when "0101001110",
            "011001" when "0101001111",
            "011010" when "0101010000",
            "001011" when "0101100000",
            "001100" when "0101100001",
            "001101" when "0101100010",
            "001110" when "0101100011",
            "001111" when "0101100100",
            "010000" when "0101100101",
            "010001" when "0101100110",
            "010010" when "0101100111",
            "010011" when "0101101000",
            "010100" when "0101101001",
            "010101" when "0101101010",
            "010110" when "0101101011",
            "010111" when "0101101100",
            "011000" when "0101101101",
            "011001" when "0101101110",
            "011010" when "0101101111",
            "011011" when "0101110000",
            "001100" when "0110000000",
            "001101" when "0110000001",
            "001110" when "0110000010",
            "001111" when "0110000011",
            "010000" when "0110000100",
            "010001" when "0110000101",
            "010010" when "0110000110",
            "010011" when "0110000111",
            "010100" when "0110001000",
            "010101" when "0110001001",
            "010110" when "0110001010",
            "010111" when "0110001011",
            "011000" when "0110001100",
            "011001" when "0110001101",
            "011010" when "0110001110",
            "011011" when "0110001111",
            "011100" when "0110010000",
            "001101" when "0110100000",
            "001110" when "0110100001",
            "001111" when "0110100010",
            "010000" when "0110100011",
            "010001" when "0110100100",
            "010010" when "0110100101",
            "010011" when "0110100110",
            "010100" when "0110100111",
            "010101" when "0110101000",
            "010110" when "0110101001",
            "010111" when "0110101010",
            "011000" when "0110101011",
            "011001" when "0110101100",
            "011010" when "0110101101",
            "011011" when "0110101110",
            "011100" when "0110101111",
            "011101" when "0110110000",
            "001110" when "0111000000",
            "001111" when "0111000001",
            "010000" when "0111000010",
            "010001" when "0111000011",
            "010010" when "0111000100",
            "010011" when "0111000101",
            "010100" when "0111000110",
            "010101" when "0111000111",
            "010110" when "0111001000",
            "010111" when "0111001001",
            "011000" when "0111001010",
            "011001" when "0111001011",
            "011010" when "0111001100",
            "011011" when "0111001101",
            "011100" when "0111001110",
            "011101" when "0111001111",
            "011110" when "0111010000",
            "001111" when "0111100000",
            "010000" when "0111100001",
            "010001" when "0111100010",
            "010010" when "0111100011",
            "010011" when "0111100100",
            "010100" when "0111100101",
            "010101" when "0111100110",
            "010110" when "0111100111",
            "010111" when "0111101000",
            "011000" when "0111101001",
            "011001" when "0111101010",
            "011010" when "0111101011",
            "011011" when "0111101100",
            "011100" when "0111101101",
            "011101" when "0111101110",
            "011110" when "0111101111",
            "011111" when "0111110000",
            "010000" when "1000000000",
            "010001" when "1000000001",
            "010010" when "1000000010",
            "010011" when "1000000011",
            "010100" when "1000000100",
            "010101" when "1000000101",
            "010110" when "1000000110",
            "010111" when "1000000111",
            "011000" when "1000001000",
            "011001" when "1000001001",
            "011010" when "1000001010",
            "011011" when "1000001011",
            "011100" when "1000001100",
            "011101" when "1000001101",
            "011110" when "1000001110",
            "011111" when "1000001111",
            "100000" when "1000010000",
            unaffected when others;

end Behavioral;
