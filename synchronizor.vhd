-- synchronizor.vhd
-- This file implements a synchronization circuit for the inputs.
-- The user can specify how many stages of synchronization (32 max).
-- 

-- Include the standard logic types.
--
library ieee;
use ieee.std_logic_1164.all;

-- Include the mazebot configuration and types
--
library work;
use work.config.all;

-- Define the synchronizor with a default level of 2.
--
entity synchronizor is

  generic( numberOfLevels : positive := 2 );

  port   ( clock        : in  std_logic;
           reset        : in  std_logic;
           input        : in  std_logic;
           output       : out std_logic
         );

end synchronizor;

architecture RTL of synchronizor is

  -- Identify internal signals used for the synchronizor.
  --
  signal internal_input : std_logic_vector( numberOfLevels downto 0 );
  signal resetn         : std_logic;
  signal one_signal     : std_logic;

begin

  -- Invert the reset and preset to get active low signals
  --
  resetn  <= not reset;

  -- Set up the one signal
  --
  one_signal <= '1';

  -- Setup the hard-wired connections for the initial input and
  -- final output
  --
  internal_input( 0 ) <= input;
  output              <= internal_input( numberOfLevels );

  -- Generate the synchronization circuit over the number of levels
  --
  synchronize_circuit : for index in numberOfLevels - 1 downto 0 generate

    -- Generate a D flip flop for each level
    --
    synchronizing_flop : dff port map (
                                        d    => internal_input( index ),
                                        clk  => clock,
                                        clrn => resetn,
                                        prn  => one_signal,
                                        q    => internal_input( index + 1 )
                                      );

  end generate;

end RTL;

