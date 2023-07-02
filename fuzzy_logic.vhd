library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fuzzy_logic is	
	generic(
		clk_freq										: natural
	);
	port(
      NTC_ADC_AVR                          : in std_logic_vector(7 downto 0);
		LDR_ADC_AVR                          : in std_logic_vector(7 downto 0)                         
	);	
end entity;	

architecture rtl of fuzzy_logic is

--signal input1, input2;

begin
   process(all)
   begin
	
	end process;
end rtl;	