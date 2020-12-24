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
			rd1, rd2, rd3, rd4 			   : out std_logic;
			datai1, datai2, datai3, datai4 : in std_logic_vector(bus_width-1 downto 0);
			datao1, datao2, datao3, datao4 : out std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Router of Router is
	-- enable all buffers
	signal bufferes_enabled : std_logic := '1';

	-- output of Input Buffers
	signal IB_out : bus_array (0 to 3);
	signal IB1_ready, IB2_ready, IB3_ready, IB4_ready : std_logic;

	-- parity check (Even) of packets
	signal pack_pcheck: std_logic_vector(0 to 3);

	-- output of Switch Fabric (SF) DeMuxs
	signal DeMUX1_out, DeMUX2_out, DeMUX3_out, DeMUX4_out : bus_array (0 to 2**de_mux_sel_c-1);

	-- output of Output Queues
	signal q_out   : bus_array (0 to 15);
	signal q_read  : std_logic_vector(0 to 15);
	signal q_empty : std_logic_vector(0 to 15);
	signal q_full  : std_logic_vector(0 to 15);

	-- input of output Buffers
	signal OB_in : bus_array (0 to 3);

	-- counter
	signal counter : std_logic_vector(counter_width-1 downto 0);

	-- FIFO wreq & rreq
	signal fifo_wreq : std_logic_vector(0 to 4 * counter_width**2 -1);
	signal fifo_rreq : std_logic_vector(0 to counter_width**2 -1);

begin

	----  Input Buffers  ----
	IB1: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => rclock,
		Ready_in  => wr1,
		Ready_out => IB1_ready,
		Data_in   => datai1,
		Data_out  => IB_out(0)
	);
	IB2: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => rclock,
		Ready_in  => wr2,
		Ready_out => IB2_ready,
		Data_in   => datai2,
		Data_out  => IB_out(1)
	);
	IB3: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => rclock,
		Ready_in  => wr3,
		Ready_out => IB3_ready,
		Data_in   => datai3,
		Data_out  => IB_out(2)
	);
	IB4: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => rclock,
		Ready_in  => wr4,
		Ready_out => IB4_ready,
		Data_in   => datai4,
		Data_out  => IB_out(3)
	);

	----  Parity Check (Even)  ----
	parity_checks: for i in 0 to 3 generate
		pack_pcheck(i) <= IB_out(i)(7) xnor (xor IB_out(i)(6 downto 0));
	end generate;

	----  FIFO write reqs  ----
	fifo_wreq(0) <= IB1_ready and pack_pcheck(0) and not IB_out(0)(1) and not IB_out(0)(0);
	fifo_wreq(1) <= IB2_ready and pack_pcheck(1) and not IB_out(1)(1) and not IB_out(1)(0);
	fifo_wreq(2) <= IB3_ready and pack_pcheck(2) and not IB_out(2)(1) and not IB_out(2)(0);
	fifo_wreq(3) <= IB4_ready and pack_pcheck(3) and not IB_out(3)(1) and not IB_out(3)(0);
	--
	fifo_wreq(4) <= IB1_ready and pack_pcheck(0) and IB_out(0)(1) and not IB_out(0)(0);
	fifo_wreq(5) <= IB2_ready and pack_pcheck(1) and IB_out(1)(1) and not IB_out(1)(0);
	fifo_wreq(6) <= IB3_ready and pack_pcheck(2) and IB_out(2)(1) and not IB_out(2)(0);
	fifo_wreq(7) <= IB4_ready and pack_pcheck(3) and IB_out(3)(1) and not IB_out(3)(0);
	--
	fifo_wreq(8) <= IB1_ready and pack_pcheck(0) and not IB_out(0)(1) and IB_out(0)(0);
	fifo_wreq(9) <= IB2_ready and pack_pcheck(1) and not IB_out(1)(1) and IB_out(1)(0);
	fifo_wreq(10) <= IB3_ready and pack_pcheck(2) and not IB_out(2)(1) and IB_out(2)(0);
	fifo_wreq(11) <= IB4_ready and pack_pcheck(3) and not IB_out(3)(1) and IB_out(3)(0);
	--
	fifo_wreq(12) <= IB1_ready and pack_pcheck(0) and IB_out(0)(1) and IB_out(0)(0);
	fifo_wreq(13) <= IB2_ready and pack_pcheck(1) and IB_out(1)(1) and IB_out(1)(0);
	fifo_wreq(14) <= IB3_ready and pack_pcheck(2) and IB_out(2)(1) and IB_out(2)(0);
	fifo_wreq(15) <= IB4_ready and pack_pcheck(3) and IB_out(3)(1) and IB_out(3)(0);

	----  Switch Fabric (SF)  ----
	DeMUX1: DeMUX port map (
		En    => '1',
		Sel   => IB_out(0)(1 downto 0),
		d_in  => IB_out(0),
		d_out => DeMUX1_out
	);
	DeMUX2: DeMUX port map (
		En    => '1',
		Sel   => IB_out(1)(1 downto 0),
		d_in  => IB_out(1),
		d_out => DeMUX2_out
	);
	DeMUX3: DeMUX port map (
		En    => '1',
		Sel   => IB_out(2)(1 downto 0),
		d_in  => IB_out(2),
		d_out => DeMUX3_out
	);
	DeMUX4: DeMUX port map (
		En    => '1',
		Sel   => IB_out(3)(1 downto 0),
		d_in  => IB_out(3),
		d_out => DeMUX4_out
	);
	
	----  Output Queues (FIFOs)  ----
	OQs: for i in 0 to 3 generate
		OQX1: FIFO port map (
			reset   => rst,
			rclk    => rclock,
			wclk    => wclock,
			rreq    => fifo_rreq(0),
			wreq    => fifo_wreq(i * 4 + 0),
			datain  => DeMUX1_out(i),
			dataout => q_out(i * 4 + 0),
			read_ok => q_read(i * 4 + 0),
			empty   => q_empty(i * 4 + 0),
			full    => q_full(i * 4 + 0)
		);
		OQX2: FIFO port map (
			reset => rst,
			rclk => rclock,
			wclk => wclock,
			rreq => fifo_rreq(1),
			wreq => fifo_wreq(i * 4 + 1),
			datain => DeMUX2_out(i),
			dataout => q_out(i * 4 + 1),
			read_ok => q_read(i * 4 + 1),
			empty => q_empty(i * 4 + 1),
			full => q_full(i * 4 + 1)
		);
		OQX3: FIFO port map (
			reset => rst,
			rclk => rclock,
			wclk => wclock,
			rreq => fifo_rreq(2),
			wreq => fifo_wreq(i * 4 + 2),
			datain => DeMUX3_out(i),
			dataout => q_out(i * 4 + 2),
			read_ok => q_read(i * 4 + 2),
			empty => q_empty(i * 4 + 2),
			full => q_full(i * 4 + 2)
		);
		OQX4: FIFO port map (
			reset => rst,
			rclk => rclock,
			wclk => wclock,
			rreq => fifo_rreq(3),
			wreq => fifo_wreq(i * 4 + 3),
			datain => DeMUX4_out(i),
			dataout => q_out(i * 4 + 3),
			read_ok => q_read(i * 4 + 3),
			empty => q_empty(i * 4 + 3),
			full => q_full(i * 4 + 3)
		);
	end generate OQs;

	----  Round-Robin MUXs  ----
	RR_MUXs: for i in 0 to 3 generate
		RR_MUXX: MUX port map (
			En => '1',
			Sel => counter,
			d_in => q_out(i * 4 to i * 4 + 3),
			d_out => OB_in(i)
		);
	end generate;

	----  FIFO read reqs  ----
	fifo_rreq(0) <= not counter(1) and not counter(0);
	fifo_rreq(1) <= not counter(1) and counter(0);
	fifo_rreq(2) <= counter(1) and not counter(0);
	fifo_rreq(3) <= counter(1) and counter(0);
		
	----  Output Buffers  ----
	OB1: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => wclock,
		Ready_in  => (or q_read(0 to 3)),
		Ready_out => rd1,
		Data_in   => OB_in(0),
		Data_out  => datao1
	);
	OB2: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => wclock,
		Ready_in  => (or q_read(4 to 7)),
		Ready_out => rd2,
		Data_in   => OB_in(1),
		Data_out  => datao2
	);
	OB3: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => wclock,
		Ready_in  => (or q_read(8 to 11)),
		Ready_out => rd3,
		Data_in   => OB_in(2),
		Data_out  => datao3
	);
	OB4: IN_OUT_BUFFER port map (
		Reset     => rst,
		Clock_En  => bufferes_enabled,
		Clock     => wclock,
		Ready_in  => (or q_read(12 to 15)),
		Ready_out => rd4,
		Data_in   => OB_in(3),
		Data_out  => datao4
	);

	----  Gray Counter  ----
	gray: Gray_Counter port map (
		Reset     => rst,
		En        => '1',
		Clock     => rclock,
		Count_out => counter
	);
	
end;