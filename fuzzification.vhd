-- fuzzification.vhd
-- This module takes the crisp inputs to the fuzzy controller and
-- converts them into fuzzy inputs of the range
-- Positive Large, Positive Medium, Positive Small,
-- Zero,
-- Negative Small, Negative Medium, Negative Large
--

-- Include the IEEE standard types
--
library ieee;
use ieee.std_logic_1164.all;

-- Include the mazebot configuration
--
library work;
use work.config.all;

entity fuzzification is

  generic ( busWidth   : positive := 4;

            -- fuzzyWidth must be less than busWidth
            --
            fuzzyWidth : positive := 3
          );

  port    ( clock      : in  std_logic;
            reset      : in  std_logic;
            data       : in  std_logic_vector( busWidth - 1 downto 0 );
            membership : in  std_logic_vector( 7 * fuzzyWidth - 1 downto 0 );
            valid_in   : in  std_logic;
            valid_out  : out std_logic;
            fuzzy_data : out std_logic_vector( 2 downto 0 )
          );        

end fuzzification;

architecture membership_function of fuzzification is

  -- Define the membership signals
  --
  signal fuzzy_pl     : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_pm     : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_ps     : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_z      : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_ns     : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_nm     : std_logic_vector( busWidth - 1 downto 0 );
  signal fuzzy_nl     : std_logic_vector( busWidth - 1 downto 0 );

  -- Define the fuzzy results, there are only 7 of them since
  -- there is only 7 membership functions
  --
  signal fuzzy_result : std_logic_vector( 6 downto 0 );

  -- Synchronize the data
  --
  signal internal_data : std_logic_vector( 2 downto 0 );

  -- Sign extenstions
  --
  signal extend_ones  : std_logic_vector( busWidth - 1 downto fuzzyWidth );
  signal extend_zeros : std_logic_vector( busWidth - 1 downto fuzzyWidth );

begin

  -- Set-up sign extensions
  --
  extend_ones  <= ( others => '1' );
  extend_zeros <= ( others => '0' );

  -- Set-up the fuzzy ranges.  The membership function that will be used
  -- is a simple rectangle.
  --
  fuzzy_pl( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 1 - 1 downto fuzzyWidth * 0 );
  fuzzy_pm( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 2 - 1 downto fuzzyWidth * 1 );
  fuzzy_ps( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 3 - 1 downto fuzzyWidth * 2 );
  fuzzy_z ( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 4 - 1 downto fuzzyWidth * 3 );
  fuzzy_ns( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 5 - 1 downto fuzzyWidth * 4 );
  fuzzy_nm( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 6 - 1 downto fuzzyWidth * 5 );
  fuzzy_nl( fuzzyWidth - 1 downto 0 ) <= membership( fuzzyWidth * 7 - 1 downto fuzzyWidth * 6 );

  -- Perform sign extensions
  --
  fuzzy_pl( busWidth - 1 downto fuzzyWidth ) <= extend_zeros;
  fuzzy_pm( busWidth - 1 downto fuzzyWidth ) <= extend_zeros;
  fuzzy_ps( busWidth - 1 downto fuzzyWidth ) <= extend_zeros;
  fuzzy_z ( busWidth - 1 downto fuzzyWidth ) <= extend_zeros;
  fuzzy_ns( busWidth - 1 downto fuzzyWidth ) <= extend_ones;
  fuzzy_nm( busWidth - 1 downto fuzzyWidth ) <= extend_ones;
  fuzzy_nl( busWidth - 1 downto fuzzyWidth ) <= extend_ones;

  -- Compare the positive large, medium, and small by looking at the
  -- ageb output.
  --
  compare_pl : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_pl,
                                         aclr               => reset,
                                         clock              => clock,
                                         ageb               => fuzzy_result(0)
                                       );

  compare_pm : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_pm,
                                         aclr               => reset,
                                         clock              => clock,
                                         ageb               => fuzzy_result(1)
                                       );

  compare_ps : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_ps,
                                         aclr               => reset,
                                         clock              => clock,
                                         ageb               => fuzzy_result(2)
                                       );

  -- For the zero bit, compare the aeb output
  --
  compare_z  : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_z,
                                         aclr               => reset,
                                         clock              => clock,
                                         aeb                => fuzzy_result(3)
                                       );

  -- For the ns, nm, nl compare the aleb output
  --
  compare_ns : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_ns,
                                         aclr               => reset,
                                         clock              => clock,
                                         aleb               => fuzzy_result(4)
                                       );

  compare_nm : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_nm,
                                         aclr               => reset,
                                         clock              => clock,
                                         aleb               => fuzzy_result(5)
                                       );

  compare_nl : lpm_compare generic map (
                                         lpm_width          => busWidth,
                                         lpm_representation => "signed",
                                         lpm_pipeline       => 1  
                                       )
                           port    map (
                                         dataa              => data,
                                         datab              => fuzzy_nl,
                                         aclr               => reset,
                                         clock              => clock,
                                         aleb               => fuzzy_result(6)
                                       );

  output : process
  begin

    wait until rising_edge( clock );

    if reset = '1' then

      internal_data <= zero;

    else

      if    fuzzy_result(0) = '1' then

        internal_data <= plarge;

      elsif fuzzy_result(1) = '1' then

        internal_data <= pmedium;

      elsif fuzzy_result(2) = '1' then

        internal_data <= psmall;

      elsif fuzzy_result(3) = '1' then

        internal_data <= zero;

      -- Start with the large one, since it takes priority.
      --
      elsif fuzzy_result(6) = '1' then

        internal_data <= nlarge;

      elsif fuzzy_result(5) = '1' then

        internal_data <= nmedium;

      elsif fuzzy_result(4) = '1' then

        internal_data <= nsmall;

      else

        internal_data <= zero;

      end if;

    end if;

  end process output;

  -- Flop the output to synchronize it
  --
  flop_output : lpm_ff generic map ( lpm_width => fuzzyWidth )
                       port    map (
                                     data      => internal_data,
                                     clock     => clock,
                                     sclr      => reset,
                                     q         => fuzzy_data
                                   );

  -- Send the valid through the same number of levels
  --
  flop_valid : synchronizor generic map ( numberOfLevels => 3 )
                            port    map ( 
                                          clock          => clock,
                                          reset          => reset,
                                          input          => valid_in,
                                          output         => valid_out
                                        );

end membership_function;