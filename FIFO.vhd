library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

use work.Router_pkg.all;


entity FIFO is
	generic (
			bus_width  : integer := 8;
			addr_width : integer := 4
		);

	port (
			reset       : in std_logic;
			rclk        : in std_logic;
			wclk        : in std_logic;
			rreq        : in std_logic;
			wreq        : in std_logic;
			datain      : in std_logic_vector(bus_width-1 downto 0);
			dataout     : out std_logic_vector(bus_width-1 downto 0);
			empty       : out std_logic;
			full        : out std_logic
		);
end;

architecture arch_FIFO of FIFO is
	signal read_ptr    : std_logic_vector(addr_width-1 downto 0);
	signal write_ptr   : std_logic_vector(addr_width-1 downto 0);
	signal read_valid  : std_logic;
	signal write_valid : std_logic;

begin
	queue_ram: DP_RAM port map (
		CLKA  => rclk,
		CLKB  => wclk,
		WEA   => write_valid,
		REA   => read_valid,
		ADDRA => write_ptr,
		ADDRB => read_ptr,
		d_in  => datain,
		d_out => dataout
	);

	queue_con: FIFO_Controller port map (
		reset       => reset,
		rdclk       => rclk,
		wrclk       => wclk,
		rreq        => rreq,
		wreq        => wreq,
		read_valid  => read_valid,
		write_valid => write_valid,
		rd_ptr      => read_ptr,
		wr_ptr      => write_ptr,
		empty       => empty,
		full        => full
	);
end;
