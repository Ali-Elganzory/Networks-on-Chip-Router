library IEEE;
use IEEE.std_logic_1164.all;

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
			datao1, datao2, datao3, datao4 : in std_logic_vector(bus_width-1 downto 0)
		);
end;

architecture arch_Router of Router is
	-- output of Input Buffers
	signal IB1_out, IB2_out, IB3_out, IB4_out : std_logic_vector(bus_width-1 downto 0);

	-- parity check (Even) of packets
	signal pack1_pcheck, pack2_pcheck, pack3_pcheck, pack4_pcheck : std_logic;

	-- output of Switch Fabric (SF) DeMuxs
	signal DeMUX1_out, DeMUX1_out, DeMUX1_out, DeMUX1_out : bus_array (0 to 2**de_mux_sel_c-1)

	-- output of Output Queues
	signal q_out   : bus_array (0 to 15);
	signal q_empty : std_logic_vector(0 to 15);
	signal q_full  : std_logic_vector(0 to 15);

	-- FSM
	signal current_state : std_logic_vector(3 downto 0);
	signal next_state : std_logic_vector(3 downto 0);

begin
	CS: process (rst, wclock, rclock) is
	begin
		if rst = '1' then
			current_state <= X"0";
		elsif rising_edge(wclock) then
			current_state <= next_state;
		end if;	
	end process;

	NS: process (current_state, wr1, wr2, wr3, wr4) is
	begin
		next_state <= wr1 & wr2 & wr3 & wr4;
	end process;

	----  Input Buffers  ----
	IB1: Reg port map (
		Reset => rst,
		Clock_En => wr1,
		Clock => rclock,
		Data_in => datai1,
		Data_out => IB1_out
	);
	IB2: Reg port map (
		Reset => rst,
		Clock_En => wr2,
		Clock => rclock,
		Data_in => datai2,
		Data_out => IB2_out
	);
	IB3: Reg port map (
		Reset => rst,
		Clock_En => wr2,
		Clock => rclock,
		Data_in => datai2,
		Data_out => IB3_out
	);
	IB4: Reg port map (
		Reset => rst,
		Clock_En => wr2,
		Clock => rclock,
		Data_in => datai2,
		Data_out => IB4_out
	);

	----  Parity Check (Even)  ----
	pack1_pcheck <= IB1_out(7) xnor (xor IB1_out(6 downto 0));
	pack2_pcheck <= IB2_out(7) xnor (xor IB2_out(6 downto 0));
	pack3_pcheck <= IB3_out(7) xnor (xor IB3_out(6 downto 0));
	pack4_pcheck <= IB4_out(7) xnor (xor IB4_out(6 downto 0));

	----  Switch Fabric (SF)  ----
	DeMUX1: DeMUX port map (
		En    => pack1_pcheck,
		Sel   => IB1_out(1 downto 0),
		d_in  => IB1_out,
		d_out => DeMUX1_out
	);
	DeMUX2: DeMUX port map (
		En    => pack2_pcheck,
		Sel   => IB2_out(1 downto 0),
		d_in  => IB2_out,
		d_out => DeMUX2_out
	);
	DeMUX3: DeMUX port map (
		En    => pack3_pcheck,
		Sel   => IB3_out(1 downto 0),
		d_in  => IB3_out,
		d_out => DeMUX3_out
	);
	DeMUX4: DeMUX port map (
		En    => pack4_pcheck,
		Sel   => IB4_out(1 downto 0),
		d_in  => IB4_out,
		d_out => DeMUX4_out
	);
	
	----  Output Queues (FIFO)  ----
	OQs: for i in 0 to 3 generate
		OQX1: FIFO port map (
			reset   => rst,
			rclk    => rclk,
			wclk    => wclk,
			rreq    => '1',
			wreq    => pack1_pcheck and current_state(3),
			datain  => DeMUX1_out(i)
			dataout => q_out(i * 4 + 0),
			empty   => q_empty(i * 4 + 0),
			full    => q_full(i * 4 + 0)
		);
		OQX2: FIFO port map (
			reset => rst,
			rclk => rclk,
			wclk => wclk,
			rreq => '1',
			wreq => pack2_pcheck and current_state(2),
			datain => DeMUX2_out(i)
			dataout => q_out(i * 4 + 1),
			empty => q_empty(i * 4 + 1),
			full => q_full(i * 4 + 1)
		);
		OQX3: FIFO port map (
			reset => rst,
			rclk => rclk,
			wclk => wclk,
			rreq => '1',
			wreq => pack3_pcheck and current_state(1),
			datain => DeMUX3_out(i)
			dataout => q_out(i * 4 + 2),
			empty => q_empty(i * 4 + 2),
			full => q_full(i * 4 + 2)
		);
		OQX4: FIFO port map (
			reset => rst,
			rclk => rclk,
			wclk => wclk,
			rreq => '1',
			wreq => pack4_pcheck and current_state(0),
			datain => DeMUX4_out(i)
			dataout => q_out(i * 4 + 3),
			empty => q_empty(i * 4 + 3),
			full => q_full(i * 4 + 3)
		);
	end generate OQs;

	RR: Round_Robin_Scheduler port map (
		clock => rclk,
		
	
end;