library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


ENTITY Statistics_Calc IS

PORT ( 
	CLK, RSTn, START, DISPLAY : IN STD_LOGIC;
	HEX0 	: OUT STD_LOGIC_VECTOR(6 downto 0);
	HEX1 	: OUT STD_LOGIC_VECTOR(6 downto 0);
	HEX2 	: OUT STD_LOGIC_VECTOR(6 downto 0);
	LEDR 	: OUT STD_LOGIC_VECTOR(9 downto 5);
	LEDG 	: OUT STD_LOGIC_VECTOR(2 downto 1)
	);
END ENTITY;

ARCHITECTURE behave OF Statistics_Calc IS

--****************************** Main Controller ***********************************
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
--*************************** SERIAL 2 PARALLEL *****************************************
	component SerialToParallel IS
	generic(G_DATA_BITS_W_PARITY : integer := 9;
			G_LSB_FIRST 		 : boolean := false;
			G_PARITY			 : STD_LOGIC:= '0');
	PORT ( 
		CLK, RST, SER_DIN, SER_DIN_VALID 	: IN std_logic;
		PAR_DOUT_VALID, PARITY_ERROR : OUT std_logic;
		PAR_DOUT : OUT STD_LOGIC_VECTOR(G_DATA_BITS_W_PARITY - 2 downto 0)
		);
	END component;
--****************************** SERIAL DATA GENERATOR ***********************************
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
--****************************** Dflop Synchronizer ***********************************
	component DflopSync2D is
	port(
		D_in, RST, CLK : IN std_logic;
		Q_out : OUT std_logic
		);
	end component;
--****************************** Derivative UP ***********************************
	component DerivativeUP IS
		PORT(
		CLK,Din,Reset : IN std_logic;
		Dout : OUT std_logic
		);
	END component;
--****************************** Derivative Down ***********************************
	
	component DerivativeDown IS
		PORT(
		CLK,Din,Reset : IN std_logic;
		Dout : OUT std_logic
		);
	END component;
--****************************** bcd_to_7seg ***********************************	
	component bcd_to_7seg is
	port(
		BCD_IN                      : in    std_logic_vector(3 downto 0);
		SHUTDOWNn                   : in    std_logic;
		D_OUT                       : out   std_logic_vector(6 downto 0));
	end component;
--****************************** bin2bcd_12bit_sync ***********************************
	component bin2bcd_12bit_sync is
	port ( 
		binIN       : in    STD_LOGIC_VECTOR (11 downto 0);     -- this is the binary number
		ones        : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the unity digit
		tenths      : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the tens digit
		hunderths   : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the hundreds digit
		thousands   : out   STD_LOGIC_VECTOR (3 downto 0);      -- 
		clk         : in    STD_LOGIC                           -- clock input
	);
	end component;      
--**************************************************************************************
	
	CONSTANT G_DATA_BITS 		: integer := 8;
	CONSTANT G_NumOFParity 		: integer := 1;
	CONSTANT G_LSB_FIRST 		: boolean := false;
	CONSTANT G_PARITY				: STD_LOGIC:= '0';
	CONSTANT G_DATA_BLOCK_SIZE	: integer := 64;
	
	SIGNAL S_Start, S_Display, S_SS, S_DD, S_RST, S_Data_Ready : STD_LOGIC;
	SIGNAL S_SerDataValidation, S_SerData : STD_LOGIC;
	SIGNAL S_DataRequest, S_ParityError, S_SerDataValid : STD_LOGIC;
	SIGNAL S_DataVector, S_ResultDataVector : STD_LOGIC_VECTOR( G_DATA_BITS - 1 downto 0);
	SIGNAL S_ResultDataType   : STD_LOGIC_VECTOR( 4 downto 0);
	SIGNAL S_ones, S_tenths, S_hunderths : STD_LOGIC_VECTOR( 3 downto 0);
	SIGNAL S_BCD12BitConverter : STD_LOGIC_VECTOR(11 downto 0);
--**************************************************************************************
	begin

InputsOneShot1: DerivativeDown
			PORT MAP(CLK,START,RSTn, S_Start);
InputsOneShot2: DerivativeDown
			PORT MAP(CLK,DISPLAY,RSTn, S_Display);
	
MainControllerLabel: Main_Controller 
					GENERIC MAP(G_DATA_BITS)
					PORT MAP(CLK, S_RST, S_SS, S_DD, S_SerDataValid, S_ParityError, 
						S_DataRequest, S_Data_Ready, S_DataVector, S_ResultDataVector, S_ResultDataType);
						
						
Serial2ParLabel: SerialToParallel
					GENERIC MAP(G_DATA_BITS + G_NumOFParity,G_LSB_FIRST,G_PARITY)
					PORT MAP (CLK, S_RST, S_SerData, S_SerDataValidation, S_SerDataValid, S_ParityError, S_DataVector);
					
DataGenLabel: 	serial_data_generator
				GENERIC MAP(G_DATA_BLOCK_SIZE)
				PORT MAP (CLK, S_RST, S_DataRequest, S_SerData, S_SerDataValidation);


BcdSyncLabel: bin2bcd_12bit_sync
	PORT MAP ( S_BCD12BitConverter , S_ones, S_tenths, S_hunderths, OPEN, CLK);
	
BcdTo7SEG0: bcd_to_7seg
	PORT MAP(S_ones, S_Data_Ready, HEX0);
BcdTo7SEG1: bcd_to_7seg
	PORT MAP(S_tenths, S_Data_Ready, HEX1);
BcdTo7SEG2: bcd_to_7seg
	PORT MAP(S_hunderths, S_Data_Ready, HEX2);	
	
	
	S_SS <= not S_Start;
	S_DD <= not	S_Display;	
	LEDR <= S_ResultDataType;
	LEDG <= S_Data_Ready & '1';
	S_BCD12BitConverter <= "0000" & S_ResultDataVector ; 
	S_RST <= not RSTn;	
END behave; 
