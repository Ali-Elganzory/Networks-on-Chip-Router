library IEEE;
use IEEE.std_logic_1164.all;


entity Reg is
	generic(
			bus_width : integer := 8
		);

	port(
			Reset    : in std_logic;
			Clock_En : in std_logic;
			Clock    : in std_logic;
			Data_in  : in std_logic_vector(bus_width-1 downto 0);
			Data_out : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Reg of Reg is

begin
	process (Reset, Clock) is
	begin
		if Reset = '1' then
			Data_out <= (others => '0');
		elsif Clock_En = '1' and rising_edge(Clock) then
			Data_out <= Data_in;
		end if;
	end process;
end;