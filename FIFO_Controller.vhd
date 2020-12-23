library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 


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

begin
	reading: process (reset, rdclk) is
	begin
		if reset = '1' then
			read_ptr <= (others => '0');
		elsif rising_edge(rdclk) then
			if rreq = '1' and is_empty = '0' then
				read_valid <= '1';
				read_ptr <= read_ptr + 1;
			else
				read_valid <= '0';
			end if;
		end if;
	end process;

	writing: process (reset, wrclk) is
	begin
		if reset = '1' then
			write_ptr <= (others => '0');
		elsif rising_edge(wrclk) then
			if wreq = '1' and is_full = '0' then
				write_valid <= '1';
				write_ptr <= write_ptr + 1;
			else
				write_valid <= '0';
			end if;
		end if;
	end process;

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
