library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux64 is
  Port (a      : in  std_logic_vector(63 downto 0);
        b      : in  std_logic_vector(63 downto 0);
        sel    : in  std_logic;
        dout   : out std_logic_vector(63 downto 0));    
end mux64;

architecture behavioral of mux64 is

begin
  
  dout <= b when sel = '1' else
          a;

end behavioral;

