library ieee;
use ieee.std_logic_1164.all;

-- Test Bench
--

entity SolarTracking_tb is
end SolarTracking_tb;

architecture mixed of fuzzification_tb is

component SolarTracking is
	port
	(
		-- INPUTS --   
		clk                        : in std_logic;	
      reset                      : in std_logic;
		                                          ------------------------------------------------
		LDR_ADC1_D1                : in std_logic;--            
		LDR_ADC1_D2                : in std_logic;-- 1.LDR'ye bağlı ADC'den gelen dijital veriler
		LDR_ADC1_D3                : in std_logic;-- 
		LDR_ADC1_D4                : in std_logic;--
		                                          -------------------------------------------------
  		LDR_ADC2_D1                : in std_logic;--
		LDR_ADC2_D2                : in std_logic;-- 2.LDR'ye bağlı ADC'den gelen dijital veriler
		LDR_ADC2_D3                : in std_logic;--
		LDR_ADC2_D4                : in std_logic;--
		                                          -------------------------------------------------		
		LDR_ADC3_D1                : in std_logic;--
		LDR_ADC3_D2                : in std_logic;-- 3.LDR'ye bağlı ADC'den gelen dijital veriler
		LDR_ADC3_D3                : in std_logic;--
		LDR_ADC3_D4                : in std_logic;-- 
		                                          -------------------------------------------------		
		LDR_ADC4_D1                : in std_logic;--
		LDR_ADC4_D2                : in std_logic;-- 4.LDR'ye bağlı ADC'den gelen dijital veriler
		LDR_ADC4_D3                : in std_logic;--
		LDR_ADC4_D4                : in std_logic;--
		                                          -------------------------------------------------
		                                          -------------------------------------------------		
		NTC_ADC_D1                 : in std_logic;--
		NTC_ADC_D2                 : in std_logic;-- NTC'ye bağlı ADC'den gelen dijital veriler
		NTC_ADC_D3                 : in std_logic;--
		NTC_ADC_D4                 : in std_logic;--
		                                          -------------------------------------------------	
		-- OUTPUTS --  
		                                           -------------------------------------------------
      STEP_OUT1                 : out std_logic;--
      STEP_OUT2                 : out std_logic;-- 1.Step Motor Çıkış Pinleri 		
      STEP_OUT3                 : out std_logic;--		
      STEP_OUT4                 : out std_logic --		
		                                           -------------------------------------------------				
	);	                                           
end component;

  -- Clock period / 2
  --
  constant T_pw       : time     := 20 ns;
  constant delay_time : time     := 10 ns;
  constant busWidth   : positive := 2;
  sig
  signal LDR_ADC1_D1                : std_logic;
  signal LDR_ADC1_D2                : std_logic;
  signal LDR_ADC1_D3                : std_logic;
  signal LDR_ADC1_D4                : std_logic;

  signal LDR_ADC2_D1                : std_logic;
  signal LDR_ADC2_D2                : std_logic;
  signal LDR_ADC2_D3                : std_logic;
  signal LDR_ADC2_D4                : std_logic;  
  
  signal LDR_ADC1_D1                : std_logic;
  signal LDR_ADC1_D2                : std_logic;
  signal LDR_ADC1_D3                : std_logic;
  signal LDR_ADC1_D4                : std_logic;  
  
  signal LDR_ADC1_D1                : std_logic;
  signal LDR_ADC1_D2                : std_logic;
  signal LDR_ADC1_D3                : std_logic;
  signal LDR_ADC1_D4                : std_logic;  
  
  signal clock        : std_logic;
  signal reset        : std_logic;
  
  signal LDR_ADC_AVR            : std_logic_vector(3 downto 0);