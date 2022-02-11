library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
end testbench;

architecture behavioral of testbench is

  component compare_unit is
  generic (id     : in  integer range 0 to 511);
  port (clk       : in  std_logic;
        load_tag  : in  std_logic;
        load_mhd  : in  std_logic;
        kmer      : in  std_logic_vector (63 DOWNTO 0);
        index     : in  integer range 0 to 511;
        dresult   : out std_logic);
  end component compare_unit;

  component shift_unit is
    port (clk       : in   std_logic;
          reset     : in   std_logic;
          din       : in   std_logic_vector( 7 downto 0);
          dout      : out  std_logic_vector(63 downto 0));
  end component shift_unit;

  signal sys_clk         : std_logic;
  signal ether_clk       : std_logic;
  signal ether_clk_cnt   : std_logic_vector(8 downto 0);
  signal proc_clk     : std_logic;
  signal proc_clk_cnt : std_logic_vector(8 downto 0);
  signal kmer            : std_logic_vector(63 downto 0);
  signal reset           : std_logic;
  signal reset_kmer      : std_logic;
  signal shift_in        : std_logic_vector(6 downto 0);
  signal shift_out_cu1   : std_logic_vector(6 downto 0);
  signal shift_out       : std_logic_vector(6 downto 0);

  type byte is array (0 to 64) of std_logic_vector(7 downto 0);
  signal data         : byte := (x"02",
                                 x"ff", x"ee", x"dd", x"cc", x"bb", x"aa", x"99", x"88",
                                 x"77", x"66", x"55", x"44", x"33", x"22", x"11", x"00",
                                 x"f0", x"e1", x"d2", x"c3", x"b4", x"a5", x"96", x"87",
                                 x"78", x"69", x"5a", x"4b", x"3c", x"2d", x"1e", x"0f",
                                 x"ff", x"ee", x"dd", x"cc", x"bb", x"aa", x"99", x"88",
                                 x"77", x"66", x"55", x"44", x"33", x"22", x"11", x"00",
                                 x"f0", x"e1", x"d2", x"c3", x"b4", x"a5", x"96", x"87",
                                 x"78", x"69", x"5a", x"4b", x"3c", x"2d", x"1e", x"0f");

  signal result        : std_logic_vector(1 downto 0);

  signal cu_index      : integer range 0 to 511;

  signal ether_byte      : std_logic_vector(7 downto 0);
  signal ether_nxt_index : integer range 128 downto 0 := 0;
  signal kmer_load       : std_logic;
  signal kmer_load_cnt   : integer range 64 downto 0 := 0;

  signal mhd_load      : std_logic;
  signal mhd_load_cnt  : integer range 64 downto 0 := 0;

begin

  gen_cmp_units: for n in 1 to 2 generate
  cmp_unit : compare_unit
    generic map (
      id        => n                    -- input
      )
    port map (
      clk       => proc_clk,            -- input
      load_tag  => kmer_load,           -- input 
      load_mhd  => mhd_load,            -- input 
      kmer      => kmer,                -- input
      index     => cu_index,            -- input
      dresult   => result(n-1)            -- input
      );
  end generate;
  
  su : shift_unit
    port map (
      clk       => proc_clk,            -- input
      reset     => reset,               -- input
      din       => ether_byte,          -- input
      dout      => kmer                 -- output
      );

  startup : process
  begin
    wait for 10 ns;
    reset <= '1';
    shift_in <= (others => '0');
    wait for 10 ns;
    reset <= '0';
    reset_kmer <= '1';
    wait for 10 ns;
    reset_kmer <= '0';
    wait for 1 ms;
  end process startup;
  
  sys_clk_gen : process
  begin
    sys_clk <= '0';
    wait for 10 ns;
    loop
      wait for 5 ns;
      sys_clk <= '1';
      wait for 5 ns;
      sys_clk <= '0';
    end loop;
  end process sys_clk_gen;

  ether_clk_gen : process(sys_clk)
  begin
    if(sys_clk'event and sys_clk = '1') then
      if(reset = '1') then
        ether_clk <= '0';
        ether_clk_cnt <= (others => '0');
      else 
        ether_clk_cnt <= ether_clk_cnt + 1;
        if(ether_clk_cnt = 3) then
          ether_clk_cnt <= (others => '0');
          if(ether_clk = '0') then
            ether_clk <= '1';
          else
            ether_clk <= '0';
          end if;
        end if;
      end if;
    end if;
  end process ether_clk_gen;

  proc_clk <= sys_clk;
  proc_clk_cnt <= (others => '0');
  
--  proc_clk_gen : process(sys_clk)
--  begin
--    if(sys_clk'event and sys_clk = '1') then
--      if(reset = '1') then
--        proc_clk_cnt <= (others => '0');           
--        proc_clk <= '0';           
--      else 
--        proc_clk_cnt <= proc_clk_cnt + 1;
--        if(proc_clk_cnt = 1) then
--          proc_clk_cnt <= (others => '0');
--          if(proc_clk = '0') then
--            proc_clk <= '1';
--          else
--            proc_clk <= '0';
--          end if;
--        end if;
--      end if;
--    end if;
--  end process proc_clk_gen;

  ether_increment : process(ether_clk)
  begin
    if(ether_clk'event and ether_clk = '1') then
      if(reset = '1') then
        ether_nxt_index <= 0;
        --ether_byte <= data(0);
      else
        ether_byte <= data(ether_nxt_index);
        if(ether_nxt_index < 64) then
          ether_nxt_index <= ether_nxt_index + 1;
        else
          ether_nxt_index <= 0;
        end if;
      end if;
    end if;
  end process ether_increment;

  kmer_increment : process(proc_clk)
  begin
    if(proc_clk'event and proc_clk = '1') then
      if(reset_kmer = '1') then
        mhd_load <= '1';
        mhd_load_cnt <= 0;
        kmer_load <= '0';
        kmer_load_cnt <= 0;
        cu_index <= 1;
      elsif(mhd_load = '1') then
        if(mhd_load_cnt < 12) then
          mhd_load_cnt <= mhd_load_cnt + 1;
        else
          mhd_load <= '0';
          kmer_load <= '1';
        end if;
      elsif(kmer_load = '1') then
        if(kmer_load_cnt < 47) then
          kmer_load_cnt <= kmer_load_cnt + 1;
          cu_index <= 1;
        else
          kmer_load <= '0';
        end if;
      else
      end if;
    end if;
  end process kmer_increment;

  --------------------------------------------------------------------
  -- If the simulation is still going after 2 ms
  -- then something has gone wrong
  --------------------------------------------------------------------
  p_timebomb : process
  begin
    wait for 2 ms;
    assert false
      report "** ERROR - Simulation running forever!"
      severity failure;
  end process p_timebomb;

end Behavioral;
