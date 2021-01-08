library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Router_pkg.all;


entity tb_Router is
end;

architecture arch_tb_Router of tb_Router is
	signal rst      : std_logic;
	signal wclock   : std_logic := '0';
	signal rclock   : std_logic := '0';
	signal wr1, wr2, wr3, wr4 			  : std_logic;
	signal datai1, datai2, datai3, datai4 : std_logic_vector(bus_width-1 downto 0);
	signal datao1, datao2, datao3, datao4 : std_logic_vector(bus_width-1 downto 0);

begin

	-- Router instance and mapping.
	Router_UUT: Router port map (
		rst => rst,
		wclock => wclock,
		rclock => rclock,
		wr1 => wr1, wr2 => wr2, wr3 => wr3, wr4 => wr4,
		datai1 => datai1, datai2 => datai2, datai3 => datai3, datai4 => datai4,
		datao1 => datao1, datao2 => datao2, datao3 => datao3, datao4 => datao4
	);

	clk: process is
	begin
		wait for 10 ns;
		wclock <= not wclock;
		rclock <= not rclock;
	end process;

	tb: process is
		variable packet1, packet2, packet3, packet4 : std_logic_vector(bus_width-1 downto 0);
	begin
	
		wr1    <= '0';
		wr2    <= '0';
		wr3    <= '0';
		wr4    <= '0';

		-- Reset the Router
		rst    <= '1';
		wait for 10 ns;
		rst    <= '0';
		wait for 10 ns;

		-- Input 4 packets via all 4 ports simultaneously
		-- routed to all 4 output ports
		packet1 := "01100000";	-- 1st FIFO of 1st port
		packet2 := "01101001";	-- 2nd FIFO of 2nd port
		packet3 := "11101110";	-- 3rd FIFO of 3rd port
		packet4 := "11111111";	-- 4th FIFO of 4th port

		datai1 <= packet1;
		datai2 <= packet2;
		datai3 <= packet3;
		datai4 <= packet4;

		wr1 <= '1';
		wr2 <= '1';
		wr3 <= '1';
		wr4 <= '1';
		----  Datapath waiting  ----
		-- 1 cycle to be in-buffered
		wait for 20 ns;
		wr1 <= '0';
		wr2 <= '0';
		wr3 <= '0';
		wr4 <= '0';
		-- 1 cycle in Switch Fabric
		-- 1 cycle in FIFO
		-- 1 cycle to be read from FIFO
		-- 1-3 cycles in scheduling -> out-buffers
		wait for 100 ns;

		-- At this point the RR Scheduler picks the 4th FIFO.
		-- each cycle it advances to the next FIFO at other port.
		wait for 20 ns;
		assert datao4 = packet4 report "Wrong packet" severity warning;
		wait for 20 ns;
		assert datao1 = packet1 report "Wrong packet" severity warning;
		wait for 20 ns;
		assert datao2 = packet2 report "Wrong packet" severity warning;
		wait for 20 ns;
		assert datao3 = packet3 report "Wrong packet" severity warning;

		wait;

	end process;

end;