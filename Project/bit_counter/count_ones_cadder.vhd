library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity count_ones_cadder is
  Port (din  : in  std_logic_vector (31 DOWNTO 0);
        dout : out std_logic_vector (5 downto 0));
end count_ones_cadder;

architecture Behavioral of count_ones_cadder is

begin

  PROCESS(din)
    VARIABLE accum: std_logic_vector (5 downto 0);
  BEGIN
    accum := (others => '0');
    FOR i IN 0 to 31 LOOP
      IF(din(i)='1') THEN
        accum := accum + 1;
      END IF;
    END LOOP;
    dout <= accum;
  END PROCESS;

end Behavioral;
