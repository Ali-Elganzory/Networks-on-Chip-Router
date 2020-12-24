library IEEE;
use IEEE.std_logic_1164.all;

use work.Router_pkg.all;


entity tb_MUX is
end;

architecture arch_tb_MUX of tb_MUX is
	signal En    : std_logic;
	signal Sel   : std_logic_vector(de_mux_sel_c-1 downto 0);
	signal d_out : std_logic_vector(bus_width-1 downto 0);
 	signal d_in  : bus_array (0 to 2**de_mux_sel_c-1);

begin
	-- Register instance and mapping.
	mux_t: MUX port map (
		En    => En,
		Sel   => Sel,
		d_in  => d_in,
		d_out => d_out
	);

	tb: process is
	begin
		En <= '1';
		d_in(0) <= (0 => '0', 1 => '0', others => '1');
		d_in(1) <= (0 => '1', 1 => '1', others => '0');
		d_in(2) <= (0 => '1', 1 => '1', others => '0');
		d_in(3) <= (others => '1');
		
		Sel <= (0 => '1', others => '0');
		wait for 20 ns;

		Sel <= (1 => '1', others => '0');
		wait for 20 ns;

		Sel <= (others => '0');
		wait for 20 ns;

		Sel <= (others => '1');
		wait for 20 ns;

		wait for 60 ns;

		wait;
	end process;
end;
