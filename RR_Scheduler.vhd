library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.bus_width;

entity RR_Scheduler is
	port (
			din1, din2, din3, din4 : in std_logic_vector(bus_width-1 downto 0);
			reset : in std_logic;
			clock : in std_logic;
			dout  : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_RR_Scheduler of RR_Scheduler is
	type state is (port1, port2, port3, port4);

	signal current_state, next_state : state;

begin
	cs: process (reset, clock) is
	begin
		if reset = '1' then
			current_state <= port1;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	ns: process (current_state) is
	begin
		case current_state is
		when port1 =>
			next_state <= port2;
		when port2 =>
			next_state <= port3;
		when port3 =>
			next_state <= port4;
		when others =>
			next_state <= port1;
		end case;
	end process;

	-- the output is independent on the input
	-- din1, din2, din3, din4 are added to synthesis a combinational circuit
	op: process (current_state, din1, din2, din3, din4) is
	begin
		case current_state is
		when port1 =>
			dout <= din1;
		when port2 =>
			dout <= din2;
		when port3 =>
			dout <= din3;
		when others =>
			dout <= din4;
		end case;
	end process;
end;
