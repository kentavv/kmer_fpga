library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_table_16 is
  Port (din  : in  std_logic_vector (15 downto 0);
        dout : out std_logic_vector ( 4 downto 0));
end count_ones_table_16;

architecture Behavioral of count_ones_table_16 is

  component count_ones_table_8 is
      Port (din  : in  std_logic_vector (7 downto 0);
            dout : out std_logic_vector (3 downto 0));
  end component count_ones_table_8;

  signal A : std_logic_vector(3 downto 0);
  signal B : std_logic_vector(3 downto 0);
  signal C : std_logic_vector(7 downto 0);
  
begin

  cot8a  : count_ones_table_8
    port map (
      din       => din(15 downto 8), -- input
      dout      => A                -- output 
      );

  cot8b  : count_ones_table_8
    port map (
      din       => din(7 downto 0), -- input
      dout      => B                -- output 
      );

  C <= A & B;
  
  with C select
    dout <= "00000" when "00000000",
            "00001" when "00000001",
            "00010" when "00000010",
            "00011" when "00000011",
            "00100" when "00000100",
            "00101" when "00000101",
            "00110" when "00000110",
            "00111" when "00000111",
            "01000" when "00001000",
            "00001" when "00010000",
            "00010" when "00010001",
            "00011" when "00010010",
            "00100" when "00010011",
            "00101" when "00010100",
            "00110" when "00010101",
            "00111" when "00010110",
            "01000" when "00010111",
            "01001" when "00011000",
            "00010" when "00100000",
            "00011" when "00100001",
            "00100" when "00100010",
            "00101" when "00100011",
            "00110" when "00100100",
            "00111" when "00100101",
            "01000" when "00100110",
            "01001" when "00100111",
            "01010" when "00101000",
            "00011" when "00110000",
            "00100" when "00110001",
            "00101" when "00110010",
            "00110" when "00110011",
            "00111" when "00110100",
            "01000" when "00110101",
            "01001" when "00110110",
            "01010" when "00110111",
            "01011" when "00111000",
            "00100" when "01000000",
            "00101" when "01000001",
            "00110" when "01000010",
            "00111" when "01000011",
            "01000" when "01000100",
            "01001" when "01000101",
            "01010" when "01000110",
            "01011" when "01000111",
            "01100" when "01001000",
            "00101" when "01010000",
            "00110" when "01010001",
            "00111" when "01010010",
            "01000" when "01010011",
            "01001" when "01010100",
            "01010" when "01010101",
            "01011" when "01010110",
            "01100" when "01010111",
            "01101" when "01011000",
            "00110" when "01100000",
            "00111" when "01100001",
            "01000" when "01100010",
            "01001" when "01100011",
            "01010" when "01100100",
            "01011" when "01100101",
            "01100" when "01100110",
            "01101" when "01100111",
            "01110" when "01101000",
            "00111" when "01110000",
            "01000" when "01110001",
            "01001" when "01110010",
            "01010" when "01110011",
            "01011" when "01110100",
            "01100" when "01110101",
            "01101" when "01110110",
            "01110" when "01110111",
            "01111" when "01111000",
            "01000" when "10000000",
            "01001" when "10000001",
            "01010" when "10000010",
            "01011" when "10000011",
            "01100" when "10000100",
            "01101" when "10000101",
            "01110" when "10000110",
            "01111" when "10000111",
            "10000" when "10001000",
            unaffected when others;

end Behavioral;
