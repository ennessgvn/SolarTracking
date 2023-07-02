-- controller.vhd
-- This module will control the speed of the motors.  The inputs to this
-- module will be either the actual velocity of the motors, and the velocity
-- we would like to control to.
--

-- Include the IEEE standard types
--
library ieee;
use ieee.std_logic_1164.all;

-- Include the mazebot configuration
--
library work;
use work.config.all;

entity fuzzy_controller is

  generic ( busWidth         : positive := 4;
            -- Due to a compile bug with MaxPlus2, this must be specified to be
            -- busWidth + 1.
            --
            extendedBusWidth : positive := 5;

            fuzzyInWidth     : positive := 3;
            fuzzyOutWidth    : positive := 3
          );

  port    ( clock            : in  std_logic;
            reset            : in  std_logic;
            data_a           : in  std_logic_vector( busWidth - 1 downto 0 );
            data_b           : in  std_logic_vector( busWidth - 1 downto 0 );
            reference        : in  std_logic_vector( busWidth - 1 downto 0 );
            diff_membership  : in  std_logic_vector( 7 * fuzzyInWidth - 1 downto 0 );
            int_membership   : in  std_logic_vector( 7 * fuzzyInWidth - 1 downto 0 );
            pwm_membership   : in  std_logic_vector( 7 * fuzzyOutWidth - 1 downto 0 );
            valid_in         : in  std_logic;
            valid_out        : out std_logic;
				counter_step     : out integer;
            control          : out std_logic_vector( busWidth - 1 downto 0 );
            fuzzy_out        : out std_logic_vector( 2 downto 0 );
            fuzzy_in         : out std_logic_vector( 2 downto 0 )
          );        

end fuzzy_controller;

-- Different control schemes can be implemented in different
-- architectures
--
architecture fuzzy of fuzzy_controller is

  component fuzzification is

    generic ( busWidth   : positive;
              fuzzyWidth : positive
            );

    port    ( clock      : in  std_logic;
              reset      : in  std_logic;
              data       : in  std_logic_vector( busWidth - 1 downto 0 );
              membership : in  std_logic_vector( 7 * fuzzyWidth - 1 downto 0 );
              valid_in   : in  std_logic;
              valid_out  : out std_logic;
              fuzzy_data : out std_logic_vector( 2 downto 0 )
            );        

  end component fuzzification;

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

  component defuzzification is

    generic ( busWidth     : positive;
              fuzzyWidth   : positive
            );

    port    ( clock        : in  std_logic;
              reset        : in  std_logic;
              fuzzy_output : in  std_logic_vector( 2 downto 0 );
              membership   : in  std_logic_vector( 7 * fuzzyWidth - 1 downto 0 );
              valid_in     : in  std_logic;
			  	  solarcount   : out integer;
              valid_out    : out std_logic;
              output       : out std_logic_vector( busWidth - 1 downto 0 )
            );        

  end component defuzzification;
 
  -- Internal signals used to connect input to fuzzification
  --
  signal internal_difference        : std_logic_vector( busWidth downto 0 );
  signal internal_integral          : std_logic_vector( busWidth downto 0 );
 
  -- Internal signals used to connect fuzzification to rulebase
  --
  signal internal_fuzzy_difference  : std_logic_vector( 2 downto 0 );
  signal internal_fuzzy_integral    : std_logic_vector( 2 downto 0 );

  -- Internal signals used to connect rulebase to defuzzification
  --
  signal internal_fuzzy_control     : std_logic_vector( 2 downto 0 );

  -- Define internal connections for all the valid signals
  --
  signal input_valid        : std_logic;
  signal fuzzy_inputa_valid : std_logic;
  signal fuzzy_inputb_valid : std_logic;
  signal fuzzy_input_valid  : std_logic;
  signal fuzzy_output_valid : std_logic;

  -- Define internal output signals
  --
  signal internal_control_valid : std_logic;
  signal internal_control       : std_logic_vector( busWidth - 1 downto 0 );


begin

  input_valid         <= '1';
  internal_difference <= "01001";
  internal_integral   <= "10010";

  -- Fuzzify the inputs
  --
  fuzzify_diff : fuzzification generic map ( 
                                             busWidth   => extendedBusWidth,
                                             fuzzyWidth => fuzzyInWidth
                                           )
                               port    map (
                                             clock      => clock,
                                             reset      => reset,
                                             data       => internal_difference,
                                             membership => diff_membership,
                                             valid_in   => input_valid,
                                             valid_out  => fuzzy_inputa_valid,
                                             fuzzy_data => internal_fuzzy_difference
                                           );

  fuzzy_in <= internal_fuzzy_difference;

  fuzzify_delta : fuzzification generic map ( 
                                              busWidth   => extendedBusWidth,
                                              fuzzyWidth => fuzzyInWidth
                                            )
                                port    map (
                                              clock      => clock,
                                              reset      => reset,
                                              data       => internal_integral,
                                              membership => int_membership,
                                              valid_in   => input_valid,
                                              valid_out  => fuzzy_inputb_valid,
                                              fuzzy_data => internal_fuzzy_integral
                                            );

  -- Generate valid signal mux's
  --
  fuzzy_input_valid  <= fuzzy_inputa_valid and fuzzy_inputb_valid;

  -- Determine the fuzzy outputs
  --
  f_control : fuzzy_rulebase port    map ( 
                                           clock       => clock,
                                           reset       => reset,
                                           difference  => internal_fuzzy_difference,
                                           integral    => internal_fuzzy_integral,
                                           valid_in    => fuzzy_input_valid,
                                           valid_out   => fuzzy_output_valid,
                                           control     => internal_fuzzy_control
                                         );

  fuzzy_out <= internal_fuzzy_control;

  -- De-fuzzify the outputs
  --
  crisp : defuzzification generic map ( 
                                        busWidth     => busWidth,
                                        fuzzyWidth   => fuzzyOutWidth
                                      )
                          port    map (
                                        clock        => clock,
                                        reset        => reset,
                                        fuzzy_output => internal_fuzzy_control,
                                        membership   => pwm_membership,
                                        valid_in     => fuzzy_output_valid,
													 solarcount   => counter_step,
                                        valid_out    => internal_control_valid,
                                        output       => internal_control
                                      );

  -- Flop valid out, along with the output data to keep the same number of 
  -- clocks
  --
  flop_valid_out : synchronizor generic map ( numberOfLevels => 1 )
                                port    map (
                                              clock          => clock,
                                              reset          => reset,
                                              input          => internal_control_valid,
                                              output         => valid_out
                                            );

  flop_outputa : lpm_ff generic map ( lpm_width => busWidth )
                        port    map (
                                      data      => internal_control,
                                      clock     => clock,
                                      sclr      => reset,
                                      q         => control
                                    );

end fuzzy;