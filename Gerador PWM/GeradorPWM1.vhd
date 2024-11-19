library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GeradorPWM1 is
    Port ( 
        clk_50MHZ : in STD_LOGIC;
		  contador_out : out STD_LOGIC_VECTOR(4 downto 0);
		  pwm_out : out std_LOGIC;
		  button_up: in STD_LOGIC;
		  button_down: in STD_LOGIC
    );
end GeradorPWM1;

architecture Behavioral of GeradorPWM1 is
   
    constant DIVISOR_CLK_PWM : INTEGER := 5000 / 2;
	 constant CONT_MAX_PWM : INTEGER range 0 to 31 := 2**5 - 1;    --5 bits de resolucao
	 constant DIVISOR_CLK_BTN : INTEGER := 5000000 / 2;
    
    signal contador_clk_pwm : INTEGER := 0;
	 signal contador_clk_btn : INTEGER := 0; 
	 signal clk_pwm : STD_LOGIC := '0';
	 signal clk_btn : STD_LOGIC := '0';
	 
	 signal contador_pwm : unsigned (4 downto 0) := to_unsigned(0, 5); 	 
	 signal duty_cycle : unsigned (4 downto 0) := to_unsigned(0, 5); 
    
begin	
    process(clk_50MHZ)
    begin
        if rising_edge(clk_50MHZ) then
            if contador_clk_pwm = DIVISOR_CLK_PWM then
                contador_clk_pwm <= 0;
                clk_pwm <= not clk_pwm; 
            else
                contador_clk_pwm <= contador_clk_pwm + 1;
            end if;	
				
				if contador_clk_btn = DIVISOR_CLK_BTN then
					contador_clk_btn <= 0;
					clk_btn <= not clk_btn;
				else
					contador_clk_btn <= contador_clk_btn + 1;
				end if;
        end if;
    end process;
	 
	 process(clk_pwm)
    begin
        if rising_edge(clk_pwm) then
            if contador_pwm < CONT_MAX_PWM then
                contador_pwm <= contador_pwm + 1;
            else
                contador_pwm <= to_unsigned(0, 5);
            end if;

				contador_out <= std_logic_vector(duty_cycle);
				
				if contador_pwm < duty_cycle then
                pwm_out <= '1';
				else
					pwm_out <= '0';
            end if;
				
        end if;
    end process;
	 
	  -- delay para leitura do botao
	  process(clk_btn)
     begin
        if rising_edge(clk_btn) then
            if button_up = '0' then
					duty_cycle <= duty_cycle + 1;
				end if;
				
				if duty_cycle = to_unsigned(31, 5)  then
					duty_cycle <= to_unsigned(0, 5);
				end if;
				
				if button_down = '0' then
					duty_cycle <= duty_cycle - 1;
				end if;
				
				if duty_cycle < to_unsigned(0, 5)  then
					duty_cycle <= to_unsigned(31, 5);
				end if;
		  end if;
	 end process;
end Behavioral;