library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 


entity Round_Robin_Scheduler is
	generic (
			bus_width : integer := 8
		);
	
	port (
			clock : in std_logic;
			din1  : in std_logic_vector(bus_width-1 downto 0);
			din2  : in std_logic_vector(bus_width-1 downto 0);
			din3  : in std_logic_vector(bus_width-1 downto 0);
			din4  : in std_logic_vector(bus_width-1 downto 0);
			dout  : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Round_Robin_Scheduler of Round_Robin_Scheduler is
	type state is (a, b, c, d);

	signal current_state : state;
	signal next_state    : state;

begin
	cs: process (clock) is
	begin
		if rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	ns: process (current_state) is
	begin
		case current_state is
			when a => 
				next_state <= b;
			when b =>
				next_state <= c;
			when c =>
				next_state <= d;
			when d =>
				next_state <= a;
			when others => 
				next_state <= a;
		end case;
	end process;

	op: process (current_state) is
	begin
		case current_state is
			when a => 
				dout <= din1;
			when b =>
				dout <= din2;
			when c =>
				dout <= din3;
			when d =>
				dout <= din4;
		end case;
	end process;
end;