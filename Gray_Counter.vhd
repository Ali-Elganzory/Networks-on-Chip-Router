library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.bus_array;


entity Gray_Counter is
	generic (
			counter_width : integer := 4
		);

	port (
			Reset     : in std_logic;
			En        : in std_logic;
			Clock     : in std_logic;
			Count_out : out std_logic_vector(counter_width-1 downto 0)
		);
end;

architecture arch_Gray_Counter of Gray_Counter is
	signal current_state, next_state, hold, next_hold: std_logic_vector (counter_width-1 downto 0);

begin
	process (Reset, Clock) is
	begin
		if Reset = '1' then
			current_state <= (others => '0');
		elsif En = '1' and rising_edge(Clock) then
			current_state <= next_state;
		end if;
	end process;

	hold <= current_state xor ('0' & hold(counter_width-1 downto 1));
 	next_hold <= std_logic_vector(unsigned(hold) + 1);
 	next_state <= next_hold xor ('0' & next_hold(counter_width-1 downto 1)); 
	Count_out <= current_state;
end;
