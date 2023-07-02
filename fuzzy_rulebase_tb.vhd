-------------------------------------------------
-- fuzzy_rulebase_tb.vhd
--
-- Author:   Steve Dillen
-- Date:     November 15, 2000 
-- Course:   EE552
-- Desc:
--
-- This testbench will test the fuzzy rulebase module
--

-- Include ieee std_logic types
--
library ieee;
use ieee.std_logic_1164.all;

-- Test Bench
--
entity fuzzy_rulebase_tb is
end fuzzy_rulebase_tb;

architecture mixed of fuzzy_rulebase_tb is

  component fuzzy_rulebase is

    port    ( clock       : in  std_logic;
              reset       : in  std_logic;
 
              -- There are 7 fuzzy linguistics so we require 3 bits for
              -- representing the fuzzy data
              --
              difference  : in  std_logic_vector( 2 downto 0 );
              integral    : in  std_logic_vector( 2 downto 0 );
              valid_in    : in  std_logic;
              valid_out   : out std_logic;
              control     : out std_logic_vector( 2 downto 0 )
            );

  end component fuzzy_rulebase;

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
  signal difference : std_logic_vector( 2 downto 0 );
  signal integral   : std_logic_vector( 2 downto 0 );
  signal valid_in   : std_logic;
  
  -- Delay the inputs so they aren't changing on the rising edge of the clock
  -- 
  signal difference_delayed : std_logic_vector( 2 downto 0 );
  signal integral_delayed   : std_logic_vector( 2 downto 0 );
  signal valid_in_delayed   : std_logic;

  -- Outputs don't need to be delayed.
  --
  signal valid_out   : std_logic;
  signal control     : std_logic_vector( 2 downto 0 );

begin

  -- Delay the inputs
  --
  difference_delayed <= difference after delay_time;
  integral_delayed   <= integral   after delay_time;
  valid_in_delayed   <= valid_in   after delay_time;

  -- Configure a device
  --
	dut : fuzzy_rulebase port map (
                                  clock       => clock,
                                  reset       => reset,
                                  difference  => difference_delayed,
                                  integral    => integral_delayed,
                                  valid_in    => valid_in_delayed,
                                  valid_out   => valid_out,
                                  control     => control
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

    -- Keep out of reset for the rest of the simulation
    --
    reset <= '0';
		wait;

	end process reset_control;

	-- process to control data inputs
  --
	input_control : process

    procedure test_rule( input_1 : in std_logic_vector( 2 downto 0 );
                         input_2 : in std_logic_vector( 2 downto 0 )
                       ) is
    begin

      difference <= input_1;
      integral   <= input_2;
   
      -- Wait for a few clock cycles, then pulse valid
      --
      wait for 4 * 2 * T_pw;
      valid_in <= '1';
      wait for 2 * T_pw;
      valid_in <= '0';

    end procedure test_rule;

	begin

    -- Start with 0's on the lines
    --
    difference <= plarge;
    integral <= psmall;
    valid_in   <= '0';

    -- Start changing on uneven cycles
    --
    wait for T_pw;

    -- Test all 49 rules
    --
    test_rule( plarge,  plarge  );
    test_rule( plarge,  pmedium );
    test_rule( plarge,  psmall  );
    test_rule( plarge,  zero    );
    test_rule( plarge,  nsmall  );
    test_rule( plarge,  nmedium );
    test_rule( plarge,  nlarge  );
 
    test_rule( pmedium, plarge  );
    test_rule( pmedium, pmedium );
    test_rule( pmedium, psmall  );
    test_rule( pmedium, zero    );
    test_rule( pmedium, nsmall  );
    test_rule( pmedium, nmedium );
    test_rule( pmedium, nlarge  );
 
    test_rule( psmall,  plarge  );
    test_rule( psmall,  pmedium );
    test_rule( psmall,  psmall  );
    test_rule( psmall,  zero    );
    test_rule( psmall,  nsmall  );
    test_rule( psmall,  nmedium );
    test_rule( psmall,  nlarge  );
 
    test_rule( zero,    plarge  );
    test_rule( zero,    pmedium );
    test_rule( zero,    psmall  );
    test_rule( zero,    zero    );
    test_rule( zero,    nsmall  );
    test_rule( zero,    nmedium );
    test_rule( zero,    nlarge  );
 
    test_rule( nsmall,  plarge  );
    test_rule( nsmall,  pmedium );
    test_rule( nsmall,  psmall  );
    test_rule( nsmall,  zero    );
    test_rule( nsmall,  nsmall  );
    test_rule( nsmall,  nmedium );
    test_rule( nsmall,  nlarge  );
 
    test_rule( nmedium, plarge  );
    test_rule( nmedium, pmedium );
    test_rule( nmedium, psmall  );
    test_rule( nmedium, zero    );
    test_rule( nmedium, nsmall  );
    test_rule( nmedium, nmedium );
    test_rule( nmedium, nlarge  );
 
    test_rule( nlarge,  plarge  );
    test_rule( nlarge,  pmedium );
    test_rule( nlarge,  psmall  );
    test_rule( nlarge,  zero    );
    test_rule( nlarge,  nsmall  );
    test_rule( nlarge,  nmedium );
    test_rule( nlarge,  nlarge  );
 
    -- Leave on to see synchronous reset
    --
    wait;

	end process input_control;	

end mixed;