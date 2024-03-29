library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIR_DF_Top is

    Port ( 
				Clock 			: in  STD_LOGIC;
				Input_Signal 		: in  signed (13 downto 0);
				Output_Signal		: out	signed (13 downto 0)
				);
				
end FIR_DF_Top;

architecture Behavioral of FIR_DF_Top is

	------	Internal signal for buffering the input and output ports.
	signal	Input_Signal_Int		:	signed (13 downto 0)		:=	(others=>'0');
	signal	Output_Signal_Int		:	signed (13 downto 0)		:=	(others=>'0');
	
	------	Delay line registers.
	signal	Input_Signal_D1			:	signed (13 downto 0)		:=	(others=>'0');
	signal	Input_Signal_D2			:	signed (13 downto 0)		:=	(others=>'0');
	signal	Input_Signal_D3			:	signed (13 downto 0)		:=	(others=>'0');
	
	------	Coefficient constants.
	Constant	Coeff_b0		:	signed (8 downto 0)		:=	to_signed(31,9);
	Constant	Coeff_b1		:	signed (8 downto 0)		:=	to_signed(87,9);
	Constant	Coeff_b2		:	signed (8 downto 0)		:=	to_signed(87,9);
	Constant	Coeff_b3		:	signed (8 downto 0)		:=	to_signed(31,9);
	
	------
	signal	Product_Pipe_0			:	signed (22 downto 0)		:=	(others=>'0'); 
	signal	Product_Pipe_1			:	signed (22 downto 0)		:=	(others=>'0'); 
	signal	Product_Pipe_2			:	signed (22 downto 0)		:=	(others=>'0'); 
	signal	Product_Pipe_3			:	signed (22 downto 0)		:=	(others=>'0');
	
	signal	Adder_Tree_0			:	signed (22 downto 0)		:=	(others=>'0'); 
	signal	Adder_Tree_1			:	signed (22 downto 0)		:=	(others=>'0'); 
	
	signal	FIR_Accumulator			:	signed (22 downto 0)		:=	(others=>'0');
	
begin

	Output_Signal						<=	Output_Signal_Int;
	
	process(Clock)
	begin
	
		if rising_edge(Clock) then
		
			-- Input signal buffering
			Input_Signal_Int			<=	Input_Signal;
			
			-- FIR delay line
			Input_Signal_D1				<=	Input_Signal_Int;
			Input_Signal_D2				<=	Input_Signal_D1;
			Input_Signal_D3				<=	Input_Signal_D2;
			
			-- Register product results
			Product_Pipe_0				<=	Coeff_b0 * Input_Signal_Int;
			Product_Pipe_1				<=	Coeff_b1 * Input_Signal_D1;
			Product_Pipe_2				<=	Coeff_b2 * Input_Signal_D2;
			Product_Pipe_3				<=	Coeff_b3 * Input_Signal_D3;
			
			-- Adder tree
			Adder_Tree_0				<=	Product_Pipe_0 + Product_Pipe_1;
			Adder_Tree_1				<=	Product_Pipe_2 + Product_Pipe_3;
			
			-- FIR multiply and accumulate
			FIR_Accumulator				<=	Adder_Tree_0 + 
												Adder_Tree_1;
			
			Output_Signal_Int			<=	FIR_Accumulator(21 downto 8);
						
		end if;
	
	end process;

end Behavioral;

