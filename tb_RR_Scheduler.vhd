library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

use work.Router_pkg.all;


entity tb_RR_Scheduler is
end;

architecture arch_tb_RR_Scheduler of tb_RR_Scheduler is
	signal din1, din2, din3, din4 : std_logic_vector(bus_width-1 downto 0);
	signal reset : std_logic;
	signal clock : std_logic := '0';
	signal dout  : std_logic_vector(bus_width-1 downto 0);

begin
	clk: process is
	begin
		wait for 10 ns;
		clock <= not clock;
	end process;

	rr_sched: RR_Scheduler port map (
		din1 => din1, din2 => din2, din3 => din3, din4 => din4,
		reset => reset,
		clock => clock,
		dout  => dout
	);

	tb: process is
	begin

		din1 <= "01100000";
		din2 <= "01110000";
		din3 <= "01111000";
		din4 <= "01111100";

		reset <= '1';
		wait for 20 ns;
		reset <= '0';
		wait for 20 ns;
		assert dout = din1 report "Wrong port for 1st state" severity warning;
		wait for 20 ns;
		assert dout = din2 report "Wrong port for 1st state" severity warning;
		wait for 20 ns;
		assert dout = din3 report "Wrong port for 1st state" severity warning;
		wait for 20 ns;
		assert dout = din4 report "Wrong port for 1st state" severity warning;
		wait for 20 ns;

		wait;
	end process;
end;
