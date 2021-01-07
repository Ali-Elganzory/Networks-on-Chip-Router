library IEEE;
use IEEE.std_logic_1164.all;

use work.Router_pkg.all;


entity tb_DP_RAM is
end;

architecture arch_tb_DP_RAM of tb_DP_RAM is
	signal CLKA  : std_logic := '0';
	signal CLKB  : std_logic := '0';
	signal WEA   : std_logic;
	signal REA   : std_logic;
	signal ADDRA : std_logic_vector(addr_width-1 downto 0);
	signal ADDRB : std_logic_vector(addr_width-1 downto 0);
	signal d_in  : std_logic_vector(bus_width-1 downto 0);
	signal d_out : std_logic_vector(bus_width-1 downto 0);

begin
	-- DP RAM instance and mapping.
	dpRAM: DP_RAM port map (
		CLKA  => CLKA,
		CLKB  => CLKB,
		WEA   => WEA,
		REA   => REA,
		ADDRA => ADDRA,
		ADDRB => ADDRB,
		d_in  => d_in,
		d_out => d_out
	);

	clk: process is
	begin
		wait for 10 ns;
		CLKA <= not CLKA;
		CLKB <= not CLKB;
	end process;

	tb: process is
		variable in1 : std_logic_vector(bus_width-1 downto 0) := "00001111";
		variable in2 : std_logic_vector(bus_width-1 downto 0) := "00001100";
	begin

		-- Write
		WEA <= '1';
		REA <= '0';
		d_in <= in1;
		ADDRA <= (0 => '0', others => '0');
		wait for 20 ns;

		-- Write & Read
		WEA <= '1';
		REA <= '1';
		d_in <= in2;
		ADDRA <= (0 => '1', others => '0');
		ADDRB <= (0 => '0', others => '0');
		wait for 20 ns;
		assert d_out = in1 report "Wrong output from RAM" severity warning;

		
		-- Read
		WEA <= '0';
		REA <= '1';
		ADDRB <= (0 => '1', others => '0');
		wait for 20 ns;
		assert d_out = in2 report "Wrong output from RAM" severity warning;

		wait;
	end process;
end;
