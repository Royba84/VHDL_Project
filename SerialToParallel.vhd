library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.NUMERIC_BIT;
use ieee.NUMERIC_STD;

--0 – even parity
--1 – odd parity

ENTITY SerialToParallel IS
generic(G_DATA_BITS_W_PARITY : integer := 9;
		G_LSB_FIRST 		 : boolean := false;
		G_PARITY			 : STD_LOGIC:= '0');
PORT ( 
	CLK, RST, SER_DIN, SER_DIN_VALID 	: IN std_logic;
	PAR_DOUT_VALID, PARITY_ERROR : OUT std_logic;
	PAR_DOUT : OUT STD_LOGIC_VECTOR(G_DATA_BITS_W_PARITY - 2 downto 0)
	);
END ENTITY;

ARCHITECTURE behave OF SerialToParallel IS
--**************************************************************************************

	signal S_PAR_DOUT : STD_LOGIC_VECTOR(G_DATA_BITS_W_PARITY - 2 downto 0);
	signal S_BitCounter : integer range 0 to G_DATA_BITS_W_PARITY ;
	signal S_Par_Check : STD_LOGIC;
	
	begin
	PROCESS(CLK,RST)
			BEGIN
			if RST = '1' then	
				PAR_DOUT <= (others => 'Z');
				S_PAR_DOUT <= (others => 'Z');
				PAR_DOUT_VALID <= 'Z';
				PARITY_ERROR <= 'Z';
				S_Par_Check <= '0';
				S_BitCounter <= 0;
				
			ELSIF rising_edge(CLK) then
				if SER_DIN_VALID = '1' then
					if S_BitCounter < G_DATA_BITS_W_PARITY - 1 then
						if G_LSB_FIRST = false then  --check if we read MSB first
							S_PAR_DOUT <= S_PAR_DOUT(G_DATA_BITS_W_PARITY - 3 downto 0) & to_X01(SER_DIN);
						else  --we read LSB first
							S_PAR_DOUT <= (to_X01(SER_DIN) & S_PAR_DOUT(G_DATA_BITS_W_PARITY - 2 downto 1));
						end if;
						S_BitCounter <= S_BitCounter + 1;
						S_Par_Check <= S_Par_Check xor SER_DIN;
						PAR_DOUT_VALID <= '0';
						PARITY_ERROR <= '0';
						
					elsif S_BitCounter = G_DATA_BITS_W_PARITY - 1 then -- must check parity
						PAR_DOUT <= S_PAR_DOUT; 
						S_PAR_DOUT <= (others => 'Z');
						S_BitCounter <= 0;
						if (S_Par_Check xor SER_DIN) = G_PARITY then
							--data is valid
							PAR_DOUT_VALID <= '1';
							PARITY_ERROR <= '0';
						else 
							--data is not valid
							PAR_DOUT_VALID <= '1';
							PARITY_ERROR <= '1';
						S_Par_Check <= '0';
						end if;

					end if;
				else -- NO SERIAL DATA VALIDATION
					S_PAR_DOUT <= (others => 'Z');
					PAR_DOUT_VALID <= '0';
					PARITY_ERROR <= '0';
					S_Par_Check <= '0';
					S_BitCounter <= 0;
					
				end if;
			END IF;
		end process;
END behave;
