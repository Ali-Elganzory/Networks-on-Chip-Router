library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.all;


entity tb_FIFO_Controller is
end;

architecture arch_tb_FIFO_Controller of tb_FIFO_Controller is
	signal reset       : std_logic;
	signal rdclk       : std_logic := '0';
	signal wrclk       : std_logic := '0';
	signal rreq        : std_logic;
	signal wreq        : std_logic;
	signal read_valid  : std_logic;
	signal write_valid : std_logic;
	signal rd_ptr      : std_logic_vector(addr_width-1 downto 0);
	signal wr_ptr      : std_logic_vector(addr_width-1 downto 0);
	signal empty       : std_logic;
	signal full        : std_logic;

begin
	-- FIFO Controller instance and mapping.
	FIFO_Con: FIFO_Controller port map (
		reset       => reset,
		rdclk 		=> rdclk,
		wrclk 		=> wrclk,
		rreq 		=> rreq,
		wreq 		=> wreq,
		read_valid  => read_valid,
		write_valid => write_valid,
		rd_ptr 		=> rd_ptr,
		wr_ptr 		=> wr_ptr,
		empty 		=> empty,
		full 		=> full
	);

	clk: process is
	begin
		wait for 10 ns;
		rdclk <= not rdclk;
		wrclk <= not wrclk;
	end process;

	tb: process is
		variable ptr0 : std_logic_vector(addr_width-1 downto 0) := (others => '0');
	begin
		reset <= '0';
		wait for 10 ns;
		reset <= '1';
		wait for 10 ns;
		reset <= '0';
		assert rd_ptr = ptr0 report "Didn't reset read ptr" severity warning;
		assert wr_ptr = ptr0 report "Didn't reset write ptr" severity warning;

		rreq <= '1';
		wait for 60 ns;
		assert rd_ptr = ptr0 report "Incremented read pointer while empty" severity warning;
		rreq <= '0';

		wreq <= '1';
		wait for 360 ns;
		assert wr_ptr = ptr0 report "Incremented write pointer while full" severity warning;
		wreq <= '0';

		rreq <= '1';
		wait for 80 ns;
		assert rd_ptr = "0110" report "Didn't increment read ptr while not empty" severity warning;
		rreq <= '0';

		wait;
	end process;
end;
