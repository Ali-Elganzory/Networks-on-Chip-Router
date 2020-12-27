library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.bus_array;


entity DeMUX is
	generic (
			de_mux_sel_c : integer := 2;
			bus_width    : integer := 8
		);

	port(
			En    : in std_logic;
			Sel   : in std_logic_vector(de_mux_sel_c-1 downto 0);
			d_in  : in std_logic_vector(bus_width-1 downto 0);
 			d_out : out bus_array (0 to 2**de_mux_sel_c-1);
			wreq  : out std_logic_vector(0 to 2**de_mux_sel_c-1)
		);
end;

architecture arch_DeMUX of DeMUX is

begin
	process (Sel, d_in) is
		variable new_wreq : std_logic_vector(0 to 3);
	begin
		if En = '1' then
			d_out(to_integer(unsigned(Sel))) <= d_in;
			new_wreq := (others => '0');
			new_wreq(to_integer(unsigned(Sel))) := '1';
			wreq <= new_wreq;
		end if;
	end process;
end;
