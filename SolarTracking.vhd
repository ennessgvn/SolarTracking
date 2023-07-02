library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SolarTracking is
	generic(
		clk_freq										: natural:= 25e6
	);
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
end entity;	
		
architecture rtl of SolarTracking is				
	
component ldr_control	
	generic(
		clk_freq										: natural
	);
	port(
	clk                                    : in std_logic;
	reset                                  : in std_logic;
   LDR_ADC1_Ds                            : in std_logic_vector(3 downto 0);
   LDR_ADC2_Ds                            : in std_logic_vector(3 downto 0);
   LDR_ADC3_Ds                            : in std_logic_vector(3 downto 0);
   LDR_ADC4_Ds                            : in std_logic_vector(3 downto 0);
	
	LDR_ADC_AVR_Ds                         : out std_logic_vector(3 downto 0)
	    );	
end component;	
	
component timer  
	generic(                                                           ------------------------------------------------------------
		clk_frequency 	: integer; -- clock frequency in Hz              ------------------------------------------------------------
		timer_value   	: integer  -- timer in microseconds (us)         --
	);                                                                 --
	port(                                                              --  10ms'lik gecikmenin yer aldığı bileşen bloğu 
		clk 				: in 	std_logic;                                 --
		reset		   	: in 	std_logic;                                 --
		timer_tick		: out std_logic                                  ------------------------------------------------------------
	);                                                                 ------------------------------------------------------------
end component;	
	
component fuzzy_controller 

  generic ( busWidth         : positive := 4;

            -- Due to a compile bug with MaxPlus2, this must be specified to be
            -- busWidth + 1.        --
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

end component;
signal      count            : integer;
signal      cnt              : integer  := 0;
constant    busWidth         : positive := 4;
constant    extendedBusWidth : positive := 5;
constant    fuzzyInWidth     : positive := 3;
constant    fuzzyOutWidth    : positive := 3;

signal LDR_ADC_AVR            : std_logic_vector(3 downto 0);
signal step_motor             : std_logic_vector(3 downto 0);
           
signal tick_10ms,	rst_10ms 	: std_logic;                                    -- Gecikmeyi tetikleyen reset ve tick sinyalleri			  
signal data_a           : std_logic_vector( busWidth - 1 downto 0 );
signal data_b           : std_logic_vector( busWidth - 1 downto 0 );
signal reference        : std_logic_vector( busWidth - 1 downto 0 );
signal diff_membership  : std_logic_vector( 7 * fuzzyInWidth - 1 downto 0 );
signal int_membership   : std_logic_vector( 7 * fuzzyInWidth - 1 downto 0 );
signal pwm_membership   : std_logic_vector( 7 * fuzzyOutWidth - 1 downto 0 );
signal valid_in         : std_logic;
signal valid_out        : std_logic;
signal control          : std_logic_vector( busWidth - 1 downto 0 );
signal fuzzy_out        : std_logic_vector( 2 downto 0 );
signal fuzzy_in         : std_logic_vector( 2 downto 0 );

begin
  
	STEP_OUT1   <= step_motor(0);
	STEP_OUT2   <= step_motor(1);
	STEP_OUT3   <= step_motor(2);
	STEP_OUT4   <= step_motor(3);	
	
   ldr: ldr_control
	generic map(
	   clk_freq       => clk_freq
	)
   port map(
	   clk               => clk,
		Reset             => reset,
      LDR_ADC1_Ds(0)    => LDR_ADC1_D1,
      LDR_ADC1_Ds(1)    => LDR_ADC1_D2,
      LDR_ADC1_Ds(2)    => LDR_ADC1_D3,
      LDR_ADC1_Ds(3)    => LDR_ADC1_D4,
      LDR_ADC2_Ds(0)    => LDR_ADC2_D1,
      LDR_ADC2_Ds(1)    => LDR_ADC2_D2,
      LDR_ADC2_Ds(2)    => LDR_ADC2_D3,
      LDR_ADC2_Ds(3)    => LDR_ADC2_D4,
      LDR_ADC3_Ds(0)    => LDR_ADC3_D1,
      LDR_ADC3_Ds(1)    => LDR_ADC3_D2,
      LDR_ADC3_Ds(2)    => LDR_ADC3_D3,
      LDR_ADC3_Ds(3)    => LDR_ADC3_D4,
      LDR_ADC4_Ds(0)    => LDR_ADC4_D1,
      LDR_ADC4_Ds(1)    => LDR_ADC4_D2,
      LDR_ADC4_Ds(2)    => LDR_ADC4_D3,
      LDR_ADC4_Ds(3)    => LDR_ADC4_D4,
		
      LDR_ADC_AVR_Ds    => LDR_ADC_AVR		
   );
	
   timer_10ms: timer
   generic map(
	clk_frequency 	=> clk_freq,
	timer_value 	=> 10000 
	)
	port map(
		clk 				=> clk,
		reset 			=> rst_10ms,
		timer_tick 		=> tick_10ms
	);  	

	flc: fuzzy_controller
	generic map(
		busWidth										=> busWidth,
		extendedBusWidth							=> extendedBusWidth,
		fuzzyInWidth								=> fuzzyInWidth,
		fuzzyOutWidth								=> fuzzyOutWidth
	)
	port map(  
      clock  => clk,
      reset  => reset,
      data_a  => LDR_ADC_AVR,
      data_b(0)  => NTC_ADC_D1,
      data_b(1)  => NTC_ADC_D2,
      data_b(2)  => NTC_ADC_D3,
      data_b(3)  => NTC_ADC_D4,
		reference  => reference,
      diff_membership  => diff_membership,
      int_membership  => int_membership,
      pwm_membership  => pwm_membership,
      valid_in  => valid_in,
      valid_out  => valid_out,
		counter_step   => count,
      control  => control,
      fuzzy_out  => fuzzy_out,
      fuzzy_in  => fuzzy_in
		
	);    
		
   process(all)
	begin
	   if rising_edge(clk) then
		   if(reset = '1') then
			step_motor  <= "0000";
			else
	         if(fuzzy_out = "000") then          -- Çok Düşük Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;
			      end if;
            elsif(fuzzy_out = "001") then       -- Düşük Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;	 
			      end if;
            elsif(fuzzy_out = "010") then       -- Orta Düşük Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;		 
			      end if; 
            elsif(fuzzy_out = "011") then       -- Orta Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;		 
			      end if; 
            elsif(fuzzy_out = "100") then       -- Orta Yüksek Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;		 
			      end if;			 
            elsif(fuzzy_out = "101") then       -- Yüksek Düzeyli Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;		 
			      end if;			 
            elsif(fuzzy_out = "110") then       -- Çok Yüksek Motor Fonksiyonu
		         if( cnt = count ) then	
					    cnt <= 0;
					else 
					    step_motor <= "1001";        -- 90 derece dönüş
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           
					    step_motor <= "1010";        -- 90 derece dönüş
                   end if;   
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						 
					    step_motor <= "0110";        -- 90 derece dönüş
                   end if; 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then           						            
					    step_motor <= "0101";        -- 90 derece dönüş
                   end if; 
						 
	                rst_10ms <= '1';             -- 10ms gecikme sağlandı.
	                if(tick_10ms = '1') then                     
						 cnt <= cnt + 1;	
						 end if;	 
		         end if;
				step_motor <= "0000";
				cnt <= 0;				
				end if;
			end if;
		end if;    
	end process;
end rtl;		
		
		




		
		