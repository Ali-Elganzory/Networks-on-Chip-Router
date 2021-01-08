library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

use work.Router_pkg.all;


entity Router is
	generic (
			bus_width : integer := 8
		);

	port (
			rst      : in std_logic;
			wclock   : in std_logic;
			rclock   : in std_logic;
			wr1, wr2, wr3, wr4 			   : in std_logic;
			datai1, datai2, datai3, datai4 : in std_logic_vector(bus_width-1 downto 0);
			datao1, datao2, datao3, datao4 : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Router of Router is
	-- grouping inputs and outputs
	signal wr    : std_logic_vector(0 to 3);	-- grouping wr (packet ready) inputs
	signal datai : bus_array (0 to 3);			-- grouping datai (packet) inputs
	signal datao : bus_array (0 to 3);			-- grouping datao (packet) outputs

	-- enable all buffers
	signal bufferes_enabled : std_logic := '1';

	-- output of Input Buffers
	signal IB_out : bus_array (0 to 3);
	signal IB_ready : std_logic_vector(0 to 3);

	-- parity check (Even) of packets
	signal pack_pcheck: std_logic_vector(0 to 3);

	-- output of Switch Fabric (SF) DeMuxs
	signal DeMUX_out : bus_array (0 to 4 ** 2 -1);

	-- output of Output Queues
	signal q_out   : bus_array (0 to 15);
	signal q_empty : std_logic_vector(0 to 15);
	signal q_full  : std_logic_vector(0 to 15);

	-- input of output Buffers
	signal OB_in : bus_array (0 to 3);

	-- FIFO wreq & rreq
	signal DeMUX_wr  : std_logic_vector(0 to 4 ** 2 -1);
	signal fifo_wreq : std_logic_vector(0 to 4 ** 2 -1);
	signal fifo_rreq : std_logic_vector(0 to 4 ** 2 -1);

	-- Output buffers holder
	signal OB_ready : std_logic_vector(0 to 3);

begin
	----  Grouping of input and output ports  ----
	wr    <= wr1 & wr2 & wr3 & wr4;
	datai <= (datai1, datai2, datai3, datai4);
	(datao1, datao2, datao3, datao4) <= datao;

	----  Input Buffers  ----
	IBs: for i in 0 to 3 generate
		IBx: IN_OUT_BUFFER port map (
			Reset     => rst,
			Clock_En  => bufferes_enabled,
			Clock     => rclock,
			Ready_in  => wr(i),
			Ready_out => IB_ready(i),
			Data_in   => datai(i),
			Data_out  => IB_out(i)
		);
	end generate;

	----  Parity Check (Even)  ----
	parity_checks: for i in 0 to 3 generate
		pack_pcheck(i) <= IB_out(i)(7) xnor (xor IB_out(i)(6 downto 0));
	end generate;

	----  Switch Fabric (SF)  ----
	De_MUXs: for i in 0 to 3 generate
		DeMUXX: DeMUX port map (
			En    => '1',
			Sel   => IB_out(i)(1 downto 0),
			d_in  => IB_out(i),
			d_out => DeMUX_out(4 * i to 4 * i + 3),
			wreq  => DeMUX_wr(4 * i to 4 * i + 3)
		);
	end generate;

	----  wreq  ----
	wreq_s: for i in 0 to 15 generate
		fifo_wreq(i) <= IB_ready(i mod 4) and pack_pcheck(i mod 4) and DeMUX_wr(i);
	end generate;
	
	----  Output Queues (FIFOs)  ----
	OQs: for i in 0 to 15 generate
		OQX: FIFO port map (
			reset   => rst,
			rclk    => rclock,
			wclk    => wclock,
			rreq    => fifo_rreq(i),
			wreq    => fifo_wreq(i),
			datain  => DeMUX_out(i),
			dataout => q_out(i),
			empty   => q_empty(i),
			full    => q_full(i)
		);
	end generate;

	----  Round-Robin MUXs  ----
	RRs: for i in 0 to 3 generate
		RRX: RR_Scheduler port map (
			din1 => q_out(i * 4 + 0), 
			din2 => q_out(i * 4 + 1), 
			din3 => q_out(i * 4 + 2), 
			din4 => q_out(i * 4 + 3),
			reset => rst,
			clock => rclock,
			dout  => OB_in(i),
			rreqs => fifo_rreq(4 * i to 4 * i + 3)
		);
	end generate;
		
	----  Output Buffers  ----
	OBs: for i in 0 to 3 generate
		OBx: IN_OUT_BUFFER port map (
			Reset     => rst,
			Clock_En  => bufferes_enabled,
			Clock     => rclock,
			Ready_in  => '1',
			Ready_out => OB_ready(i),
			Data_in   => OB_in(i),
			Data_out  => datao(i)
		);
	end generate;

end;