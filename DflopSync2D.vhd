library ieee;
use ieee.std_logic_1164.all;
entity DflopSync2D is
	port(
		D_in, RST, CLK : IN std_logic;
		Q_out : OUT std_logic
		);
end DflopSync2D;
architecture behave of DflopSync2D is
	signal QinDout : std_logic := '0';  -- acts like port/wire
	begin
		process(RST,CLK)
			begin
				if RST = '0' then 
					Q_out <= '1';
					QinDout <= '1';
				else
					if CLK'EVENT and CLK = '1' then
						QinDout <= D_in;
						Q_out <= QinDout;
					end if;
				end if;
			end process; -- only at the end of the process the signals and hardware ports change	
		END architecture;
		
