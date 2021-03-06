library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package pkg is
  type DataInArray is array (3 downto 0) of std_logic_vector(63 downto 0);
  type DataOutArray is array (3 downto 0) of std_logic_vector(63 downto 0);
  type PushArray is array (3 downto 0) of std_logic;
  type PopArray is array (3 downto 0) of std_logic;
  type NoPopArray is array (3 downto 0) of std_logic;
  type RoutingTableArray is array (3 downto 0) of std_logic_vector(63 downto 0);
  type BufferArray is array (3 downto 0) of std_logic_vector(3 downto 0);
  type AddrArray is array (7 downto 0) of std_logic_vector(7 downto 0);
  type WRArray is array (7 downto 0) of std_logic;
  type IOArray is array (3 downto 0) of std_logic_vector(63 downto 0);
end package;

package body pkg is
end package body;
