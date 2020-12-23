library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.all;


entity tb_Gray_to_Binary is
end;

architecture arch_tb_Gray_to_Binary of tb_Gray_to_Binary is
	signal gray_in : std_logic_vector(bus_width-1 downto 0);
	signal bin_out : std_logic_vector(bus_width-1 downto 0);

begin
	-- Register instance and mapping.
	converter: Gray_to_Binary port map (
		gray_in => gray_in,
		bin_out => bin_out
	);

	tb: process is
	begin
		for i in 0 to 2**bus_width loop
			gray_in <= std_logic_vector(to_unsigned(i, gray_in'length));
			wait for 20 ns;
		end loop;

		wait;
	end process;
end;
