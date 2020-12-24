library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.all;


entity tb_Router is
end;

architecture arch_tb_Router of tb_Router is
	signal rst      : std_logic;
	signal wclock   : std_logic := '1';
	signal rclock   : std_logic := '1';
	signal wr1, wr2, wr3, wr4 			  : std_logic;
	signal rd1, rd2, rd3, rd4 			  : std_logic;
	signal datai1, datai2, datai3, datai4 : std_logic_vector(bus_width-1 downto 0);
	signal datao1, datao2, datao3, datao4 : std_logic_vector(bus_width-1 downto 0);

begin

	-- Router instance and mapping.
	Router_UUT: Router port map (
		rst => rst,
		wclock => wclock,
		rclock => rclock,
		wr1 => wr1, wr2 => wr2, wr3 => wr3, wr4 => wr4,
		rd1 => rd1, rd2 => rd2, rd3 => rd3, rd4 => rd4,
		datai1 => datai1, datai2 => datai2, datai3 => datai3, datai4 => datai4,
		datao1 => datao1, datao2 => datao2, datao3 => datao3, datao4 => datao4
	);

	clk: process is
	begin
		wait for 10 ns;
		wclock <= not wclock;
		rclock <= not rclock;
	end process;

	tb: process is
	begin
	
		wr1    <= '0';
		wr2    <= '0';
		wr3    <= '0';
		wr4    <= '0';
		rst    <= '1';
		wait for 5 ns;
		rst    <= '0';
		wait for 55 ns;

		wr1    <= '1';
		datai1 <= "01100000";
		wait for 20 ns;
		wr1    <= '0';
		wr2    <= '1';
		datai2 <= "11101000";
		wait for 20 ns;
		wr2    <= '0';
		wait for 120 ns;

		wait;

	end process;

end;