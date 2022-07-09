	--Includes&libraries needed:
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_signed.all;
	use ieee.std_logic_arith.all;
	-- Test bench for the top level - Statistics_Calc.vhd 

	entity Statistics_Calc_TB is
	end entity;

	architecture behave of Statistics_Calc_TB is

		constant C_CLK_PRD				: time := 20 ns;
		
		--Statistics_Calc component properties:
		component Statistics_Calc is
		port (
		CLK 		: in std_logic;
		RSTn 		: in std_logic;
		START		: in std_logic;
		DISPLAY		: in std_logic;
		HEX0		: out std_logic_vector(6 downto 0);
		HEX1		: out std_logic_vector(6 downto 0);
		HEX2		: out std_logic_vector(6 downto 0);
		LEDR		: out std_logic_vector(9 downto 5);
		LEDG		: out std_logic_vector(2 downto 1)
		);
		end component;
		
		--Signals:
		signal clk_sig				: std_logic := '0';
		signal rstn_sig				: std_logic := '0';
		signal START_sig, DISPLAY_sig			: std_logic;
		signal S_HEX0, S_HEX1, S_HEX2		:  std_logic_vector(6 downto 0);
		signal S_LEDR		:  std_logic_vector(9 downto 5);
		signal S_LEDG		:  std_logic_vector(2 downto 1);
		
	begin

		DUT: Statistics_Calc
		-- Ports:
		port map (
						CLK				=> clk_sig,
						RSTn			=> rstn_sig,
						START			=> START_sig,
						DISPLAY			=> DISPLAY_sig,
						HEX0			=> S_HEX0,
						HEX1			=> S_HEX1,
						HEX2			=> S_HEX2,
						LEDR			=> S_LEDR,
						LEDG        	=> S_LEDG
					);
					
		clk_sig <= not clk_sig after C_CLK_PRD / 2;
		rstn_sig <= '0', '1' after 500 ns;
		
		START_sig  <= '1','0' after 530 ns,'1' after 550 ns;  
		DISPLAY_sig <= '1','0' after 150 us,'1' after 151 us ,'0' after 250 us,'1' after 251 us ,'0' after 350 us,'1' after 351 us ,'0' after 450 us,'1' after 451 us ,'0' after 550 us,'1' after 551 us ,'0' after 650 us,'1' after 651 us ; 
	end behave;
