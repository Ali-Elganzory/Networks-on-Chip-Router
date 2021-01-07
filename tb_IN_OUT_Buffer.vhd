library IEEE;
use IEEE.std_logic_1164.all;

use work.Router_pkg.all;


entity tb_IN_OUT_BUFFER is
end;

architecture arch_tb_IN_OUT_BUFFER of tb_IN_OUT_BUFFER is
	signal Reset     : std_logic;
	signal Clock_En  : std_logic;
	signal Clock     : std_logic := '0';
	signal Ready_in  : std_logic;
	signal Ready_out : std_logic;
	signal Data_in   : std_logic_vector(bus_width-1 downto 0);
	signal Data_out  : std_logic_vector(bus_width-1 downto 0);

begin
	-- Register instance and mapping.
	r: IN_OUT_BUFFER port map (
		Reset     => Reset,
		Clock_En  => Clock_En,
		Clock     => Clock,
		Ready_in  => Ready_in,
		Ready_out => Ready_out,
		Data_in   => Data_in,
		Data_out  => Data_out
	);

	clk: process is
	begin
		wait for 10 ns;
		Clock <= not Clock;
	end process;

	tb: process is
		variable in1 : std_logic_vector(bus_width-1 downto 0) := "00001111";
		variable in2 : std_logic_vector(bus_width-1 downto 0) := "00001100";
	begin
		Reset <= '0';
		wait for 10 ns;
		Reset <= '1';
		wait for 10 ns;
		Reset <= '0';
		
		-- Buffer in1
		Clock_En <= '1';
		Ready_in <= '1';
		Data_in  <= in1;
		wait for 20 ns;
		assert Data_out = in1 report "Wrong output from Buffer" severity warning;

		-- Not ready buffer
		Ready_in <= '0';
		Data_in  <= in2;
		wait for 20 ns;
		assert Data_out = in1 report "Wrong output from Buffer" severity warning;

		-- Buffer in2
		Ready_in <= '1';
		Data_in  <= in2;
		wait for 20 ns;
		assert Data_out = in2 report "Wrong output from Buffer" severity warning;

		wait;
	end process;
end;