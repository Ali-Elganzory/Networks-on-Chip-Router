library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

use work.Router_pkg.Gray_Counter;


entity FIFO_Controller is
	generic (
			addr_width : integer := 4
		);

	port (
			reset       : in std_logic;
			rdclk       : in std_logic;
			wrclk       : in std_logic;
			rreq        : in std_logic;
			wreq        : in std_logic;
			read_valid  : out std_logic;
			write_valid : out std_logic;
			rd_ptr      : out std_logic_vector(addr_width-1 downto 0);
			wr_ptr      : out std_logic_vector(addr_width-1 downto 0);
			empty       : out std_logic;
			full        : out std_logic
		);
end;

architecture arch_FIFO_Controller of FIFO_Controller is
	signal read_ptr   : std_logic_vector(addr_width-1 downto 0);
	signal write_ptr  : std_logic_vector(addr_width-1 downto 0);
	signal is_empty   : std_logic;
	signal is_full    : std_logic;
	signal last_op    : std_logic;
	signal rd_valid   : std_logic;
	signal wr_valid   : std_logic;

begin
	rdpointer: Gray_Counter 
	generic map (
		counter_width => addr_width
	)
	port map (
		Reset     => reset,
		En        => rd_valid,
		Clock     => rdclk,
		Count_out => read_ptr
	);

	wrpointer: Gray_Counter 
	generic map (
		counter_width => addr_width
	)
	port map (
		Reset     => reset,
		En        => wr_valid,
		Clock     => wrclk,
		Count_out => write_ptr
	);

	read_valid  <= rd_valid;
	write_valid <= wr_valid;

	rd_valid <= rreq and not is_empty;
	wr_valid <= wreq and not is_full;

	lastop: process (reset, rdclk, wrclk) is
	begin
		if reset = '1' then
			last_op <= '0';
		elsif rising_edge(rdclk) and rising_edge(wrclk) then
			if rreq = '1' and is_empty = '0' and wreq = '1' and is_full = '0' then
				last_op <= last_op;
			elsif rreq = '1' and is_empty = '0' then
				last_op <= '0';
			elsif wreq = '1' and is_full = '0' then
				last_op <= '1';
			end if;
		elsif rising_edge(rdclk) and rreq = '1' and is_empty = '0' then
				last_op <= '0';
		elsif rising_edge(wrclk) and wreq = '1' and is_full = '0' then
				last_op <= '1';
		end if;
	end process;

	flags: process (read_ptr, write_ptr, last_op) is
	begin
		if (read_ptr = write_ptr) then
 			if last_op = '1' then
 				is_full <= '1';
 				is_empty <= '0';
 			else
 				is_full <= '0';
 				is_empty <= '1';
 			end if;
 		else
 			is_full <= '0';
 			is_empty <= '0';
 		end if;
	end process;

	rd_ptr <= read_ptr;
	wr_ptr <= write_ptr;

	empty <= is_empty;
	full  <= is_full;
end;
