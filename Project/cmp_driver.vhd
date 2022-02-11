----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kent A. Vander Velden
-- 
-- Create Date:    14:48:25 11/28/2008 
-- Design Name: 
-- Module Name:    cmp_driver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
--library unisim;
--use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cmp_driver is
   port (
	   cmp_clk           : in  std_logic;
		reset_i           : in std_logic;
		
  	   in_fifo_rd_en     : out std_logic;
	   in_fifo_dout      : in  std_logic_vector(7 downto 0);
      in_fifo_ready     : in  std_logic;
      out_fifo_wr_en    : out std_logic;
      out_fifo_din      : out std_logic_vector(7 downto 0);
		
      GPIO_LED_0        : out std_logic;
      GPIO_LED_1        : out std_logic;
      GPIO_LED_2        : out std_logic;
      GPIO_LED_3        : out std_logic;
      GPIO_LED_4        : out std_logic;
      GPIO_LED_5        : out std_logic;
      GPIO_LED_6        : out std_logic;
      GPIO_LED_7        : out std_logic
      );
end cmp_driver;

architecture Behavioral of cmp_driver is

  constant cmp_unit_count  : integer := 96;
  
  component compare_unit is
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
  end component compare_unit;

  component shift_unit is
    port (clk       : in   std_logic;
          reset     : in   std_logic;
          enable    : in   std_logic;
          din       : in   std_logic_vector( 7 downto 0);
          dout      : out  std_logic_vector(63 downto 0));
  end component shift_unit;
  
  component mux64 is
    port (a      : in  std_logic_vector(63 downto 0);
          b      : in  std_logic_vector(63 downto 0);
          sel    : in  std_logic;
          dout   : out std_logic_vector(63 downto 0));    
  end component mux64;

  component bi_or_unit is
    port (din      : in  std_logic_vector(cmp_unit_count-1 downto 0);     -- change if changing cmp unit count
          dout     : out std_logic_vector(1 downto 0));
  end component bi_or_unit;

  type proc_state_type is (WAIT_FIFO_FULL_FIRST, CONSUME_PARAMETERS_PRE_DELAY, CONSUME_PARAMETERS, CONSUME_PARAMETERS_TAGS, WAIT_FIFO_FULL, CONSUME_PRE_DELAY, CONSUME_PRE_LOAD, CONSUME, ADD_PAD);
  signal  proc_state       : proc_state_type;
--  signal  proc_state_next  : proc_state_type;

  signal proc_counter       : integer range 0 to 2047;
  signal proc_counter2      : integer range 0 to 7;

  signal kmer            : std_logic_vector(63 downto 0);
--  signal reset           : std_logic;
--  signal reset_kmer      : std_logic;
--  signal shift_in        : std_logic_vector(6 downto 0);
--  signal shift_out_cu1   : std_logic_vector(6 downto 0);
--  signal shift_out       : std_logic_vector(6 downto 0);

  signal raw_result        : std_logic_vector(cmp_unit_count-1 downto 0);  -- change if changing cmp unit count
  signal kmer_result       : std_logic_vector(1 downto 0);
  signal kmer_result_comb  : std_logic_vector(1 downto 0);
  signal result            : std_logic_vector(7 downto 0);
  
  signal cu_index      : integer range 0 to 511;
  signal su_enable     : std_logic;
  
--  signal ether_byte      : std_logic_vector(7 downto 0);
--  signal ether_nxt_index : integer range 128 downto 0 := 0;
  signal kmer_load       : std_logic;
--  signal kmer_load_cnt   : integer range 64 downto 0 := 0;

  signal mhd_load      : std_logic;
--  signal mhd_load_cnt  : integer range 64 downto 0 := 0;

  signal check_rc      : std_logic;
  signal check_fwd     : std_logic;
  signal check_rev     : std_logic;
  signal pkt_count     : std_logic_vector(31 downto 0);
  
  signal in_fifo_dout_reg : std_logic_vector(7 downto 0);
  
  signal su_out   : std_logic_vector(63 downto 0);
  signal kmer_tag : std_logic_vector(63 downto 0);
  signal kmer_sel : std_logic;
  
  signal dbg_state : std_logic_vector(4 downto 0);
  
begin

  gen_cmp_units: for n in 1 to cmp_unit_count generate    -- change if changing cmp unit count
  cmp_unit : compare_unit
    generic map (
      id        => n                   -- input
      )
    port map (
      clk       => cmp_clk,            -- input
		reset     => reset_i,            -- input
      load_tag  => kmer_load,          -- input
      load_mhd  => mhd_load,           -- input
      kmer      => kmer,               -- input
      index     => cu_index,           -- input
      check_rc  => check_rc,           -- input
      check_fwd => check_fwd,          -- input
      check_rev => check_rev,          -- input
      result    => raw_result(n-1)     -- output
      );
  end generate;
  
  su : shift_unit
    port map (
      clk       => cmp_clk,            -- input
      reset     => reset_i,            -- input
      enable    => su_enable,          -- intput
      din       => in_fifo_dout_reg,   -- input
--      din       => ether_byte,       -- input
      dout      => su_out                -- output
      );

    kmer_mux : mux64
      port map (
        a    => su_out,   -- input (sel = 0)
        b    => kmer_tag, -- input (sel = 1)
        sel  => kmer_sel, -- input
        dout => kmer      -- output
        );

    kmer_compress : bi_or_unit
      port map (
        din  => raw_result,      -- input
        dout => kmer_result_comb -- output
        );
          
    GPIO_LED_0  <= '0';
    GPIO_LED_1  <= '0';
    GPIO_LED_3  <= '0';
    GPIO_LED_2  <= dbg_state(4);
    GPIO_LED_4  <= dbg_state(3);
    GPIO_LED_5  <= dbg_state(2);
    GPIO_LED_6  <= dbg_state(1);
    GPIO_LED_7  <= dbg_state(0);

--    GPIO_LED_0  <= pkt_count(7);
--    GPIO_LED_1  <= pkt_count(6);
--    GPIO_LED_3  <= pkt_count(5);
--    GPIO_LED_2  <= pkt_count(4);
--    GPIO_LED_4  <= pkt_count(3);
--    GPIO_LED_5  <= pkt_count(2);
--    GPIO_LED_6  <= pkt_count(1);
--    GPIO_LED_7  <= pkt_count(0);
				
    do_it : process(cmp_clk) 
	 begin
		if(rising_edge(cmp_clk)) then
	     if(reset_i   = '1') then
		  dbg_state <= (others => '0');
		  
		    proc_state <= WAIT_FIFO_FULL_FIRST;
		    kmer_load  <= '0';
		    mhd_load   <= '0';
		    check_rc   <= '0';
		    check_fwd  <= '0';
		    check_rev  <= '0';
		    pkt_count  <= (others => '0');
		    su_enable  <= '0';
		    kmer_sel   <= '0';
		    kmer_tag   <= (others => '0');
		    result     <= (others => '0');
--		    kmer_result <= (others => '0');
        else
 	       in_fifo_rd_en    <= '0';
		    out_fifo_wr_en   <= '0';
		    mhd_load         <= '0';
		    kmer_load        <= '0';
		    cu_index         <= 0;
		    su_enable        <= '0';
		    kmer_sel         <= '0';
		    in_fifo_dout_reg <= in_fifo_dout;
		  
		    if(pkt_count = 0) then
			   dbg_state(4) <= '1';
		    else
			   dbg_state(4) <= '0';
		    end if;
			 
          case proc_state is
		    when WAIT_FIFO_FULL_FIRST =>
			 dbg_state(3 downto 0) <= "0001";
		      if(in_fifo_ready = '1') then
   		     proc_counter <= 0;
			     proc_state   <= CONSUME_PARAMETERS_PRE_DELAY;
			   end if;
		    when CONSUME_PARAMETERS_PRE_DELAY => -- wait a couple of cycles so FIFO delay is pass
		    dbg_state(3 downto 0) <= "0010";
  			   in_fifo_rd_en <= '1';
		      proc_counter  <= proc_counter + 1;
		      if(proc_counter = 1) then
		        proc_counter <= 0;
		        proc_state   <= CONSUME_PARAMETERS;
		      end if;
		    when CONSUME_PARAMETERS =>
			 dbg_state(3 downto 0) <= "0011";
 		      in_fifo_rd_en <= '1';
            proc_counter <= proc_counter + 1;
		      if(proc_counter = 0) then 
		        check_rc  <= in_fifo_dout(0);
		        check_fwd <= in_fifo_dout(1);
		        check_rev <= in_fifo_dout(2);
  		      elsif(proc_counter < 5) then 
   		     pkt_count <= pkt_count(23 downto 0) & in_fifo_dout;
  		      elsif(proc_counter < 13) then
  		        kmer_sel <= '1'; 
			     kmer_tag <= kmer_tag(55 downto 0) & in_fifo_dout_reg;
			     mhd_load <= '1';
			   elsif(proc_counter = 13) then
  		        kmer_sel     <= '1'; 
			     kmer_tag     <= kmer_tag(55 downto 0) & in_fifo_dout_reg;
			     mhd_load     <= '1';
			     proc_state   <= CONSUME_PARAMETERS_TAGS;
			     proc_counter <= 0;
			   end if;
		    when CONSUME_PARAMETERS_TAGS =>    
			 dbg_state(3 downto 0) <= "0100";
		      if(proc_counter < 984) then 
		        in_fifo_rd_en <= '1';
		      end if;
		    
		      if(proc_counter < 986) then  
 			     kmer_sel     <= '1';                          
			     cu_index     <= (proc_counter / 8) + 1;
			     kmer_tag     <= kmer_tag(55 downto 0) & in_fifo_dout_reg;
			     kmer_load    <= '1';
			     proc_counter <= proc_counter + 1;
			   elsif(proc_counter = 986) then
			     kmer_sel     <= '1';
			     cu_index     <= (proc_counter / 8) + 1;
			     kmer_tag     <= kmer_tag(55 downto 0) & in_fifo_dout_reg;
			     kmer_load    <= '1';
			     proc_counter <= 0;
			     proc_state   <= WAIT_FIFO_FULL;
			   end if;
		    when WAIT_FIFO_FULL =>
			 dbg_state(3 downto 0) <= "0101";
				if(in_fifo_ready = '1') then
--			     if(pkt_count = 0) then
-- 	  		       in_fifo_rd_en <= '1';
--				    proc_state <= CONSUME_PARAMETERS;
--				  else 
    		       proc_counter  <= 0;
   		       proc_counter2 <= 0;
			     --proc_state <= CONSUME_PRE_DELAY;
			       proc_state    <= CONSUME_PRE_LOAD;
 		          su_enable     <= '1';
			       in_fifo_rd_en <= '0';
--				  end if;
			   end if;
		    when CONSUME_PRE_DELAY =>
			 dbg_state(3 downto 0) <= "0110";
			   in_fifo_rd_en <= '1';
			   proc_counter  <= proc_counter + 1;
 		      if(proc_counter = 1) then
		        proc_counter <= 0;
		        proc_state   <= CONSUME_PRE_LOAD;
 		        su_enable    <= '1';
            end if;
		    when CONSUME_PRE_LOAD =>
			 dbg_state(3 downto 0) <= "0111";
 		      su_enable <= '1';
			   in_fifo_rd_en <= '0';
			   proc_counter2 <= proc_counter2 + 1;
			 
			   if(proc_counter2 = 0) then
			     in_fifo_rd_en <= '1';
			   end if;
			 
			   if(proc_counter2 = 3) then
			     proc_counter  <= proc_counter + 1;
			     proc_counter2 <= 0;
			   end if;
			 
		      if(proc_counter = 8 and proc_counter2 = 3) then -- nine bytes with four cc each to reach output of shift unit
		        proc_counter <= 0;
		      --proc_counter2 <= 0;
		        proc_state <= CONSUME;
            end if;
		    when CONSUME =>
			 dbg_state(3 downto 0) <= "1000";
		      su_enable <= '1';
            in_fifo_rd_en <= '0';
            proc_counter2 <= proc_counter2 + 1;
          
--          kmer_result(1) <= raw_result(7) or raw_result(6) or raw_result(5) or raw_result(4);
--          kmer_result(0) <= raw_result(3) or raw_result(2) or raw_result(1) or raw_result(0);
            kmer_result(1) <= kmer_result_comb(1);
            kmer_result(0) <= kmer_result_comb(0);
                    
--            if(raw_result(7 downto 4) = 0) then
--              kmer_result(1) <= '0';
--            else 
--              kmer_result(1) <= '1';
--            end if;
          
--            if(raw_result(3 downto 0) = 0) then
--            kmer_result(0) <= '0';
--            else 
--            kmer_result(0) <= '1';
--            end if;
          
            result <= result(5 downto 0) & kmer_result;
          
            if(proc_counter2 = 0) then
              in_fifo_rd_en <= '1';
            end if;
      
            if(proc_counter2 = 3) then 
              proc_counter  <= proc_counter + 1;
              proc_counter2 <= 0;
            end if;
      
            if(proc_counter > 0 and proc_counter2 = 0) then
              out_fifo_wr_en <= '1';
            end if; 
        
            if(proc_counter > 991) then
              in_fifo_rd_en <= '0';
            end if;
      
			   if(proc_counter = 993 and proc_counter2 = 3) then
              proc_state     <= ADD_PAD;
              su_enable      <= '0';
			     in_fifo_rd_en  <= '0';
			     out_fifo_wr_en <= '0';
			     proc_counter   <= 0;
			     proc_counter2  <= 0;
				  pkt_count      <= pkt_count - 1;
			   end if;
		    when ADD_PAD =>
			 dbg_state(3 downto 0) <= "1001";
		      out_fifo_wr_en <= '1';
		      proc_counter   <= proc_counter + 1;
		      result         <= x"ff";
		      if(proc_counter = 7) then
		        out_fifo_wr_en <= '0';
		        proc_counter   <= 0;
		        proc_state     <= WAIT_FIFO_FULL;
		      end if;
          when OTHERS =>
            proc_state <= WAIT_FIFO_FULL;
          end case;
		  end if;
		end if;
	 end process do_it;

  --kmer_result <= "01";
  out_fifo_din <= result;
  --  out_fifo_din <= x"db";
    
end Behavioral;
