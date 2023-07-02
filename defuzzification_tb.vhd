-------------------------------------------------
-- defuzzification_tb.vhd
--
-- Author:   Steve Dillen
-- Date:     November 15, 2000 
-- Course:   EE552
-- Desc:
--
-- This testbench will test the defuzzification module.
-- This is done by inputting the fuzzy value, the membership
-- functions and examining the output
--

-- Include ieee std_logic types
--
library ieee;
use ieee.std_logic_1164.all;

-- Test Bench
--
entity defuzzification_tb is
end defuzzification_tb;

architecture mixed of defuzzification_tb is

  component defuzzification is

    port    ( clock        : in  std_logic;
              reset        : in  std_logic;
              fuzzy_output : in  std_logic_vector( 2 downto 0 );
              membership   : in  std_logic_vector( 7 * 3 - 1 downto 0 );
              valid_in     : in  std_logic;
              valid_out    : out std_logic;
              output       : out std_logic_vector( 4 - 1 downto 0 )
            );        

  end component defuzzification;

  -- Clock period / 2
  --
  constant T_pw       : time     := 20 ns;
  constant delay_time : time     := 10 ns;
  constant busWidth   : positive := 2;

  -- Define constants for fuzzy logic linguistics
  --
  constant plarge  : std_logic_vector := "000";
  constant pmedium : std_logic_vector := "001";
  constant psmall  : std_logic_vector := "010";
  constant zero    : std_logic_vector := "011";
  constant nsmall  : std_logic_vector := "100";
  constant nmedium : std_logic_vector := "101";
  constant nlarge  : std_logic_vector := "110";

  -- Generated control signals
  --
  signal clock        : std_logic;
  signal reset        : std_logic;

  -- Generated input signals
  --
  signal fuzzy_output : std_logic_vector( 2 downto 0 );
  signal membership   : std_logic_vector( 7 * 3 - 1 downto 0 );
  signal valid_in     : std_logic;
  
  -- Delay the inputs so they aren't changing on the rising edge of the clock
  -- 
  signal fuzzy_output_delayed : std_logic_vector( 2 downto 0 );
  signal membership_delayed   : std_logic_vector( 7 * 3 - 1 downto 0 );
  signal valid_in_delayed     : std_logic;

  -- Outputs don't need to be delayed.
  --
  signal valid_out : std_logic;
  signal output    : std_logic_vector( 4 - 1 downto 0 );

begin

  -- Delay the inputs
  --
  fuzzy_output_delayed <= fuzzy_output after delay_time;
  membership_delayed   <= membership   after delay_time;
  valid_in_delayed     <= valid_in     after delay_time;

  -- Configure a pwm
  --
	dut : defuzzification port map (
                                   clock        => clock,
                                   reset        => reset,
                                   fuzzy_output => fuzzy_output_delayed,
                                   membership   => membership_delayed,
                                   valid_in     => valid_in_delayed,
                                   valid_out    => valid_out,
                                   output       => output
                                 );

	-- clock generator
  --
	clock_gen : process
	begin

		clock <= '0';
    wait for T_pw;
    clock <= '1';
    wait for T_pw;

	end process clock_gen;

	-- process to control the reset signal
  --
	reset_control : process
	begin
		
		-- Reset the circuit
    --
		reset <= '1';
		wait for 4 * T_pw;

    -- Take out of reset
    --
		reset <= '0';
		wait;

	end process reset_control;

	-- process to control data inputs
  --
	input_control : process
	begin

    -- Start with 0's on the lines
    --
    fuzzy_output <= ( others => '0' );
    valid_in     <= '0';
 
    -- Memberships   NL NM NS  Z  PS PM PL
    --
    membership   <= "100110111000001010011";

    -- Start changing on uneven cycles
    --
    wait for T_pw;

    -- Wait for a few clock cycles
    --
    wait for 10 * 2 * T_pw;

    -- Change fuzzy_output to pl
    --
    valid_in     <= '1';
    fuzzy_output <= plarge;
    wait for 4 * 2 * T_pw;


    -- Change fuzzy_output to pm
    --
    fuzzy_output <= pmedium;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy_output to ps
    --
    fuzzy_output <= psmall;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy_output to z
    --
    fuzzy_output <= zero;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy_output to ns
    --
    fuzzy_output <= nsmall;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy_output to nm
    --
    fuzzy_output <= nmedium;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy_output to nl
    --
    fuzzy_output <= nlarge;
    wait for 4 * 2 * T_pw;

    -- Change fuzzy output to pl with not valid
    --
    fuzzy_output <= plarge;
    valid_in     <= '0';

    -- Leave on to see synchronous reset
    --
    wait;

	end process input_control;	

end mixed;