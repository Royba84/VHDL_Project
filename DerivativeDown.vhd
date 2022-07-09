LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY DerivativeDown IS
	PORT(
	CLK,Din,Reset : IN std_logic;
	Dout : OUT std_logic
	);
END ENTITY;
	
ARCHITECTURE behave OF DerivativeDown IS
Signal Mem1,Mem2 : std_logic := '0';
BEGIN
	PROCESS (CLK,Reset)
	BEGIN
		IF Reset = '0' THEN
			Mem1 <= '0';
			Mem2 <= '0';
		ELSIF rising_edge(CLK) THEN
			Mem1 <= Din;
			Mem2 <= Mem1;  --this acts a a clk delay and will only be updated on the next cycle		
		END IF;
	END PROCESS;
	Dout <= Mem2 and not Mem1;
END behave;
