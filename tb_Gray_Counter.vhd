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
		Reset <= '1';
		wait for 20 ns;
		Reset <= '0';
		
		En <= '0';
		wait for 40 ns;

		En <= '1';
		wait for 100 ns;

		wait;
	end process;
end;