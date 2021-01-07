library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.all;


entity tb_FIFO is
end;

architecture arch_tb_FIFO of tb_FIFO is
	signal reset       : std_logic;
	signal rclk        : std_logic := '0';
	signal wclk        : std_logic := '0';
	signal rreq        : std_logic;
	signal wreq        : std_logic;
	signal datain      : std_logic_vector(bus_width-1 downto 0);
	signal dataout     : std_logic_vector(bus_width-1 downto 0);
	signal empty       : std_logic;
	signal full        : std_logic;

begin
	-- FIFO Controller instance and mapping.
	FI_FO: FIFO port map (
		reset   => reset,
		rclk    => rclk,
		wclk    => wclk,
		rreq    => rreq,
		wreq    => wreq,
		datain  => datain,
		dataout => dataout,
		empty   => empty,
		full    => full
	);

	clk: process is
	begin
		wait for 10 ns;
		rclk <= not rclk;
		wclk <= not wclk;
	end process;

	tb: process is
		variable in1 : std_logic_vector(bus_width-1 downto 0) := "00001111";
		variable in2 : std_logic_vector(bus_width-1 downto 0) := "00001100";
	begin
		reset <= '0';
		wait for 10 ns;
		reset <= '1';
		wait for 10 ns;
		reset <= '0';	

		-- Write
		wreq <= '1';
		rreq <= '0';
		datain <= in1;
		wait for 20 ns;

		-- Write & Read
		wreq <= '1';
		rreq <= '1';
		datain <= in2;
		wait for 20 ns;
		assert dataout = in1 report "Wrong output from FIFO" severity warning;

		
		-- Read
		wreq <= '0';
		rreq <= '1';
		wait for 20 ns;
		assert dataout = in2 report "Wrong output from FIFO" severity warning;

		wait;
	end process;
end;
