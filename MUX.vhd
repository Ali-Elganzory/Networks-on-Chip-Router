library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.bus_array;


entity MUX is
	generic (
			de_mux_sel_c : integer := 2;
			bus_width    : integer := 8
		);

	port(
			En    : in std_logic;
			Sel   : in std_logic_vector(de_mux_sel_c-1 downto 0);
 			d_in  : in bus_array (0 to 2**de_mux_sel_c-1);
			d_out : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_MUX of MUX is

begin
	process (Sel, d_in) is
	begin
		if En = '1' then
			d_out <= d_in(to_integer(unsigned(Sel)));
		end if;
	end process;
end;
