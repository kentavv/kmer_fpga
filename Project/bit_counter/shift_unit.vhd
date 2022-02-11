library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_unit is
  Port (clk       : in   std_logic;
        reset     : in   std_logic;
        enable    : in   std_logic;
        din       : in   std_logic_vector( 7 downto 0);
        dout      : out  std_logic_vector(63 downto 0));
end shift_unit;

architecture behavioral of shift_unit is

  signal buf : std_logic_vector(71 downto 0);
  signal cnt : std_logic_vector( 3 downto 0);

begin
  
  shifter : process(clk)
  begin
    if(rising_edge(clk)) then
	   if(reset = '1') then
        cnt <= (others => '0');
        buf <= (others => '0');
	   elsif(enable = '1') then
        cnt <= cnt + 1;
--        if(cnt = 4) then
--          cnt <= (others => '0');
--          buf(7 downto 0) <= din;
--        else
--          buf <= buf(69 downto 0) & "00";
--        end if;
        buf <= buf(69 downto 0) & "00";
        if(cnt = 3) then
          cnt <= (others => '0');
          buf(7 downto 0) <= din;
        end if;
      end if;
    end if;
  end process shifter;
  
  dout <= buf(71 downto 8);

end behavioral;
