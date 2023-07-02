-- defuzzification.vhd
-- This module takes the fuzzy outputs of the fuzzy controller and
-- converts them into crisp outputs
--

-- Include the IEEE standard types
--
library ieee;
use ieee.std_logic_1164.all;

-- Include the mazebot configuration
--
library work;
use work.config.all;

entity defuzzification is

  generic ( busWidth     : positive := 4;
            
            -- Must be less that the busWidth
            --
            fuzzyWidth   : positive := 3
          );

  port    ( clock        : in  std_logic;
            reset        : in  std_logic;
            fuzzy_output : in  std_logic_vector( 2 downto 0 );
            membership   : in  std_logic_vector( 7 * fuzzyWidth - 1 downto 0 );
            valid_in     : in  std_logic;
            valid_out    : out std_logic;
				solarcount   : out integer;
            output       : out std_logic_vector( busWidth - 1 downto 0 )
          );        

end defuzzification;

architecture membership_function of defuzzification is

  -- Define the membership signals
  --
  signal defuzzify_pl     : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_pm     : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_ps     : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_z      : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_ns     : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_nm     : std_logic_vector( fuzzyWidth - 1 downto 0 );
  signal defuzzify_nl     : std_logic_vector( fuzzyWidth - 1 downto 0 );

  -- Define the fuzzy results, there are only 7 of them since
  -- there is only 7 membership functions
  --
  signal fuzzy_result : std_logic_vector( 6 downto 0 );

  -- Define an internal signal to use for synchronizing the circuit
  --
  signal internal_output : std_logic_vector( busWidth - 1 downto 0 );

  signal extend_ones  : std_logic_vector( busWidth - 1 downto fuzzyWidth );
  signal extend_zeros : std_logic_vector( busWidth - 1 downto fuzzyWidth );

begin

  -- Set-up sign extension signals
  --
  extend_ones  <= ( others => '1' );
  extend_zeros <= ( others => '0' );

  -- Set-up the fuzzy ranges.  The membership function that will be used
  -- is a simple rectangle.
  --
  defuzzify_pl <= membership( fuzzyWidth * 1 - 1 downto fuzzyWidth * 0 );
  defuzzify_pm <= membership( fuzzyWidth * 2 - 1 downto fuzzyWidth * 1 );
  defuzzify_ps <= membership( fuzzyWidth * 3 - 1 downto fuzzyWidth * 2 );
  defuzzify_z  <= membership( fuzzyWidth * 4 - 1 downto fuzzyWidth * 3 );
  defuzzify_ns <= membership( fuzzyWidth * 5 - 1 downto fuzzyWidth * 4 );
  defuzzify_nm <= membership( fuzzyWidth * 6 - 1 downto fuzzyWidth * 5 );
  defuzzify_nl <= membership( fuzzyWidth * 7 - 1 downto fuzzyWidth * 6 );

  defuzzify : process

    variable save_output : std_logic_vector( fuzzyWidth - 1 downto 0 );

  begin

    -- Synchronize on clock edge
    --
    wait until rising_edge( clock );

    -- Provide a synchronous reset
    --
    if reset = '1' then

      -- Set internal_output to no change
      save_output := defuzzify_z;

    else

      if    fuzzy_output = plarge  then   -- Çok Yüksek Düzey Motor Fonksiyonu

        save_output := defuzzify_pl;
        solarcount  <= 63;
      elsif fuzzy_output = pmedium then   -- Yüksek Düzey Motor Fonksiyonu

        save_output := defuzzify_pm;
        solarcount  <= 44;
      elsif fuzzy_output = psmall  then   -- Orta Yüksek Düzey Motor Fonksiyonu

        save_output := defuzzify_ps;
        solarcount  <= 30;
      elsif fuzzy_output = zero    then   -- Orta Düzey Motor Fonkisyonu 

        save_output := defuzzify_z;
        solarcount  <= 25;
      elsif fuzzy_output = nsmall  then   -- Orta Düşük Düzey Motor Fonksiyonu

        save_output := defuzzify_ns;
        solarcount  <= 20;
      elsif fuzzy_output = nmedium then   -- Düşük Düzey Motor Fonksiyonu

        save_output := defuzzify_nm;
        solarcount  <= 10;
      elsif fuzzy_output = nlarge  then   -- Çok Düşük Düzey Motor Fonksiyonu

        save_output := defuzzify_nl;
        solarcount  <= 4;
      else                                -- Motor Hareketi Olmayacak

        save_output := defuzzify_z;
        solarcount  <= 0;
      end if;

    end if;

    internal_output( fuzzyWidth - 1 downto 0 ) <= save_output;

    if save_output( fuzzyWidth - 1 ) = '1' then

      -- Sign extend with ones...
      --
      internal_output( busWidth - 1 downto fuzzyWidth ) <= extend_ones;

    else

      -- Sign extend with zeros...
      --
      internal_output( busWidth - 1 downto fuzzyWidth ) <= extend_zeros;

    end if;

  end process defuzzify;

  -- Synchronize the output
  --
  sync_output : lpm_ff generic map ( lpm_width => busWidth )
                       port    map (
                                     data      => internal_output,
                                     clock     => clock,
                                     sclr      => reset,
                                     q         => output
                                   );

  -- Send the valid through the same number of levels
  --
  flop_valid : synchronizor generic map ( numberOfLevels => 2 )
                            port    map ( 
                                          clock          => clock,
                                          reset          => reset,
                                          input          => valid_in,
                                          output         => valid_out
                                        );  

end membership_function;