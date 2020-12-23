library IEEE;
use IEEE.std_logic_1164.all;


entity Gray_to_Binary is
	generic (
			bus_width : integer := 4
		);

	port (
			gray_in : in std_logic_vector(bus_width-1 downto 0);
			bin_out : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Gray_to_Binary of Gray_to_Binary is
	signal bin_signals : std_logic_vector(bus_width-1 downto 0);

begin
	bin_signals(bus_width-1) <= gray_in(bus_width-1);

	convertor: for i in bus_width-2 downto 0 generate
		bin_signals(i) <= gray_in(i) xor bin_signals(i+1);
	end generate;

	bin_out <= bin_signals;
end;
