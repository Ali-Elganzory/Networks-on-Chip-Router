library IEEE;
use IEEE.std_logic_1164.all;

use work.Router_pkg.all;


entity tb_DeMUX is
end;

architecture arch_tb_DeMUX of tb_DeMUX is
	signal En    : std_logic;
	signal Sel   : std_logic_vector(de_mux_sel_c-1 downto 0);
	signal d_in  : std_logic_vector(bus_width-1 downto 0);
 	signal d_out : bus_array (0 to 2**de_mux_sel_c-1);
	signal wreq  : std_logic_vector(0 to 2**de_mux_sel_c-1);

begin
	-- Register instance and mapping.
	de_mux: DeMUX port map (
		En    => En,
		Sel   => Sel,
		d_in  => d_in,
		d_out => d_out,
		wreq  => wreq
	);

	tb: process is
		variable in1 : std_logic_vector(bus_width-1 downto 0) := (0 => '1', others => '0');
		variable in2 : std_logic_vector(bus_width-1 downto 0) := (others => '1');
		variable in3 : std_logic_vector(bus_width-1 downto 0) := (0 => '1', 1 => '1', others => '0');
	begin
		En <= '1';
		
		Sel <= "00";
		d_in <= in1;
		wait for 20 ns;
		assert d_out(0) = in1   report "Wrong output" severity warning;

		Sel <= "01";
		d_in <= in2;
		wait for 20 ns;
		assert d_out(1) = in2   report "Wrong output" severity warning;

		Sel <= "10";
		d_in <= in3;
		wait for 20 ns;
		assert d_out(2) = in3   report "Wrong output" severity warning;

		Sel <= "11";
		d_in <= in1;
		wait for 20 ns;
		assert d_out(3) = in1   report "Wrong output" severity warning;

		wait;
	end process;
end;