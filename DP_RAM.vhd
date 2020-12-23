library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.bus_array;


entity DP_RAM is
	generic (
			bus_width  : integer := 8;
			addr_width : integer := 3
		);

	port (
			CLKA  : in std_logic;
			CLKB  : in std_logic;
			WEA   : in std_logic;
			REA   : in std_logic;
			ADDRA : in std_logic_vector(addr_width-1 downto 0);
			ADDRB : in std_logic_vector(addr_width-1 downto 0);
			d_in  : in std_logic_vector(bus_width-1 downto 0);
			d_out : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_DP_RAM of DP_RAM is
	signal mem : bus_array (0 to 2**addr_width-1);

begin
	w: process (CLKA) is
	begin
		if WEA = '1' and rising_edge(CLKA) then
			mem(to_integer(unsigned(ADDRA))) <= d_in;
		end if;
	end process;

	r: process (CLKB) is
	begin
		if REA = '1' and rising_edge(CLKB) then
			d_out <= mem(to_integer(unsigned(ADDRB)));
		end if;
	end process;
end;