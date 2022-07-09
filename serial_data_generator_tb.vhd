library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity serial_data_generator_tb is
end entity;

architecture behave of serial_data_generator_tb is

	constant C_DATA_BLOCK_SIZE		: integer := 64;
	constant C_CLK_PRD				: time := 20 ns;
	constant C_REQUEST_WIDTH		: time := 2.5 us;
	
	component serial_data_generator is
	generic (
		G_DATA_BLOCK_SIZE	: integer := 64
	);
	port (
		CLK					: in    std_logic;	-- system clock
		RST					: in    std_logic;	-- asynchronous, active high reset
		DATA_REQUEST		: in    std_logic;	-- active high
		
		SER_DOUT			: out   std_logic;	-- derial data output
		SER_DOUT_VALID		: out   std_logic	-- active high
	);
	end component;
	
	signal clk_sig			: std_logic := '0';
	signal rst_sig			: std_logic := '0';
	signal data_req_sig 	: std_logic := '0';
	signal ser_data			: std_logic;
	signal ser_data_valid	: std_logic;
	
begin

	dut: serial_data_generator
	generic map (
		G_DATA_BLOCK_SIZE	=> C_DATA_BLOCK_SIZE
	)
	port map (
		CLK					=> clk_sig,
		RST					=> rst_sig,
		DATA_REQUEST		=> data_req_sig,
		SER_DOUT			=> ser_data,
		SER_DOUT_VALID		=> ser_data_valid
	);

	clk_sig <= not clk_sig after C_CLK_PRD / 2;
	rst_sig <= '1', '0' after 100 ns;
	
	process
	begin
		wait for 100 us;
		for i in 0 to 3 loop
			wait until rising_edge(clk_sig);
			data_req_sig <= '1';
			wait for C_REQUEST_WIDTH;
			wait until rising_edge(clk_sig);
			data_req_sig <= '0';
			
			wait until falling_edge(ser_data_valid);
			wait for 100 us;
		end loop;
		
		report "End of Simulation"
		severity failure;
		
		wait;
	end process;
	
end architecture;
