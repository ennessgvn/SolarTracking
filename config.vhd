-- config.vhd
--
-- This file includes all the system modules that are used commonly across
-- the Mazebot components.
--

library ieee;
use ieee.std_logic_1164.all;

package config is

  -- Define constants for fuzzy logic linguistics
  --
  constant plarge  : std_logic_vector := "000";
  constant pmedium : std_logic_vector := "001";
  constant psmall  : std_logic_vector := "010";
  constant zero    : std_logic_vector := "011";
  constant nsmall  : std_logic_vector := "100";
  constant nmedium : std_logic_vector := "101";
  constant nlarge  : std_logic_vector := "110";

  -- Define useful components
  -- These are placed here for a quick reference for what parameter's
  -- exist so I don't have to keep checking the help menu
  --
  component synchronizor is

    generic( numberOfLevels : positive := 2 );

    port   ( clock        : in  std_logic;
             reset        : in  std_logic;
             input        : in  std_logic;
             output       : out std_logic
           );

  end component synchronizor;

  component lpm_counter

    generic ( 
              lpm_width     : positive;
              lpm_modulus   : natural := 0;
              lpm_direction : string := "UNUSED";
              lpm_avalue    : string := "UNUSED";
              lpm_svalue    : string := "UNUSED";
              lpm_pvalue    : string := "UNUSED";
              lpm_type      : string := "LPM_COUNTER";
              lpm_hint      : string := "UNUSED"
            );

    port    (
              data          : in  std_logic_vector( lpm_width - 1 downto 0 ) := ( others => '0' );
              clock         : in  std_logic;
              cin           : in  std_logic := '0';
              clk_en        : in  std_logic := '1';
              cnt_en        : in  std_logic := '1';
              updown        : in  std_logic := '1';
              sload         : in  std_logic := '0';
              sset          : in  std_logic := '0';
              sclr          : in  std_logic := '0';
              aload         : in  std_logic := '0';
              aset          : in  std_logic := '0';
              aclr          : in  std_logic := '0';
              cout          : out std_logic := '0';
              q             : out std_logic_vector( lpm_width - 1 downto 0 )
            );

  end component lpm_counter;

  component lpm_ff

    generic ( 
              lpm_width  : positive;
              lpm_avalue : string := "UNUSED";
              lpm_pvalue : string := "UNUSED";
              lpm_fftype : string := "DFF";
              lpm_type   : string := "LPM_FF";
              lpm_svalue : string := "UNUSED";
              lpm_hint   : string := "UNUSED"
            );

    port    ( 
              data       : in  std_logic_vector( lpm_width - 1 downto 0 );
              clock      : in  std_logic;
              enable     : in  std_logic := '1';
              sload      : in  std_logic := '0';
              sclr       : in  std_logic := '0';
              sset       : in  std_logic := '0';
              aload      : in  std_logic := '0';
              aclr       : in  std_logic := '0';
              aset       : in  std_logic := '0';
              q          : out std_logic_vector( lpm_width - 1 downto 0 )
            );

  end component lpm_ff;

  component lpm_add_sub

    generic (
              lpm_width          : positive;
              lpm_representation : string  := "SIGNED";
              lpm_direction      : string  := "UNUSED";
              lpm_pipeline       : integer := 0;
              lpm_type           : string  := "LPM_ADD_SUB";
              lpm_hint           : string  := "UNUSED"
            );

    port    (
              dataa   : in  std_logic_vector( lpm_width - 1 downto 0 ); 
              datab   : in  std_logic_vector( lpm_width - 1 downto 0 );
              aclr    : in  std_logic := '0'; 
              clock   : in  std_logic := '0'; 
              cin     : in  std_logic := '0';
              add_sub : in  std_logic := '1';
              clken   : in  std_logic := '1';
              result  : out std_logic_vector( lpm_width - 1 downto 0 );
              cout    : out std_logic;
              overflow: out std_logic
            );

  end component lpm_add_sub;

  component lpm_compare

    generic ( 
              lpm_width          : positive;
              lpm_representation : string  := "UNSIGNED";
              lpm_pipeline       : integer := 0;
              lpm_type           : string  := "LPM_COMPARE";
              lpm_hint           : string  := "UNUSED");

    port    ( dataa : in  std_logic_vector( lpm_width - 1 downto 0 );
              datab : in  std_logic_vector( lpm_width - 1 downto 0 );
              aclr  : in  std_logic := '0';
              clock : in  std_logic := '0';
              clken : in  std_logic := '1';
              agb   : out std_logic;
              ageb  : out std_logic;
              aeb   : out std_logic;
              aneb  : out std_logic;
              alb   : out std_logic;
              aleb  : out std_logic
            );

  end component lpm_compare;

  component dff

    port    (
              d    : in  std_logic;
              clk  : in  std_logic;
              clrn : in  std_logic;
              prn  : in  std_logic;
              q    : out std_logic 
            );

  end component dff;

  component mazebot_dff is

    port    ( 
              clock  : in  std_logic;
              reset  : in  std_logic;
              enable : in  std_logic;
              d      : in  std_logic;
              q      : out std_logic
            );

  end component mazebot_dff;

end package config;