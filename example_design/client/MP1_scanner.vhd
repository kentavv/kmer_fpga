----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company:  Iowa State University (Ames)
-- Engineer: Dr. Phillip H. Jones III (phjones@iastate.edu)
-- 
-- Create Date:    10:11:07 09/25/2008 
-- Design Name:    MP1_scnner
-- Module Name:    MP1_scanner - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Scan incoming UDP packtes for strings and count them
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MP1_scanner is
    Port ( rx_ll_clock            : in  STD_LOGIC;
           rx_ll_reset            : in  STD_LOGIC; -- active high
           rx_ll_data_in_scn      : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_ll_sof_in_n_scn     : in  STD_LOGIC;
           rx_ll_eof_in_n_scn     : in  STD_LOGIC;
           rx_ll_src_rdy_in_n_scn : in  STD_LOGIC;
           rx_ll_dst_rdy_in_n_scn : in  STD_LOGIC;
           GPIO_LED_0             : out std_logic;
           GPIO_LED_1             : out std_logic;
           GPIO_LED_2             : out std_logic;
           GPIO_LED_3             : out std_logic;
           GPIO_LED_4             : out std_logic;
           GPIO_LED_5             : out std_logic;
           GPIO_LED_6             : out std_logic;
           GPIO_LED_7             : out std_logic;
           rx_ll_data_in          : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_ll_sof_in_n         : out  STD_LOGIC;
           rx_ll_eof_in_n         : out  STD_LOGIC;
           rx_ll_src_rdy_in_n     : out  STD_LOGIC;
           rx_ll_dst_rdy_in_n     : out  STD_LOGIC);
end MP1_scanner;

architecture Behavioral of MP1_scanner is

-------------------------------------------------------
-- declare constants, types,signals, and components  --
-------------------------------------------------------

-- constants
constant DELAY : integer := 10;  -- number of clock cycles to delay the input
constant DELAY_MINUS_4 : integer := DELAY - 4;
constant DELAY_MINUS_2 : integer := DELAY - 2;
  -- index relative to begining of the ethernet packet header 
constant SOIP_INDEX         : std_logic_vector(15 downto 0) := x"000E";  -- Position of begining of IP header
  -- indexes relative to beginning of the IP packet header
constant SRC_IP_AVL_INDEX   : std_logic_vector(15 downto 0) := x"000F";  -- Position of incoming src IP final byte
constant DST_IP_AVL_INDEX   : std_logic_vector(15 downto 0) := x"0013";  -- Position of incoming dst IP final byte
constant UDP_LEN_AVL_INDEX  : std_logic_vector(15 downto 0) := x"0019";  -- Position of incoming UDP Lenght final byte
constant UDP_CKSUM_AVL_INDEX  : std_logic_vector(15 downto 0) := x"001B";  -- Position of incoming UDP Checksum final byte
constant UDP_DATA_AVL_INDEX : std_logic_vector(15 downto 0) := x"001C";  -- Postion of the start of UDP payload
constant SRC_INSERT_INDEX   : std_logic_vector(15 downto 0) := SRC_IP_AVL_INDEX + DELAY_MINUS_4; 
constant DST_INSERT_INDEX   : std_logic_vector(15 downto 0) := DST_IP_AVL_INDEX + DELAY_MINUS_4;
constant UDP_CKSUM_INSERT_INDEX : std_logic_vector(15 downto 0) := UDP_CKSUM_AVL_INDEX + DELAY_MINUS_2;



-- types
type scan_state_type is (WAIT_SOF, WAIT_SOIP, IP_SRC_AVL, IP_DST_AVL,
                         UDP_LEN_AVL, START_UDP_PAYLOAD, WAIT_EOF);

type corn_state_type is (WAIT_START_SCAN,WAIT_C,WAIT_O,WAIT_R,WAIT_N,WAIT_Ex);

type ece_state_type is (WAIT_START_SCAN,WAIT_E1,WAIT_C,WAIT_E2);

type gataga_state_type is (WAIT_START_SCAN,WAIT_G1,WAIT_A1,WAIT_T,WAIT_A2,WAIT_G2,WAIT_A3);

type data_scn_dly_array is array (DELAY-1 downto 0) of std_logic_vector(7 downto 0);
type sof_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type eof_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type src_rdy_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type dst_rdy_n_scn_dly_array is array (DELAY-1 downto 0) of std_logic;
type ip_src_shift_reg_array is array (3 downto 0) of std_logic_vector(7 downto 0);
type ip_dst_shift_reg_array is array (3 downto 0) of std_logic_vector(7 downto 0);


type corn_count_shift_reg_array is array (1 downto 0) of std_logic_vector(7 downto 0);
type ece_count_shift_reg_array is array (1 downto 0) of std_logic_vector(7 downto 0);
type gataga_count_shift_reg_array is array (1 downto 0) of std_logic_vector(7 downto 0);


-- signals
signal  scan_state       : scan_state_type;
signal  scan_state_next  : scan_state_type;

 -- register entity inputs
signal rx_ll_data_in_scn_reg       : std_logic_vector(7 downto 0);
signal rx_ll_sof_in_n_scn_reg      : std_logic;
signal rx_ll_eof_in_n_scn_reg      : std_logic;
signal rx_ll_src_rdy_in_n_scn_reg  : std_logic;
signal rx_ll_dst_rdy_in_n_scn_reg  : std_logic;

  -- register entity outputs
signal rx_ll_data_in_reg      : std_logic_vector(7 downto 0);
signal rx_ll_sof_in_n_reg     : std_logic;
signal rx_ll_eof_in_n_reg     : std_logic;
signal rx_ll_src_rdy_in_n_reg : std_logic;
signal rx_ll_dst_rdy_in_n_reg : std_logic;  -- reg not used


  -- Delay shift registers
signal data_scn_dly       : data_scn_dly_array; 
signal sof_n_scn_dly      : sof_n_scn_dly_array;
signal eof_n_scn_dly      : eof_n_scn_dly_array;
signal src_rdy_n_scn_dly  : src_rdy_n_scn_dly_array;
signal dst_rdy_n_scn_dly  : dst_rdy_n_scn_dly_array;  -- delay shift reg not used


  -- Shift registers for shifting src and dest IP when swapping IP src/dst address
signal ip_src_shift_reg : ip_src_shift_reg_array;
signal ip_dst_shift_reg : ip_dst_shift_reg_array;


signal corn_count_shift_reg : corn_count_shift_reg_array;
signal ece_count_shift_reg : ece_count_shift_reg_array;
signal gataga_count_shift_reg : gataga_count_shift_reg_array;


signal eth_index_reg        : std_logic_vector(15 downto 0);  -- Store postion within the ethernet packet
signal ip_index_reg         : std_logic_vector(15 downto 0);  -- Store postion within the IP packet
signal udp_payload_index    : std_logic_vector(15 downto 0);  -- UDP payload position constant offset from etherent packet position
signal udp_len_reg          : std_logic_vector(15 downto 0);  -- Store UDP length
signal corn_count_insert_pos_reg          : std_logic_vector(15 downto 0);  -- Store where to insert corn count
signal ece_count_insert_pos_reg          : std_logic_vector(15 downto 0);  -- Store where to insert ece count
signal gataga_count_insert_pos_reg          : std_logic_vector(15 downto 0);  -- Store where to insert gataga count
signal ip_src_addr_reg      : std_logic_vector(31 downto 0);  -- Store UDP recieved src address
signal ip_dst_addr_reg      : std_logic_vector(31 downto 0);  -- Store UDP recieved dest address
signal src_insert_shift_reg : std_logic_vector(3 downto 0);   -- Control insertions of swapped src address
signal dst_insert_shift_reg : std_logic_vector(3 downto 0);   -- Control insertion of swaped dst address
signal zero_udp_cksum_insert_shift_reg : std_logic_vector(1 downto 0);  -- Control insertion of 0'ed UDP Checksum

signal corn_count_insert_shift_reg : std_logic_vector(1 downto 0);   -- Control insertions of corn count
signal ece_count_insert_shift_reg : std_logic_vector(1 downto 0);   -- Control insertions of ece count
signal gataga_count_insert_shift_reg : std_logic_vector(1 downto 0);   -- Control insertions of gataga count

signal data_out_sel         : std_logic_vector(7 downto 0);  -- output data: select 
signal rx_ll_data_in_insert : std_logic_vector(7 downto 0);  -- output of output data multiplixing


  -- Flag special events
signal eth_start_flag    : std_logic;
signal eth_end_flag      : std_logic;
signal ld_ip_index_flag  : std_logic;
signal ld_src_ip_flag    : std_logic;
signal ld_dst_ip_flag    : std_logic;
signal ld_udp_len_flag   : std_logic;
signal start_scan_flag   : std_logic;
signal wr_src_IP_flag    : std_logic;   -- write new src IP address
signal wr_dst_IP_flag    : std_logic;   -- write new dest IP address
signal wr_zero_udp_cksum : std_logic;   -- write zero'ed out UDP checksum

signal wr_corn_count_flag    : std_logic;   -- write corn count
signal wr_ece_count_flag     : std_logic;   -- write ece count
signal wr_gataga_count_flag  : std_logic;   -- write gataga count


  -- used to remove invalid data from input processing pipeling, and flow control
signal pause_flag      : std_logic; -- Indicate sender has no valid data or recieve is not ready
                                    -- (pauses scanner, forwards flow control signals to next module)
signal rx_ll_src_rdy_in_n_mux : std_logic;       
signal eof_pend_reg           : std_logic;  -- indicate the eof of the most recent packet could still be in the pipeline
signal packet_done_reg        : std_logic;  -- indicate done processing the current packet


-- CORN! search signals

signal  corn_state       : corn_state_type;
signal  corn_state_next  : corn_state_type;
signal  corn_state_standby : std_logic;
signal  corn_state_standby_next : std_logic;

signal corn_flag         : std_logic;
signal corn_flag_LED_reg : std_logic;
signal corn_count_reg    : std_logic_vector(15 downto 0);  -- Store corn count

-- ECE search signals

signal  ece_state       : ece_state_type;
signal  ece_state_next  : ece_state_type;
signal  ece_state_standby : std_logic;
signal  ece_state_standby_next : std_logic;

signal ece_flag         : std_logic;
signal ece_flag_LED_reg : std_logic;
signal ece_count_reg    : std_logic_vector(15 downto 0);  -- Store ece count

-- GATAGA search signals

signal  gataga_state       : gataga_state_type;
signal  gataga_state_next  : gataga_state_type;
signal  gataga_state_standby : std_logic;
signal  gataga_state_standby_next : std_logic;

signal gataga_flag         : std_logic;
signal gataga_flag_LED_reg : std_logic;
signal gataga_count_reg    : std_logic_vector(15 downto 0);  -- Store gataga count

constant udp_header_array :  std_logic_vector(335 downto 0) := x"001b21233354aabbccddee00080045000404000040004011b387c0a8010cc0a80105ae22ae2203f00000";
signal udp_header_array_shift_reg : std_logic_vector(335 downto 0);
 

-- components
  -- None


begin



-- register inputs
Reg_Inputs: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then  -- active high
      rx_ll_data_in_scn_reg      <= x"CC";  --(others => '0');
      rx_ll_sof_in_n_scn_reg     <= '1'; -- recieved sof (active low)
      rx_ll_eof_in_n_scn_reg     <= '1'; -- recived eof (active low) 
      rx_ll_src_rdy_in_n_scn_reg <= '1'; -- src does not have valid data (active low)
      rx_ll_dst_rdy_in_n_scn_reg <= '1'; -- dst not ready (active low)
    else      
      rx_ll_data_in_scn_reg      <= rx_ll_data_in_scn;
      rx_ll_sof_in_n_scn_reg     <= rx_ll_sof_in_n_scn;
      rx_ll_eof_in_n_scn_reg     <= rx_ll_eof_in_n_scn;
      rx_ll_src_rdy_in_n_scn_reg <= rx_ll_src_rdy_in_n_scn; -- src does not have valid data
      rx_ll_dst_rdy_in_n_scn_reg <= rx_ll_dst_rdy_in_n_scn; -- dst not ready
    end if;
  end if;

end process Reg_Inputs;



---------------------------------------------------
--       Begin: Flag Packet Events                 --
---------------------------------------------------  

-- UpdateNxtSt_pkt
UpdateNxtSt_pkt: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
  
    if(rx_ll_reset = '1') then
      scan_state <= WAIT_SOF;
    else
      if(pause_flag = '0') then -- active high
        scan_state <= scan_state_next;
      end if;
    end if;
	 
  end if;

end process UpdateNxtSt_pkt;



-- Comp_Next_State
Comp_Nxt_ST_pkt: process(scan_state, eth_index_reg, ip_index_reg,
                         rx_ll_sof_in_n_scn_reg, rx_ll_eof_in_n_scn_reg)
begin

  -- defaults
  scan_state_next  <= scan_state;
  eth_start_flag   <= '0';
  eth_end_flag     <= '0';
  ld_ip_index_flag <= '0';
  ld_src_ip_flag   <= '0';
  ld_dst_ip_flag   <= '0';
  ld_udp_len_flag  <= '0';
  start_scan_flag  <= '0';


  case scan_state is
  
  when WAIT_SOF =>  -- wait for an ethernet packet to arrive

    if(rx_ll_sof_in_n_scn_reg = '0') then  -- active low
      eth_start_flag <= '1';
      scan_state_next <= WAIT_SOIP;
    end if;

  when WAIT_SOIP =>  -- Wait for the start of the IP header

    if(eth_index_reg = SOIP_INDEX) then
      ld_ip_index_flag <= '1';
      scan_state_next <= IP_SRC_AVL;
    end if;
           
  when IP_SRC_AVL =>

    if(ip_index_reg = SRC_IP_AVL_INDEX) then
      ld_src_ip_flag <= '1';
      scan_state_next <= IP_DST_AVL;
    end if;

  when IP_DST_AVL =>

    if(ip_index_reg = DST_IP_AVL_INDEX) then
      ld_dst_ip_flag <= '1';
      scan_state_next <= UDP_LEN_AVL;
    end if;

  when UDP_LEN_AVL =>

    if(ip_index_reg = UDP_LEN_AVL_INDEX) then
      ld_udp_len_flag <= '1';
      scan_state_next <= START_UDP_PAYLOAD;
    end if;

  when START_UDP_PAYLOAD =>

    if(ip_index_reg = UDP_DATA_AVL_INDEX) then
      start_scan_flag <= '1';
      scan_state_next <= WAIT_EOF;
    end if;

  when WAIT_EOF => -- Wait for the end of the frame
  
    if(rx_ll_eof_in_n_scn_reg = '0') then  -- active low
      eth_end_flag <= '1';
      scan_state_next <= WAIT_SOF;
    end if;

  when OTHERS =>
    scan_state_next <= WAIT_SOF;   
  end case;
	
end process Comp_Nxt_ST_pkt;


---------------------------------------------------
--       End: Flag Packet Events                 --
---------------------------------------------------





-- Register and Counter Management
Reg_Cnt_Mgr: process(rx_ll_clock)
begin

  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then -- active high   

      -- Initialize shift registers
      -- (Note: this is a good use for varibles, and loops)
      for array_index in data_scn_dly'range loop
        data_scn_dly(array_index)      <= x"AA"; --(others => '0');
        sof_n_scn_dly(array_index)     <= '1'; -- active low
        eof_n_scn_dly(array_index)     <= '1'; -- active low
        src_rdy_n_scn_dly(array_index) <= '1'; -- active low
      end loop;

      for array_index in ip_src_shift_reg'range loop      
        ip_src_shift_reg(array_index) <= (others => '0');
        ip_dst_shift_reg(array_index) <= (others => '0');
      end loop;

      for array_index in corn_count_shift_reg'range loop      
        corn_count_shift_reg(array_index) <= (others => '0');
        ece_count_shift_reg(array_index) <= (others => '0');
        gataga_count_shift_reg(array_index) <= (others => '0');
      end loop;

      udp_len_reg           <= (others => '1');  -- Lenth of the UDP packect
      corn_count_insert_pos_reg           <= (others => '1');  -- Where to insert count
      ece_count_insert_pos_reg           <= (others => '1');  -- Where to insert count
      gataga_count_insert_pos_reg           <= (others => '1');  -- Where to insert count
      eth_index_reg         <= (others => '0');  -- Position within the ehternet packet
      ip_index_reg          <= (others => '0');  -- Position within the IP packet
      ip_src_addr_reg       <= (others => '0');  -- IP src address
      ip_dst_addr_reg       <= (others => '0');  -- IP dst address
      src_insert_shift_reg  <= (others => '0');  -- control spicing src address into output stream
      dst_insert_shift_reg  <= (others => '0');
      zero_udp_cksum_insert_shift_reg <= (others => '0'); -- control writing 0'ed UDP checksum into output stream 
      
		corn_count_insert_shift_reg  <= (others => '0');  -- control splicing counts into output stream
		ece_count_insert_shift_reg  <= (others => '0');  -- control splicing counts into output stream
		gataga_count_insert_shift_reg  <= (others => '0');  -- control splicing counts into output stream

      packet_done_reg       <= '1';
      eof_pend_reg          <= '0';
		
      
    else

      if(pause_flag = '0')  then -- active high

        
        -- delay all registered input by 10 clock cycles  
        data_scn_dly(data_scn_dly'high downto 0) <= 
          data_scn_dly(data_scn_dly'high-1 downto 0) & rx_ll_data_in_scn_reg;
	 
        sof_n_scn_dly(sof_n_scn_dly'high downto 0) <= 
          sof_n_scn_dly(sof_n_scn_dly'high-1 downto 0) & rx_ll_sof_in_n_scn_reg;
	 
        eof_n_scn_dly(eof_n_scn_dly'high downto 0) <= 
          eof_n_scn_dly(eof_n_scn_dly'high-1 downto 0) & rx_ll_eof_in_n_scn_reg;

        src_rdy_n_scn_dly(src_rdy_n_scn_dly'high downto 0) <= 
          src_rdy_n_scn_dly(src_rdy_n_scn_dly'high-1 downto 0) & rx_ll_src_rdy_in_n_scn_reg;

      
        -- store UDP payload length
		  if(ld_udp_len_flag = '1') then
          udp_len_reg <= data_scn_dly(0) & rx_ll_data_in_scn_reg;
			 corn_count_insert_pos_reg <= (data_scn_dly(0) & rx_ll_data_in_scn_reg)+13+DELAY;
			 ece_count_insert_pos_reg <= (data_scn_dly(0) & rx_ll_data_in_scn_reg)+15+DELAY;
			 gataga_count_insert_pos_reg <= (data_scn_dly(0) & rx_ll_data_in_scn_reg)+17+DELAY;
        elsif (rx_ll_eof_in_n_reg = '0') then  -- active low
          udp_len_reg <= (others => '1'); -- reset udp_length to 0xFFFF 
			 corn_count_insert_pos_reg <= (others => '1');
			 ece_count_insert_pos_reg <= (others => '1');
			 gataga_count_insert_pos_reg <= (others => '1');
        else
          udp_len_reg <= udp_len_reg;
			 corn_count_insert_pos_reg <= corn_count_insert_pos_reg;
			 ece_count_insert_pos_reg <= ece_count_insert_pos_reg;
			 gataga_count_insert_pos_reg <= gataga_count_insert_pos_reg;
        end if;

        -- Track the postion within the ethernet packet
        if(eth_start_flag = '1') then
          eth_index_reg <= x"0001"; --set index postion to 1
        elsif (eth_end_flag = '1') then
          eth_index_reg <= (others => '0'); --set index position to 0
        else
          eth_index_reg <= eth_index_reg + 1; -- Increse payload position indicator 
        end if;

        -- Track the postion within the IP packet
        if(ld_ip_index_flag = '1') then
          ip_index_reg <= x"0001";  --set index position to 1
          packet_done_reg <= '0';
        elsif (packet_done_reg = '0') then  -- while IP packet is being processed
          ip_index_reg <= ip_index_reg + 1; -- increse payload position indicator
        else
          ip_index_reg <= ip_index_reg;          
        end if;

        if(rx_ll_eof_in_n_reg = '0') then
          packet_done_reg <= '1'; -- indicate finished processing the current IP packet
        end if;
             

        -- Load IP src address from input stream into a register
        if(ld_src_ip_flag = '1') then
          ip_src_addr_reg <= data_scn_dly(2) & data_scn_dly(1) & data_scn_dly(0) & rx_ll_data_in_scn_reg;
        end if;

        -- Load IP dst address from input stream into a register
        if(ld_dst_ip_flag = '1') then
          ip_dst_addr_reg <= data_scn_dly(2) & data_scn_dly(1) & data_scn_dly(0) & rx_ll_data_in_scn_reg;
        end if;

        -- Indicate time to write new src IP address into output stream
	-- and shift out new src IP address (i.e orginail dest IP address)
        if(SRC_INSERT_INDEX = ip_index_reg) then
          src_insert_shift_reg <= "1111";
          ip_src_shift_reg(3) <= ip_dst_addr_reg(31 downto 24);
          ip_src_shift_reg(2) <= ip_dst_addr_reg(23 downto 16);
          ip_src_shift_reg(1) <= ip_dst_addr_reg(15 downto 8);
          ip_src_shift_reg(0) <= ip_dst_addr_reg(7 downto 0);
        else
          src_insert_shift_reg(src_insert_shift_reg'high downto 0) <=
            src_insert_shift_reg(src_insert_shift_reg'high-1 downto 0) & '0';
		  
          ip_src_shift_reg(ip_src_shift_reg'high downto 0) <= 
            ip_src_shift_reg(ip_src_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write dst IP address into output stream
        if(DST_INSERT_INDEX = ip_index_reg) then
          dst_insert_shift_reg <= "1111";
          ip_dst_shift_reg(3) <= ip_src_addr_reg(31 downto 24);
          ip_dst_shift_reg(2) <= ip_src_addr_reg(23 downto 16);
          ip_dst_shift_reg(1) <= ip_src_addr_reg(15 downto 8);
          ip_dst_shift_reg(0) <= ip_src_addr_reg(7 downto 0);
        else
          dst_insert_shift_reg(dst_insert_shift_reg'high downto 0) <=
            dst_insert_shift_reg(dst_insert_shift_reg'high-1 downto 0) & '0';
		  
          ip_dst_shift_reg(ip_dst_shift_reg'high downto 0) <= 
            ip_dst_shift_reg(ip_dst_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write zeroed out UDP checksum into output stream
        if(UDP_CKSUM_INSERT_INDEX = ip_index_reg) then
          zero_udp_cksum_insert_shift_reg <= "11";
        else
          zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high downto 0) <=
            zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high-1 downto 0) & '0';
        end if;	 

        -- Indicate time to write corn count into output stream
 --       if(udp_len_reg-3*2+DELAY = ip_index_reg) the
        --if(udp_len_ref < x"ffff" ) then --and udp_len_reg+13+DELAY = ip_index_reg) then
--        if(udp_len_reg+17+DELAY = ip_index_reg) then
        if(corn_count_insert_pos_reg = ip_index_reg) then
          corn_count_insert_shift_reg <= "11";
--			 corn_count_reg <= udp_len_reg-3*2+DELAY;
--			 corn_count_reg <= udp_len_reg;
          corn_count_shift_reg(1) <= corn_count_reg(15 downto 8);
          corn_count_shift_reg(0) <= corn_count_reg(7 downto 0);
        else
          corn_count_insert_shift_reg(corn_count_insert_shift_reg'high downto 0) <=
            corn_count_insert_shift_reg(corn_count_insert_shift_reg'high-1 downto 0) & '0';

          corn_count_shift_reg(corn_count_shift_reg'high downto 0) <= 
            corn_count_shift_reg(corn_count_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write ece count into output stream
        if(ece_count_insert_pos_reg = ip_index_reg) then
--        if(udp_len_ref /= x"ffff" and udp_len_reg+15+DELAY = ip_index_reg) then
          ece_count_insert_shift_reg <= "11";
          ece_count_shift_reg(1) <= ece_count_reg(15 downto 8);
          ece_count_shift_reg(0) <= ece_count_reg(7 downto 0);
        else
          ece_count_insert_shift_reg(ece_count_insert_shift_reg'high downto 0) <=
            ece_count_insert_shift_reg(ece_count_insert_shift_reg'high-1 downto 0) & '0';

          ece_count_shift_reg(ece_count_shift_reg'high downto 0) <= 
            ece_count_shift_reg(ece_count_shift_reg'high-1 downto 0) & x"00";
        end if;	 

        -- Indicate time to write gataga count into output stream
        if(gataga_count_insert_pos_reg = ip_index_reg) then
--        if(udp_len_ref /= x"ffff" and udp_len_reg+17+DELAY = ip_index_reg) then
          gataga_count_insert_shift_reg <= "11";
          gataga_count_shift_reg(1) <= gataga_count_reg(15 downto 8);
          gataga_count_shift_reg(0) <= gataga_count_reg(7 downto 0);
        else
          gataga_count_insert_shift_reg(gataga_count_insert_shift_reg'high downto 0) <=
            gataga_count_insert_shift_reg(gataga_count_insert_shift_reg'high-1 downto 0) & '0';

          gataga_count_shift_reg(gataga_count_shift_reg'high downto 0) <= 
            gataga_count_shift_reg(gataga_count_shift_reg'high-1 downto 0) & x"00";
        end if;	 
        
        -- Indicate an eof has been detected, and the next sof has not arrived
	if(eth_end_flag = '1') then
          eof_pend_reg <= '1';
        elsif (eth_start_flag = '1') then
          eof_pend_reg <= '0'; 
        else
          eof_pend_reg <= eof_pend_reg;
        end if;
      
      end if; -- end pause
    end if; -- end reset
  end if; -- end clk'event
end process Reg_Cnt_Mgr;



------------------------------------------------------------
------------------------------------------------------------
-- Name: Sel_output                                       --
-- Description:  Choose between the following sources     -- 
--                                                        --
--  1. Src IP                                             --
--  2. Dest IP                                            --
--  4. Zero out UDP checksum                              --
--  8. ??                                                 --
--  others. Input stream                                  --
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Sel_output: process(data_out_sel, 
                    ip_src_shift_reg(ip_src_shift_reg'high),
                    ip_dst_shift_reg(ip_dst_shift_reg'high), 
						  corn_count_shift_reg(corn_count_shift_reg'high), 
						  ece_count_shift_reg(ece_count_shift_reg'high), 
						  gataga_count_shift_reg(gataga_count_shift_reg'high), 
						  data_scn_dly(data_scn_dly'high) )
begin

  case data_out_sel is
  when x"01" =>
    rx_ll_data_in_insert <= ip_src_shift_reg(ip_src_shift_reg'high); -- insert new src IP to output
  when x"02" =>
    rx_ll_data_in_insert <= ip_dst_shift_reg(ip_dst_shift_reg'high); -- insert new dest IP to output
  when x"04" =>
    rx_ll_data_in_insert <= x"00"; -- Zero out UDP checksum, tells OS to ignore checksum
  when x"08" =>
    rx_ll_data_in_insert <= corn_count_shift_reg(corn_count_shift_reg'high); -- insert corn count
--    rx_ll_data_in_insert <= x"f6"; -- insert corn count
  when x"10" =>
    rx_ll_data_in_insert <= ece_count_shift_reg(ece_count_shift_reg'high); -- insert ece count
  when x"20" =>
    rx_ll_data_in_insert <= gataga_count_shift_reg(gataga_count_shift_reg'high); -- insert gataga count
  when OTHERS =>	
    rx_ll_data_in_insert <= data_scn_dly(data_scn_dly'high); -- unmodified input data    
  end case;
	
end process Sel_output;

wr_src_IP_flag <= src_insert_shift_reg(src_insert_shift_reg'high);
wr_dst_IP_flag <= dst_insert_shift_reg(dst_insert_shift_reg'high);
wr_zero_udp_cksum <= zero_udp_cksum_insert_shift_reg(zero_udp_cksum_insert_shift_reg'high);
wr_corn_count_flag <= corn_count_insert_shift_reg(corn_count_insert_shift_reg'high);
wr_ece_count_flag <= ece_count_insert_shift_reg(ece_count_insert_shift_reg'high);
wr_gataga_count_flag <= gataga_count_insert_shift_reg(gataga_count_insert_shift_reg'high);
data_out_sel <= "00" & wr_gataga_count_flag & wr_ece_count_flag & wr_corn_count_flag & wr_zero_udp_cksum & wr_dst_IP_flag & wr_src_IP_flag;     -- output data select 



------------------------------------------------------------
------------------------------------------------------------
-- Name: Reg_Outputs                                      --
-- Description:  Register the outputs of this entity      -- 
--                                                        --
------------------------------------------------------------
------------------------------------------------------------
Reg_Outputs: process(rx_ll_clock)
begin
  if(rx_ll_clock'event and rx_ll_clock = '1') then
    if(rx_ll_reset = '1') then -- active high
      rx_ll_data_in_reg        <= (others => '0');
      rx_ll_sof_in_n_reg       <= '1';  -- active low
      rx_ll_eof_in_n_reg       <= '1';  -- active low
      rx_ll_src_rdy_in_n_reg   <= '1';  -- active low
    else
      if(pause_flag = '0') then -- pause output if flow control active
        rx_ll_data_in_reg        <= rx_ll_data_in_insert;
        rx_ll_sof_in_n_reg       <= sof_n_scn_dly(sof_n_scn_dly'high);
        rx_ll_eof_in_n_reg       <= eof_n_scn_dly(eof_n_scn_dly'high);
        rx_ll_src_rdy_in_n_reg   <= src_rdy_n_scn_dly(src_rdy_n_scn_dly'high);
      end if;
    end if;
  end if;
end process Reg_Outputs;


-- Non-process Combinational assignments

  -- start flow control, and invaild data bubble removal
pause_flag <= '1' when (rx_ll_dst_rdy_in_n_scn_reg = '1') or
                       ((rx_ll_src_rdy_in_n_scn_reg = '1') and (eof_pend_reg = '0'))   -- pause active high,
                  else
              '0';


rx_ll_src_rdy_in_n_mux <=  '1' when ((rx_ll_src_rdy_in_n_scn_reg = '1') and (eof_pend_reg = '0')) 
                               else
                          rx_ll_src_rdy_in_n_reg;  -- src ready from delay reg 

  -- end flow control, and invalid data bubble removal


udp_payload_index <= ip_index_reg - x"01C";  -- Position in UDP payload constant offset
                                             -- from position in IP packet


  -- Assign output ports
GPIO_LED_0           <= corn_count_reg(0);
GPIO_LED_1           <= corn_count_reg(1);
GPIO_LED_2           <= ece_count_reg(0);
GPIO_LED_3           <= ece_count_reg(1);
GPIO_LED_4           <= ece_count_reg(2);
GPIO_LED_5           <= gataga_count_reg(0);
GPIO_LED_6           <= gataga_count_reg(1);
GPIO_LED_7           <= gataga_count_reg(2);
rx_ll_data_in        <= rx_ll_data_in_reg;
rx_ll_sof_in_n       <= rx_ll_sof_in_n_reg;
rx_ll_eof_in_n       <= rx_ll_eof_in_n_reg;
rx_ll_src_rdy_in_n   <= rx_ll_src_rdy_in_n_mux;     -- mux between direct input, and dly shift register  
rx_ll_dst_rdy_in_n   <= rx_ll_dst_rdy_in_n_scn_reg; -- pass flow control signal directly from register input


end Behavioral;

