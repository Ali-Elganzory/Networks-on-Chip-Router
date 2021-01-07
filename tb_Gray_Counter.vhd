library IEEE;
use IEEE.std_logic_1164.all;

use work.Router_pkg.all;


entity tb_Gray_Counter is
end;

architecture arch_tb_Gray_Counter of tb_Gray_Counter is
	signal Reset     : std_logic;
	signal En        : std_logic;
	signal Clock     : std_logic := '0';
	signal Count_out : std_logic_vector(counter_width-1 downto 0);

begin
	-- Gray Counter instance and mapping.
	counter: Gray_Counter port map (
		Reset     => Reset,
		En        => En,
		Clock     => Clock,
		Count_out => Count_out
	);

	clk: process is
	begin
		wait for 10 ns;
		Clock <= not Clock;
	end process;

	tb: process is
	begin
		Reset <= '0';
		wait for 10 ns;
		Reset <= '1';
		wait for 10 ns;
		Reset <= '0';
		assert Count_out = "00" report "Counter didn't reset" severity warning;
		
		En <= '0';
		wait for 40 ns;
		assert Count_out = "00" report "Counter isn't disabled" severity warning;

		En <= '1';
		wait for 20 ns;
		assert Count_out = "01" report "Counter doesn't work" severity warning;
		wait for 20 ns;
		assert Count_out = "11" report "Counter doesn't work" severity warning;
		wait for 20 ns;
		assert Count_out = "10" report "Counter doesn't work" severity warning;

		wait;
	end process;
end;