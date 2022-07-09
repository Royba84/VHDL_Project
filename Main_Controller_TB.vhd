library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity Main_Controller_TB is
end Main_Controller_TB;

architecture sim of Main_Controller_TB is

-- Constants declaration
	constant C_CLK_PRD	            : time := 20 ns;
	constant C_G_DATA_BITS_W_PARITY :integer :=9;
	constant C_G_LSB_FIRST          :Boolean   := FALSE;
	constant C_G_PARITY             :std_logic := '0'; 
	constant C_G_DATA_BLOCK_SIZE	: integer := 64;

	
-- Component declaration
component Main_Controller IS
	generic(G_DATA_BITS : integer := 8);
	PORT ( 
		CLK, RST, START, DISPLAY, DIN_VALID, PARITY_ERROR : IN std_logic;
		DATA_REQUEST, RESULTS_READY : OUT std_logic;
		DIN : IN STD_LOGIC_VECTOR(G_DATA_BITS - 1 downto 0);
		RESULT : OUT STD_LOGIC_VECTOR(G_DATA_BITS - 1 downto 0);
		RESULT_TYPE : OUT STD_LOGIC_VECTOR(4 downto 0)
		);
	END component;
--**********************************************************************************
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
	

-- Signals declaration
	SIGNAL S_CLK            		: STD_LOGIC := '0';
	SIGNAL S_RST	        		: STD_LOGIC := '0';
	SIGNAL S_SER_DIN	    		: STD_LOGIC;
	SIGNAL S_SER_DIN_VALID  		: STD_LOGIC;
	SIGNAL S_SER_DINvector			: STD_LOGIC_VECTOR(C_G_DATA_BITS_W_PARITY - 2 downto 0);
	SIGNAL S_SER_DINvector_VALID	: STD_LOGIC;
	SIGNAL S_Data_Req    			: STD_LOGIC;
	SIGNAL S_Parity_Error 			: STD_LOGIC;
	SIGNAL S_Result_Ready			: STD_LOGIC;
	SIGNAL S_RESULT 				: STD_LOGIC_VECTOR(C_G_DATA_BITS_W_PARITY - 2 downto 0);
	SIGNAL S_RESULT_TYPE 			: STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL S_START					: STD_LOGIC;
	SIGNAL S_DISPLAY 				: STD_LOGIC;
	
begin

-- ********************* clock & reset generation ********************
	--clk <= not clk after C_CLK_PRD / 2;
    
    process
    begin
        S_CLK <= '1';
        wait for C_CLK_PRD / 2;
        S_CLK <= '0';
        wait for C_CLK_PRD / 2;
		
	--	if S_Result_Ready = '1'then
	--S_DISPLAY <= '0' after 10 ns,'1' after 20 ns; 
	--end if;
    end process;
	
    
	S_RST <= '1', '0' after  25 ns;
	S_START <= '1','0' after 30 ns,'1' after 50 ns;  
	S_DISPLAY <= '1','0' after 60 us,'1' after 61 us; 
-- *******************************************************************


MainControllerLabel: Main_Controller
					GENERIC MAP(C_G_DATA_BITS_W_PARITY - 1)
					PORT Map(S_CLK, S_RST, S_START, S_DISPLAY, S_SER_DINvector_VALID, S_Parity_Error,
							 S_Data_Req, S_Result_Ready, S_SER_DINvector, S_RESULT,S_RESULT_TYPE);

Serial2ParallelLabel: SerialToParallel
				GENERIC MAP ( C_G_DATA_BITS_W_PARITY, C_G_LSB_FIRST, C_G_PARITY)
				PORT MAP (S_CLK,S_RST,S_SER_DIN,S_SER_DIN_VALID,S_SER_DINvector,S_SER_DINvector_VALID,S_Parity_Error);
	
SerialGenLabel: serial_data_generator
				GENERIC MAP(C_G_DATA_BLOCK_SIZE)
				PORT MAP(S_CLK,S_RST,S_Data_Req,S_SER_DIN,S_SER_DIN_VALID);
	
end sim;

