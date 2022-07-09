library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


ENTITY Main_Controller IS

generic(G_DATA_BITS : integer := 8);
PORT ( 
	CLK, RST, START, DISPLAY, DIN_VALID, PARITY_ERROR : IN std_logic;
	DATA_REQUEST, RESULTS_READY : OUT std_logic;
	DIN : IN STD_LOGIC_VECTOR(G_DATA_BITS - 1 downto 0);
	RESULT : OUT STD_LOGIC_VECTOR(G_DATA_BITS - 1 downto 0);
	RESULT_TYPE : OUT STD_LOGIC_VECTOR(4 downto 0)
	
	);
END ENTITY;

ARCHITECTURE behave OF Main_Controller IS

	constant NUM_OF_CLKS_PER_REQUEST : integer := 200; -- 200
	constant Block_Size : integer := 64; --4
	constant Half_Block_Size : integer := 32 ; -- 2 
	constant Max_Sum_NumofBits : integer := G_DATA_BITS + G_DATA_BITS - 2;
	constant Number_ofBits_toShift : integer := 6; --6
	
	-- Memory Block
	TYPE Mem_Bytes_Mem IS ARRAY (positive range <>) of STD_LOGIC_VECTOR( G_DATA_BITS - 1 DOWNTO 0 ); 
	SIGNAL Mem_Bytes : Mem_Bytes_Mem(1 to Block_Size ) := (others=>(others=>'0')); --SIGNAL Mem_Bytes : Mem_Bytes_Mem(Block_Size - 1 to 0);
	-- Main Machin State
	TYPE Main_Controller_States is (IDLE, Data_Request_State, Calculate, Displayy);
	SIGNAL State :Main_Controller_States;
	-- Progress State Meachin 
	TYPE Progress_States is ( Free, Calculation, DisplayRes );
	SIGNAL S_ProgressState :Progress_States;
	
	SIGNAL S_Indexi, S_Indexj, S_count, S_ParRORcount, S_CLK_NUM_COUNTER, S_RESULT_TYPE : integer;
	SIGNAL S_SumV2_AVG : STD_LOGIC_VECTOR( Max_Sum_NumofBits DOWNTO 0 );

	begin

		PROCESS(CLK,RST)
			BEGIN
			IF RST = '1' then	
				DATA_REQUEST <= '0';
				RESULTS_READY <= '0';
				RESULT <= (others => '0');
				State <= IDLE;
				S_ProgressState <= Free;
				RESULT_TYPE <=  (others => '0');
				S_RESULT_TYPE <= 0 ;
				
				S_count <= 1;
				S_SumV2_AVG <= (others => '0');
				S_ParRORcount <= 0 ;
				S_CLK_NUM_COUNTER <= NUM_OF_CLKS_PER_REQUEST;
				
			ELSIF rising_edge(CLK) THEN
				--------------- CONTROL SYSTEM
				IF S_ProgressState = DisplayRes THEN 
					IF DISPLAY = '0' THEN
						S_RESULT_TYPE <= S_RESULT_TYPE + 1;
					ELSIF START = '0'THEN
						State <= IDLE;
					END IF;
				ELSIF S_ProgressState = Free THEN
					IF START = '0' THEN 
							State <= Data_Request_State;
							S_ProgressState <= Calculation;
					END IF;
				END IF;
				----------------- END OF CONTROLL SYSTEM
			
				CASE State IS
					WHEN IDLE =>
						DATA_REQUEST <= '0';
						RESULTS_READY <= '0';
						S_ProgressState <= Free;
						RESULT_TYPE <=  (others => '0');
						S_RESULT_TYPE <= 0 ;
						
						S_SumV2_AVG <= (others => '0');
						S_ParRORcount <= 0 ;
						S_CLK_NUM_COUNTER <= NUM_OF_CLKS_PER_REQUEST;
						S_count <= 1;
						
						
						
					WHEN Data_Request_State => 
					
						IF S_CLK_NUM_COUNTER > 0 and DIN_VALID = '0' THEN
							DATA_REQUEST <= '1';
							S_CLK_NUM_COUNTER <= S_CLK_NUM_COUNTER - 1;
							
						ELSIF DIN_VALID = '1' THEN
							DATA_REQUEST <= '0'; 
							S_CLK_NUM_COUNTER <= 0;
							IF S_count = Block_Size THEN --check if we got all data
								Mem_Bytes(S_count) <= to_X01(DIN);
								S_SumV2_AVG <= S_SumV2_AVG + to_X01(DIN);
								IF PARITY_ERROR = '1' THEN
									S_ParRORcount <= S_ParRORcount + 1;
								END IF;
								State <= Calculate;
								S_count <= 1; -- reset for next rotation
								S_Indexi <= Block_Size;  -- used for sorting array offsets
								S_Indexj <= 1;
							ELSE
								Mem_Bytes(S_count) <= to_X01(DIN);
								S_SumV2_AVG <= S_SumV2_AVG + to_X01(DIN);
								S_count <= S_count + 1;
								IF PARITY_ERROR = '1' THEN
									S_ParRORcount <= S_ParRORcount + 1;
								END IF;
							END IF;
						END IF;
									
					
					WHEN Calculate =>
						-- sort the arry
						IF S_Indexi > 1 then
							IF S_Indexj < S_Indexi then --check if we still in range
								IF Mem_Bytes(S_Indexj) > Mem_Bytes(S_Indexj + 1) THEN--found bigger need to swap
									Mem_Bytes(S_Indexj) <= Mem_Bytes(S_Indexj + 1);
									Mem_Bytes(S_Indexj + 1) <= Mem_Bytes(S_Indexj);
								END IF; --end of swap
								S_Indexj <= S_Indexj + 1;
							ELSE
								S_Indexj <= 1;
								S_Indexi <= S_Indexi - 1;
							END IF;
						ELSE -- END OF SORTING NOW WE CALC THE MEDIAN
							S_SumV2_AVG <= std_logic_vector(shift_right(unsigned(S_SumV2_AVG) ,Number_ofBits_toShift));
							--ASK FADEl--S_SumV2_AVG <=  (others => '0') and S_SumV2_AVG(Max_Sum_NumofBits downto Number_ofBits_toShift);
							S_ProgressState <= DisplayRes;
							RESULTS_READY <= '1';
							State <= Displayy;
						END IF;

					WHEN Displayy =>
						CASE S_RESULT_TYPE IS
							WHEN 0 => --OFF
								RESULT_TYPE <= "00000";
								RESULT <= (others => 'Z');
								
							WHEN 1 => --MAX
								RESULT_TYPE <= "00001";
								RESULT <= Mem_Bytes(Block_Size);
								
							WHEN 2 => --MIN
								RESULT_TYPE <= "00010";
								RESULT <= Mem_Bytes(1);
								
							WHEN 3 => --AVG
								RESULT_TYPE <= "00100";
								RESULT<= S_SumV2_AVG(G_DATA_BITS - 1 downto 0);	
								
							WHEN 4 => --MEDIAN
								RESULT_TYPE <= "01000";
								IF Mem_Bytes(Half_Block_Size)(0) = '1' and Mem_Bytes(Half_Block_Size + 1)(0) = '1' THEN -- both numbers are odd soo we need to round up
									RESULT <=  ('0' & Mem_Bytes(Half_Block_Size)(G_DATA_BITS - 1 downto 1)) + ('0' & Mem_Bytes(Half_Block_Size + 1)(G_DATA_BITS - 1 downto 1)) + "00000001" ; --((others => '0') & '1');
								ELSE 
									RESULT <=  ('0' & Mem_Bytes(Half_Block_Size)(G_DATA_BITS - 1 downto 1)) + ('0' & Mem_Bytes(Half_Block_Size + 1)(G_DATA_BITS - 1 downto 1));
								END IF;
							WHEN 5 => --NUMofERROR
								RESULT_TYPE <= "10000";
								RESULT <= std_logic_vector(to_unsigned(S_ParRORcount, RESULT'length));
							WHEN others =>
								S_RESULT_TYPE <= 1; 
						END CASE;
				END CASE;
			END IF;
		END PROCESS;
END behave; 
