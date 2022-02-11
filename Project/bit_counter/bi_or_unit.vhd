library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bi_or_unit is
  Port (
        din  : in  std_logic_vector (95 downto 0);
--        din  : in  std_logic_vector (31 downto 0);
--        din  : in  std_logic_vector (15 downto 0);
--        din  : in  std_logic_vector ( 7 downto 0);
--        din  : in  std_logic_vector ( 3 downto 0);
--        din  : in  std_logic_vector ( 1 downto 0);
        dout : out std_logic_vector ( 1 downto 0));
end bi_or_unit;

architecture Behavioral of bi_or_unit is

  signal L5 : std_logic_vector(95 downto 0);
  signal L4 : std_logic_vector(47 downto 0);
  signal L3 : std_logic_vector(23 downto 0);
  signal L2 : std_logic_vector(11 downto 0);
  signal L1 : std_logic_vector( 5 downto 0);
  signal L0 : std_logic_vector( 1 downto 0);

begin

  L5 <= din;
--  L4 <= din;
--  L3 <= din;
--  L2 <= din;
--  L1 <= din;
--  L0 <= din;
  
  g4: for i in 0 to 47 generate
    L4(i) <= L5(i*2) or L5(i*2+1);
  end generate;

  g3: for i in 0 to 23 generate
    L3(i) <= L4(i*2) or L4(i*2+1);
  end generate;

  g2: for i in 0 to 11 generate
    L2(i) <= L3(i*2) or L3(i*2+1);
  end generate;

  g1: for i in 0 to 5 generate
    L1(i) <= L2(i*2) or L2(i*2+1);
  end generate;

--  g0: for i in 0 to 1 generate
--    L0(i) <= L1(i*2) or L1(i*2+1);
--  end generate;

  L0(0) <= L1(0) or L1(1) or L1(2);
  L0(1) <= L1(3) or L1(4) or L1(5);
  
  dout <= L0;
  
end Behavioral;

