library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity compare_unit is
  generic (id     : in  integer range 0 to 511);
  port (clk       : in  std_logic;
        reset     : in  std_logic;
        load_tag  : in  std_logic;
        load_mhd  : in  std_logic;
        kmer      : in  std_logic_vector (63 downto 0);
        index     : in  integer range 0 to 511;
        check_rc  : in  std_logic;
        check_fwd : in  std_logic;
        check_rev : in  std_logic;
        result    : out std_logic);
end compare_unit;

architecture behavioral of compare_unit is
  component reverse_comp is
    port (din   : in  std_logic_vector (63 downto 0);
          dout  : out std_logic_vector (63 downto 0));
  end component reverse_comp;

  component reverse is
    port (din   : in  std_logic_vector (63 downto 0);
          dout  : out std_logic_vector (63 downto 0));
  end component reverse;

  component count_ones is
    port (din   : in  std_logic_vector (31 downto 0);
          dout  : out std_logic_vector ( 5 downto 0));
  end component count_ones;

  component mash is
    port (din  : in  std_logic_vector (63 downto 0);
          dout : out std_logic_vector (31 downto 0));
  end component mash;

  component compare6 is
    port (din1  : in  std_logic_vector (5 DOWNTO 0);
          din2  : in  std_logic_vector (5 DOWNTO 0);
          dout  : out std_logic);
  end component compare6;

  signal tag     : std_logic_vector(63 downto 0);
  signal tag_rc  : std_logic_vector(63 downto 0);

  signal rev_kmer : std_logic_vector(63 downto 0);

  signal kmer_xor_tag    : std_logic_vector(63 downto 0);
  signal kmer_xor_tag_rc : std_logic_vector(63 downto 0);
  signal rev_kmer_xor_tag    : std_logic_vector(63 downto 0);
  signal rev_kmer_xor_tag_rc : std_logic_vector(63 downto 0);

  signal kmer_xor_tag_mashed    : std_logic_vector(31 downto 0);
  signal kmer_xor_tag_rc_mashed : std_logic_vector(31 downto 0);
  signal rev_kmer_xor_tag_mashed    : std_logic_vector(31 downto 0);
  signal rev_kmer_xor_tag_rc_mashed : std_logic_vector(31 downto 0);

  signal max_hd  : std_logic_vector(5 downto 0);

  signal ones    : std_logic_vector(5 downto 0);
  signal ones_rc : std_logic_vector(5 downto 0);
  signal rev_ones    : std_logic_vector(5 downto 0);
  signal rev_ones_rc : std_logic_vector(5 downto 0);

  signal ones_cmp    : std_logic;
  signal ones_rc_cmp : std_logic;
  signal rev_ones_cmp    : std_logic;
  signal rev_ones_rc_cmp : std_logic;

  --signal result      : std_logic;

begin
  rc : reverse_comp
    port map (
      din  => tag,                       -- input
      dout => tag_rc                     -- output
      );

  rev : reverse
    port map (
      din  => kmer,                       -- input
      dout => rev_kmer                    -- output
      );

  m1 : mash
    port map (
      din  => kmer_xor_tag,              -- input
      dout => kmer_xor_tag_mashed        -- output
      );

  m2 : mash
    port map (
      din  => kmer_xor_tag_rc,           -- input
      dout => kmer_xor_tag_rc_mashed     -- output
      );

  m3 : mash
    port map (
      din  => rev_kmer_xor_tag,          -- input
      dout => rev_kmer_xor_tag_mashed    -- output
      );

  m4 : mash
    port map (
      din  => rev_kmer_xor_tag_rc,       -- input
      dout => rev_kmer_xor_tag_rc_mashed -- output
      );

  co1 : count_ones
    port map (
      din  => kmer_xor_tag_mashed,       -- input
      dout => ones                       -- output
      );

  co2 : count_ones
    port map (
      din  => kmer_xor_tag_rc_mashed,    -- input
      dout => ones_rc                    -- output
      );

  co3 : count_ones
    port map (
      din  => rev_kmer_xor_tag_mashed,   -- input
      dout => rev_ones                   -- output
      );

  co4 : count_ones
    port map (
      din  => rev_kmer_xor_tag_rc_mashed, -- input
      dout => rev_ones_rc                 -- output
      );

  cmp1 : compare6
    port map (
      din1 => ones,                      -- input
      din2 => max_hd,                    -- input
      dout => ones_cmp                   -- output
      );

  cmp2 : compare6
    port map (
      din1 => ones_rc,                   -- input
      din2 => max_hd,                    -- input
      dout => ones_rc_cmp                -- output
      );

  cmp3 : compare6
    port map (
      din1 => rev_ones,                  -- input
      din2 => max_hd,                    -- input
      dout => rev_ones_cmp               -- output
      );

  cmp4 : compare6
    port map (
      din1 => rev_ones_rc,               -- input
      din2 => max_hd,                    -- input
      dout => rev_ones_rc_cmp            -- output
      );

  do_it : process(clk)
  begin
    if(rising_edge(clk)) then
      if(reset = '1') then
	     tag <= (others => '0');
	     max_hd <= (others => '0');
		else
        if(load_tag = '1') then
          if(index = id) then
            tag <= kmer;
          end if;
        elsif(load_mhd = '1') then
          max_hd <= kmer(5 downto 0);
        end if;
		end if;
    end if;
  end process do_it;
  
  kmer_xor_tag    <= kmer xor tag;
  kmer_xor_tag_rc <= kmer xor tag_rc;
  
  rev_kmer_xor_tag    <= rev_kmer xor tag;
  rev_kmer_xor_tag_rc <= rev_kmer xor tag_rc;

  result <= (check_fwd and (ones_cmp     or (check_rc and ones_rc_cmp    ))) or 
            (check_rev and (rev_ones_cmp or (check_rc and rev_ones_rc_cmp)));
  
end behavioral;

