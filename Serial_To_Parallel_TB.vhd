library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity Serial_To_Parallel_TB is
end Serial_To_Parallel_TB;

architecture sim of Serial_To_Parallel_TB is

-- Constants declaration
	constant C_CLK_PRD	            : time := 20 ns;
	constant C_G_DATA_BITS_W_PARITY :integer :=9;
	constant C_G_LSB_FIRST          :Boolean   := FALSE;
	constant C_G_PARITY             :std_logic := '0'; 
	constant C_G_DATA_BLOCK_SIZE	: integer := 64;

	
-- Component declaration
component SerialToParallel is
	generic(
	 G_DATA_BITS_W_PARITY:integer   := 9;
	 G_LSB_FIRST         :Boolean   := FALSE;
	 G_PARITY            :std_logic := '0'
    );
    port(
		CLK            : in std_logic;
		RST            : in std_logic;
		SER_DIN        : in std_logic;
		SER_DIN_VALID  : in std_logic;
		PAR_DOUT       : out std_logic_vector(G_DATA_BITS_W_PARITY-2 downto 0);
		PAR_DOUT_VALID : out std_logic;
		PARITY_ERROR   : out std_logic
    );
	end component;
--**********************************************************************************	
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
	
--*****************************************************************************************************
-- Signals declaration
	signal S_CLK            : std_logic := '0';
	signal S_RST	        : std_logic := '0';
	signal S_SER_DIN	    : std_logic;
	signal S_SER_DIN_VALID	: std_logic;
	signal S_Data_Req    	: std_logic;
	
	
begin

-- ********************* clock & reset generation ********************
	--clk <= not clk after C_CLK_PRD / 2;
    
    process
    begin
        S_CLK <= '1';
        wait for C_CLK_PRD / 2;
        S_CLK <= '0';
        wait for C_CLK_PRD / 2;
    end process;
    
	S_RST <= '1', '0' after  50 ns;
	S_Data_Req <='0','1' after 3 us,'0' after 30 us; 
	
-- *******************************************************************

Serial2ParallelLabel: SerialToParallel
					GENERIC MAP ( C_G_DATA_BITS_W_PARITY, C_G_LSB_FIRST, C_G_PARITY)
					PORT MAP (S_CLK,S_RST,S_SER_DIN,S_SER_DIN_VALID,open,open,open);
	
SerialGenLabel: serial_data_generator
				GENERIC MAP(C_G_DATA_BLOCK_SIZE)
				PORT MAP(S_CLK,S_RST,S_Data_Req,S_SER_DIN,S_SER_DIN_VALID);
	
end sim;

