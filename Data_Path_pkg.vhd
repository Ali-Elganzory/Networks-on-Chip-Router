library IEEE;
use IEEE.std_logic_1164.all;


package Router_pkg is

	constant bus_width     : integer := 8;
	constant de_mux_sel_c  : integer := 2;
	constant addr_width    : integer := 4;
	constant counter_width : integer := 4;

	type bus_array is array(natural range <>) of std_logic_vector(bus_width - 1 downto 0);

	component Reg is
		generic(
				bus_width : integer := bus_width
			);

		port(
				Reset    : in std_logic;
				Clock_En : in std_logic;
				Clock    : in std_logic;
				Data_in  : in std_logic_vector(bus_width-1 downto 0);
				Data_out : out std_logic_vector(bus_width-1 downto 0)
			);
	end component;

	component DeMUX is
		generic (
				de_mux_sel_c : integer := de_mux_sel_c;
				bus_width    : integer := bus_width
			);

		port(
				En : in std_logic;
				Sel    : in std_logic_vector(de_mux_sel_c-1 downto 0);
				d_in  : in std_logic_vector(bus_width-1 downto 0);
 				d_out : out bus_array (0 to 2**de_mux_sel_c-1)
			);
	end component;

	component DP_RAM is
		generic (
				bus_width  : integer := bus_width;
				addr_width : integer := addr_width
			);

		port (
				CLKA  : in std_logic;
				CLKB  : in std_logic;
				WEA   : in std_logic;
				REA   : in std_logic;
				ADDRA : in std_logic_vector(addr_width-1 downto 0);
				ADDRB : in std_logic_vector(addr_width-1 downto 0);
				d_in  : in std_logic_vector(bus_width-1 downto 0);
				d_out : out std_logic_vector(bus_width-1 downto 0)
			);
	end component;

	component Gray_Counter is
		generic (
				counter_width : integer := counter_width
			);

		port (
				Reset     : in std_logic;
				En        : in std_logic;
				Clock     : in std_logic;
				Count_out : out std_logic_vector(counter_width-1 downto 0)
			);
	end component;

	component Gray_to_Binary is
		generic (
				bus_width : integer := bus_width
			);

		port (
				gray_in : in std_logic_vector(bus_width-1 downto 0);
				bin_out : out std_logic_vector(bus_width-1 downto 0)
			);
	end component;

	component FIFO_Controller is
		generic (
				addr_width : integer := addr_width
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
	end component;

	component FIFO is
		generic (
				bus_width : integer := bus_width
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
	end component;

end;
