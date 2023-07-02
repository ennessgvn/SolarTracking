library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ldr_control is	
	generic(
		clk_freq										: natural
	);
	port( 
	clk                                    : in std_logic;                             -- Sistem Saat Sinyali
	reset                                  : in std_logic;                             -- Sistem Reset Sinyali
   LDR_ADC1_Ds                            : in std_logic_vector(3 downto 0);          -- 1.ADC çıktısından alınan 4 bitlik LDR verisi
   LDR_ADC2_Ds                            : in std_logic_vector(3 downto 0);          -- 2.ADC çıktısından alınan 4 bitlik LDR verisi
   LDR_ADC3_Ds                            : in std_logic_vector(3 downto 0);          -- 3.ADC çıktısından alınan 4 bitlik LDR verisi
   LDR_ADC4_Ds                            : in std_logic_vector(3 downto 0);          -- 4.ADC çıktısından alınan 4 bitlik LDR verisi
	
	LDR_ADC_AVR_Ds                         : out std_logic_vector(3 downto 0)          -- İnteger tipinde ortalaması alınmış ışık verisinin 4 bitlik çıktısı
	    );	
end entity;

architecture rtl of ldr_control is

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

signal tick_10ms,	rst_10ms 	: std_logic;                            -- Gecikmeyi tetikleyen reset ve tick sinyalleri
signal reg_address_int1			: integer range 0 to 15:= 0;           -- 1. LDR verisinin atanacağı intereger tipinde register
signal reg_address_int2			: integer range 0 to 15:= 0;           -- 2. LDR verisinin atanacağı intereger tipinde register	
signal reg_address_int3			: integer range 0 to 15:= 0;           -- 3. LDR verisinin atanacağı intereger tipinde register
signal reg_address_int4			: integer range 0 to 15:= 0;           -- 4. LDR verisinin atanacağı intereger tipinde register
signal reg_address_int_avr    : integer range 0 to 15:= 0;           -- İnteger tipinde ortalamaları alınan 4 registerın ortalaması

begin
  
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
	
  process(all)
  begin
     if(reset = '0') then                                                -- İşlem başlangıcında önce olumsuz durum (reset durumu) kontrol edilir.
	  rst_10ms     		  <='0';                                         -- Reset geldiğinde 10ms'lik gecikme default olarak çalıştırılmaz.
	  reg_address_int1     <= 0;                                          -- Reset geldiğinde 1.LDR için register integer olarak 0'da tutulur.
	  reg_address_int2     <= 0;                                          -- Reset geldiğinde 2.LDR için register integer olarak 0'da tutulur.
     reg_address_int3     <= 0;                                          -- Reset geldiğinde 3.LDR için register integer olarak 0'da tutulur.
	  reg_address_int4     <= 0;                                          -- Reset geldiğinde 4.LDR için register integer olarak 0'da tutulur.
	  reg_address_int_avr  <= 0;                                          -- Reset geldiğinde 4 registerın ortalaması integer olarak 0'da tutulur.
	  LDR_ADC_AVR_Ds       <= "0000";                                     -- Reset geldiğinde ortalama LDR verisinin 4 bitine de '0' atılır.
	  
	  elsif(rising_edge(clk)) then                                        -- İlk saat darbesi geldiğinde
	  reg_address_int1 <= (to_integer(unsigned(LDR_ADC1_Ds)));            -- 4 bitlik 1.LDR verisi integer tipinde bir registera atılır.
	  reg_address_int2 <= (to_integer(unsigned(LDR_ADC2_Ds)));            -- 4 bitlik 2.LDR verisi integer tipinde bir registera atılır.	  
	  reg_address_int3 <= (to_integer(unsigned(LDR_ADC3_Ds)));            -- 4 bitlik 3.LDR verisi integer tipinde bir registera atılır.  
	  reg_address_int4 <= (to_integer(unsigned(LDR_ADC4_Ds)));            -- 4 bitlik 4.LDR verisi integer tipinde bir registera atılır.
	  
	  rst_10ms <= '1';                                                    -- 10ms gecikme sağlandı.
	     if(tick_10ms = '1') then
	     reg_address_int_avr <= (reg_address_int1 + reg_address_int2 + reg_address_int3 + reg_address_int4) / 4;   -- 4 Register adresinin ortalaması alınarak yeni bir registera atandı.
	     LDR_ADC_AVR_Ds      <= std_logic_vector( to_unsigned( reg_address_int_avr, 4));		                     -- Ortalama register değeri integer tipinden binary'ye çevirildi ve çıkış vektörüne atandı.
	     end if;	  
     end if;
  end process;
  
end architecture;	