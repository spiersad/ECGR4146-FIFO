library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.pkg.all;

entity ROUTER is
  generic (N: integer := 8; -- number of address bits for 2**N address locations
           ADDSKEW: std_logic_vector(7 downto 0) := "00010000";
           M: integer := 64); -- number of data bits to/from FIFO
  port (CLK,RESET: in std_logic;
        DIN: in DataInArray;
        EXPUSH: in PushArray;
        EXPOP: in PopArray;
        DOUT: out DataOutArray);
end entity ROUTER;

architecture behav of router is
  type state is (state0, state1, state2, state3,state4 ,state5 ,state6);
  signal current_state, next_state : state := state0;
  signal INPUSH: PushArray;
  signal INPOP: PopArray;
  signal NOPOP: NoPopArray;
  signal h: std_logic_vector(N-1 downto 0);
  signal WE, f,INIT: std_logic;
  signal BUFF: BufferArray;
  signal TMP: std_logic_vector(63 downto 0);
  signal a, d: IOArray;
  signal b, c: std_logic_vector(63 downto 0);
  signal g: AddrArray;
  signal e: WRArray;
  signal IOSelect: std_logic_vector(1 downto 0);
  signal AddrBit: std_logic;
  component FIFO_LOGIC_MODIFIED is
    generic (N: integer); -- number of address bits
    port (CLK, PUSH, POP, INIT: in std_logic;
          BUFF: out std_logic_vector(3 downto 0);
          ADD: out std_logic_vector(N-1 downto 0);
          FULL, EMPTY, WE, NOPUSH, NOPOP: out std_logic);
  end component FIFO_LOGIC_MODIFIED;
  component RAM is
    generic (K, W: integer); -- number of address and data bits
    port (WR: in std_logic; -- active high write enable
          ADDR: in std_logic_vector (W-1 downto 0); -- RAM address
          DIN: in std_logic_vector (K-1 downto 0); -- write data
          DOUT: out std_logic_vector (K-1 downto 0)); -- read data
  end component RAM;
begin
  OUTFIFO_GEN:
  for I in 3 downto 0 generate
    OUTFIFO: FIFO_LOGIC_MODIFIED generic map (N => N)
      port map(CLK => CLK, PUSH => INPUSH(I), POP => EXPOP(I), INIT => INIT,
               ADD => g(I+4), BUFF => BUFF(I), WE => e(I+4), NOPOP => NOPOP(I));
  end generate;
  INFIFO_GEN:
  for I in 3 downto 0 generate
    INFIFO: FIFO_LOGIC_MODIFIED generic map (N => N)
      port map(CLK => CLK, PUSH => EXPUSH(I), POP => INPOP(I), INIT => INIT,
               ADD => g(I), WE => e(I));
  end generate;
  R: RAM generic map (W => N, K => M)
      port map (DIN => b, ADDR => h, WR => f, DOUT => c);
  
  b <= a(0) when (IOSelect = "00");
  d(0) <= c when (IOSelect = "00");
  b <= a(1) when (IOSelect = "01");
  d(1) <= c when (IOSelect = "01");
  b <= a(2) when (IOSelect = "10");
  d(2) <= c when (IOSelect = "10");
  b <= a(3) when (IOSelect = "11");
  d(3) <= c when (IOSelect = "11");
  f <= e(0) when (IOSelect = "00" and AddrBit = '0');
  h <= g(0) + std_logic_vector(unsigned(ADDSKEW) * 0) when (IOSelect = "00" and AddrBit = '0');
  f <= e(1) when (IOSelect = "01" and AddrBit = '0');
  h <= g(1) + std_logic_vector(unsigned(ADDSKEW) * 1)when (IOSelect = "01" and AddrBit = '0');
  f <= e(2) when (IOSelect = "10" and AddrBit = '0');
  h <= g(2) + std_logic_vector(unsigned(ADDSKEW) * 2)when (IOSelect = "10" and AddrBit = '0');
  f <= e(3) when (IOSelect = "11" and AddrBit = '0');
  h <= g(3) + std_logic_vector(unsigned(ADDSKEW) * 3)when (IOSelect = "11" and AddrBit = '0');
  f <= e(4) when (IOSelect = "00" and AddrBit = '1');
  h <= g(4) + std_logic_vector(unsigned(ADDSKEW) * 4)when (IOSelect = "00" and AddrBit = '1');
  f <= e(5) when (IOSelect = "01" and AddrBit = '1');
  h <= g(5) + std_logic_vector(unsigned(ADDSKEW) * 5)when (IOSelect = "01" and AddrBit = '1');
  f <= e(6) when (IOSelect = "10" and AddrBit = '1');
  h <= g(6) + std_logic_vector(unsigned(ADDSKEW) * 6)when (IOSelect = "10" and AddrBit = '1');
  f <= e(7) when (IOSelect = "11" and AddrBit = '1');
  h <= g(7) + std_logic_vector(unsigned(ADDSKEW) * 7)when (IOSelect = "11" and AddrBit = '1');
  
   process(Clk, Reset)
      variable i : std_logic_vector(1 downto 0);
      
      begin
        if (RESET = '1') then
          current_state <= state0;
           i := "00";
           INIT<= '1';
           IOSelect <= "00";
           AddrBit <= '0';
           INPUSH <= (others => '0');
           INPOP <= (others => '0');
        else
          if (Clk'event and Clk='1') then
            case current_state is
            when state0 =>
             INPOP(to_integer(unsigned(i))) <= '1';
             INPUSH <= (others => '0');
             if(NOPOP(to_integer(unsigned(i))) = '1') then
              next_state <= state1;
             elsif((b(63 downto 48) >= (std_logic_vector(to_unsigned(0,64)))) and (b(63 downto 48) < (std_logic_vector(to_unsigned(21844,64))))) then
              IOSelect <= "00";
              AddrBit <= '1';
              next_state <= state2;
             elsif((b(63 downto 48) >= (std_logic_vector(to_unsigned(21845,64)))) and (b(63 downto 48) < (std_logic_vector(to_unsigned(43690,64))))) then
              IOSelect <= "01";
              AddrBit <= '1';
              next_state <= state3;
             elsif((b(63 downto 48) >= (std_logic_vector(to_unsigned(43691,64)))) and (b(63 downto 48) < (std_logic_vector(to_unsigned(65535,64))))) then
              IOSelect <= "10";
              AddrBit <= '1';
              next_state <= state4;
             --elsif()
             end if;
             
            when state1 =>
              i := i + "01";
              INPOP(to_integer(unsigned(i))) <= '0';
              INPUSH(0) <= '1';
              next_state <= state0;
              AddrBit <= '0';
              IOSelect <= i;
              
            when state2 =>
              i := i + "01";
              INPOP(to_integer(unsigned(i))) <= '0';
              INPUSH(1) <= '1';
              next_state <= state0;
              AddrBit <= '0';
              IOSelect <= i;
              
            when state3 =>
              i := i + "01";
              INPOP(to_integer(unsigned(i))) <= '0';
              INPUSH(1) <= '1';
              next_state <= state0;
              AddrBit <= '0';
              IOSelect <= i;
              
            when others =>
              next_state <= state0;
            end case;
          end if;
        current_state <= next_state;
      end if;
   end process;
end behav;