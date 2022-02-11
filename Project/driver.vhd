----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kent A. Vander Velden
-- 
-- Create Date:    05:17:18 11/28/2008 
-- Design Name: 
-- Module Name:    driver - Behavioral 
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

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity driver is
   port (
	   cmp_clk                 : in  std_logic;
      ll_clk_0_i              : in  std_logic;
		reset_i                 : in std_logic;
		
      rx_ll_data_0_i          : in  std_logic_vector(7 downto 0);
      rx_ll_sof_n_0_i         : in  std_logic;
      rx_ll_eof_n_0_i         : in  std_logic;
      rx_ll_src_rdy_n_0_i     : in  std_logic;
      rx_ll_dst_rdy_n_0_i     : out std_logic;

      tx_ll_data_0_i          : out  std_logic_vector(7 downto 0);
      tx_ll_sof_n_0_i         : out  std_logic;
      tx_ll_eof_n_0_i         : out  std_logic;
      tx_ll_src_rdy_n_0_i     : out  std_logic;
      tx_ll_dst_rdy_n_0_i     : in  std_logic;
		
      GPIO_LED_0              : out std_logic;
      GPIO_LED_1              : out std_logic;
      GPIO_LED_2              : out std_logic;
      GPIO_LED_3              : out std_logic;
      GPIO_LED_4              : out std_logic;
      GPIO_LED_5              : out std_logic;
      GPIO_LED_6              : out std_logic;
      GPIO_LED_7              : out std_logic
      );
end driver;

architecture Behavioral of driver is

component in_fifo is
	port (
	din: IN std_logic_VECTOR(7 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(7 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic;
	prog_full: OUT std_logic);
end component;

component out_fifo is
	port (
	din: IN std_logic_VECTOR(7 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(7 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic;
	prog_full: OUT std_logic);
end component;

component cmp_driver is
   port (
	   cmp_clk                 : in  std_logic;
		reset_i                 : in std_logic;
		
  	   in_fifo_rd_en     : out std_logic;
	   in_fifo_dout      : in  std_logic_vector(7 downto 0);
      in_fifo_ready     : in  std_logic;
	   out_fifo_wr_en    : out std_logic;
	   out_fifo_din      : out std_logic_vector(7 downto 0);
		
      GPIO_LED_0              : out std_logic;
      GPIO_LED_1              : out std_logic;
      GPIO_LED_2              : out std_logic;
      GPIO_LED_3              : out std_logic;
      GPIO_LED_4              : out std_logic;
      GPIO_LED_5              : out std_logic;
      GPIO_LED_6              : out std_logic;
      GPIO_LED_7              : out std_logic
      );
end component;

type in_state_type is (WAIT_SOF, SKIP_HEADER, RCV_PAYLOAD, PAUSE);
signal  in_state       : in_state_type;
signal  in_state_next  : in_state_type;

type out_state_type is (WAIT_SOF, WAIT_FIFO_FULL, SEND_HEADER, SEND_PAYLOAD, PAUSE);
signal  out_state       : out_state_type;
signal  out_state_next  : out_state_type;

constant udp_header_array :  std_logic_vector(335 downto 0) := x"001b21233354aabbccddee00080045000404000040004011b387c0a8010cc0a80105ae22ae2203f00000";
signal udp_header_array_shift_reg : std_logic_vector(335 downto 0);
  

signal rx_ll_dst_rdy_n_0_i_reg : std_logic;
signal rx_ll_data_0_i_reg : std_logic_vector(7 downto 0);

signal tx_ll_sof_n_0_i_reg : std_logic;
signal tx_ll_eof_n_0_i_reg : std_logic;
signal tx_ll_src_rdy_n_0_i_reg : std_logic;
signal tx_ll_data_0_i_reg : std_logic_vector(7 downto 0);

signal input_counter       : integer range 0 to 2047;
signal output_counter      : integer range 0 to 2047;

signal in_fifo_din : std_logic_vector(7 downto 0);
signal in_fifo_rd_en : std_logic;
signal in_fifo_wr_en : std_logic;

signal in_fifo_empty : std_logic;
signal in_fifo_prog_full : std_logic;
signal in_fifo_dout : std_logic_vector(7 downto 0);

signal in_fifo_ready : std_logic;

signal out_fifo_din : std_logic_vector(7 downto 0);
signal out_fifo_rd_en : std_logic;
signal out_fifo_wr_en : std_logic;

signal out_fifo_prog_full : std_logic;
signal out_fifo_dout : std_logic_vector(7 downto 0);

signal out_fifo_din_fixed : std_logic_vector(7 downto 0);

begin

in_fifo1 : in_fifo 
	port map (
	din       => rx_ll_data_0_i_reg, --: IN std_logic_VECTOR(7 downto 0);
	rd_clk    => cmp_clk,            --: IN std_logic;
	rd_en     => in_fifo_rd_en,      --: IN std_logic;
	rst       => reset_i,            --: IN std_logic;
	wr_clk    => ll_clk_0_i,         --: IN std_logic;
	wr_en     => in_fifo_wr_en,      --: IN std_logic;
	dout      => in_fifo_dout,       -- : OUT std_logic_VECTOR(7 downto 0);
	empty     => in_fifo_empty,      --: OUT std_logic;
	full      => open,               --: OUT std_logic;
	prog_full => in_fifo_prog_full   --: OUT std_logic
	);

out_fifo1 : out_fifo 
	port map (
	din       => out_fifo_din,      --: IN std_logic_VECTOR(7 downto 0);
--	din       => out_fifo_din_fixed, --: IN std_logic_VECTOR(7 downto 0);
	rd_clk    => ll_clk_0_i,        --: IN std_logic;
	rd_en     => out_fifo_rd_en,    --: IN std_logic;
	rst       => reset_i,           --: IN std_logic;
	wr_clk    => cmp_clk,           --: IN std_logic;
	wr_en     => out_fifo_wr_en,    --: IN std_logic;
	dout      => out_fifo_dout,     --: OUT std_logic_VECTOR(7 downto 0);
	empty     => open,              --: OUT std_logic;
	full      => open,              --: OUT std_logic;
	prog_full => out_fifo_prog_full --: OUT std_logic
	);

cmp_driver1 : cmp_driver 
   port map (
	   cmp_clk           => cmp_clk,        --: in  std_logic;
		reset_i           => reset_i,        --: in std_logic;
		
  	   in_fifo_rd_en     => in_fifo_rd_en,  --: out std_logic;
	   in_fifo_dout      => in_fifo_dout,   --: in  std_logic_vector(7 downto 0);
      in_fifo_ready     => in_fifo_ready,  --: in  std_logic;
	   out_fifo_wr_en    => out_fifo_wr_en, --: out std_logic;
	   out_fifo_din      => out_fifo_din,   --: out std_logic_vector(7 downto 0);
		
--      GPIO_LED_0        => GPIO_LED_0, --              : out std_logic;
--      GPIO_LED_1        => GPIO_LED_1, --              : out std_logic;
--      GPIO_LED_2        => GPIO_LED_2, --              : out std_logic;
--      GPIO_LED_3        => GPIO_LED_3, --              : out std_logic;
--      GPIO_LED_4        => GPIO_LED_4, --              : out std_logic;
--      GPIO_LED_5        => GPIO_LED_5, --              : out std_logic;
--      GPIO_LED_6        => GPIO_LED_6, --              : out std_logic;
--      GPIO_LED_7        => GPIO_LED_7  --              : out std_logic

      GPIO_LED_0        => GPIO_LED_0, --: out std_logic;
      GPIO_LED_1        => GPIO_LED_1, --: out std_logic;
      GPIO_LED_2        => GPIO_LED_2, --: out std_logic;
      GPIO_LED_3        => GPIO_LED_3, --: out std_logic;
      GPIO_LED_4        => GPIO_LED_4, --: out std_logic;
      GPIO_LED_5        => GPIO_LED_5, --: out std_logic;
      GPIO_LED_6        => GPIO_LED_6, --: out std_logic;
      GPIO_LED_7        => GPIO_LED_7--: out std_logic
      );

     -- Debug LEDs
     --GPIO_LED_0  <= reset_i;
     --GPIO_LED_1  <= tx_ll_src_rdy_n_0_i_reg;
     --GPIO_LED_2  <= tx_ll_dst_rdy_n_0_i;
     --GPIO_LED_3  <= in_fifo_prog_full;
     --GPIO_LED_4  <= out_fifo_prog_full;
     --GPIO_LED_5  <= '0';
     --GPIO_LED_6  <= '0';
     --GPIO_LED_7  <= '0';

    ingoing : process(ll_clk_0_i) 
	 begin
		if(rising_edge(ll_clk_0_i)) then
		  if(reset_i = '1') then
		    rx_ll_data_0_i_reg <= x"00";
  	       rx_ll_dst_rdy_n_0_i_reg <= '1';
		    in_fifo_wr_en <= '0';
 		    input_counter <= 0;

		    in_state <= WAIT_SOF;
		  else
		    rx_ll_data_0_i_reg <= rx_ll_data_0_i;
  	       rx_ll_dst_rdy_n_0_i_reg <= '0';
		    in_fifo_wr_en <= '0';
          case in_state is
		    when WAIT_SOF =>
		      if(rx_ll_sof_n_0_i = '0') then
   		     input_counter <= 0;
			     in_state <= SKIP_HEADER;
			   end if;
          when SKIP_HEADER =>  -- the header is 42 bytes
			   if(input_counter < 41) then 
              input_counter <= input_counter + 1;
            else
              input_counter <= 0;  -- exit on the last byte of the header
              in_state <= RCV_PAYLOAD;
			     in_fifo_wr_en <= '1';
			   end if;
		    when RCV_PAYLOAD =>
            if(input_counter < 999) then
			     in_fifo_wr_en <= '1';
              input_counter  <= input_counter + 1;
		      else
			     in_fifo_wr_en <= '0';
              in_state <= WAIT_SOF;
            end if;
          when OTHERS =>
            in_state <= WAIT_SOF;
          end case;
		  end if;
	   end if;
	 end process ingoing;

    outgoing : process(ll_clk_0_i) 
	 begin
		if(rising_edge(ll_clk_0_i)) then
	     if(reset_i = '1') then
   	    tx_ll_sof_n_0_i_reg <= '1';
   	    tx_ll_eof_n_0_i_reg <= '1';
          tx_ll_src_rdy_n_0_i_reg <= '1';
	 	    tx_ll_data_0_i_reg <= x"00";
	 	    out_fifo_rd_en <= '0';
          output_counter <= 0;
		  
		    out_state <= WAIT_FIFO_FULL;
		  else
  	       tx_ll_sof_n_0_i_reg <= '1';
    	    tx_ll_eof_n_0_i_reg <= '1';
          tx_ll_src_rdy_n_0_i_reg <= '1';
		    tx_ll_data_0_i_reg <= x"ff";
		    out_fifo_rd_en <= '0';
          case out_state is
		    when WAIT_FIFO_FULL =>
		      if out_fifo_prog_full = '1' then
   		     output_counter <= 0;
              udp_header_array_shift_reg <= udp_header_array;
			     out_state <= SEND_HEADER;
			   end if;
          when SEND_HEADER =>
		  	  if(output_counter = 0) then 
			    tx_ll_sof_n_0_i_reg <= '0';
           end if;
		     if(output_counter < 42) then
  			    tx_ll_data_0_i_reg <= udp_header_array_shift_reg(udp_header_array_shift_reg'high downto udp_header_array_shift_reg'high-7);
       
   		    udp_header_array_shift_reg(udp_header_array_shift_reg'high downto 0) <=
               udp_header_array_shift_reg(udp_header_array_shift_reg'high-8 downto 0) & x"00";
           end if;
			  if(output_counter < 41) then
             output_counter <= output_counter + 1;
           else
             output_counter <= 0;
             out_state <= SEND_PAYLOAD;
			    out_fifo_rd_en <= '1';
			  end if;
  		     tx_ll_src_rdy_n_0_i_reg <= '0';
		    when SEND_PAYLOAD =>
           if(output_counter < 1000) then
             tx_ll_data_0_i_reg <= out_fifo_dout;
           end if;
           if(output_counter < 999) then
			    out_fifo_rd_en <= '1';
             output_counter  <= output_counter + 1;
 			    tx_ll_src_rdy_n_0_i_reg <= '0';
		     else
			    out_fifo_rd_en <= '0';
             out_state <= WAIT_FIFO_FULL;
             output_counter <= 0;
  	          tx_ll_eof_n_0_i_reg <= '0';
 			    tx_ll_src_rdy_n_0_i_reg <= '0';
           end if;
--		  when PAUSE =>
--         if(output_counter < 200) then
--           output_counter  <= output_counter + 1;
--         else
--          out_state <= WAIT_FIFO_FULL;
--         end if;
          when OTHERS =>
           out_state <= WAIT_FIFO_FULL;
          end case;
		  end if;
		end if;
	 end process outgoing;
	 
rx_ll_dst_rdy_n_0_i <= rx_ll_dst_rdy_n_0_i_reg;

tx_ll_sof_n_0_i <= tx_ll_sof_n_0_i_reg;
tx_ll_eof_n_0_i <= tx_ll_eof_n_0_i_reg;
tx_ll_src_rdy_n_0_i <= tx_ll_src_rdy_n_0_i_reg;
tx_ll_src_rdy_n_0_i <= tx_ll_src_rdy_n_0_i_reg;
tx_ll_data_0_i <= tx_ll_data_0_i_reg;

in_fifo_ready <= in_fifo_prog_full and not in_fifo_empty; -- in_fifo_prog_full is high for some time after a rst but in_fifo_empty is not

--out_fifo_din_fixed <= x"da";

end Behavioral;

