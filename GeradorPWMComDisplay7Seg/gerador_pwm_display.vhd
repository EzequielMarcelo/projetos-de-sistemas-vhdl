library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gerador_pwm_display is
	Port(
		clk_50MHz : in STD_LOGIC;
		digit_output : out STD_LOGIC_VECTOR(3 downto 0);
      seg_output : out STD_LOGIC_VECTOR(6 downto 0)
		);

end gerador_pwm_display;

architecture Behavioral of gerador_pwm_display is

constant DIVISOR_MULTIPLEX : INTEGER := 50000 / 2;    

signal contador_multiplex : INTEGER := 0;
signal clk_multiplex : STD_LOGIC := '0';

signal digito_atual : unsigned (1 downto 0) := (others => '0');
signal uni : unsigned (3 downto 0)    := to_unsigned(5, 4);
signal dec : unsigned (3 downto 0)    := to_unsigned(9, 4);
signal cen : unsigned (3 downto 0)    := to_unsigned(0, 4);
signal valor_plotado : unsigned (3 downto 0) := (others => '0');


begin
	process(clk_50MHZ)
		begin
        if rising_edge(clk_50MHZ) then				
				if contador_multiplex = DIVISOR_MULTIPLEX then
                contador_multiplex <= 0;
                clk_multiplex <= not clk_multiplex; 
            else
                contador_multiplex <= contador_multiplex + 1;
            end if;
        end if;
    end process;
	 
	 --varre os digitos
    process(clk_multiplex)
		begin
        if rising_edge(clk_multiplex) then
				if digito_atual >= to_unsigned(3, 2) then
					digito_atual <= (others => '0'); 
				else
					digito_atual <= digito_atual + 1; 
				end if;
        end if;
    end process;
	 
	 -- seleciona o digito a ser plotado
	 with digito_atual select
        valor_plotado <= uni when "00",  -- Valor a ser plotado recebe valor da unidade
								 dec when "01",  -- Valor a ser plotado recebe valor da dezena
								 cen when "10",  -- Valor a ser plotado recebe valor da centena
								 "0000" when others;  -- Plota zero
								
	 -- acende o digito do display a ser plotado
	 with digito_atual select
        digit_output <= "1110" when "00",  -- Habilita o digito da unidade
								"1101" when "01",  -- Habilita o digito da dezena
								"1011" when "10",  -- Habilita o digito da centena
								"1111" when others;  -- Desabilita todos os digitos
	 
	 -- tranforma o valor a ser plotado de bin para 7 seg					 
    with valor_plotado select
        seg_output <= "1111110" when "0000",  -- Display mostra 0
                      "0110000" when "0001",  -- Display mostra 1
                      "1101101" when "0010",  -- Display mostra 2
                      "1111001" when "0011",  -- Display mostra 3
                      "0110011" when "0100",  -- Display mostra 4
                      "1011011" when "0101",  -- Display mostra 5
                      "1011111" when "0110",  -- Display mostra 6
                      "1110000" when "0111",  -- Display mostra 7
                      "1111111" when "1000",  -- Display mostra 8
                      "1111011" when "1001",  -- Display mostra 9
                      "0000000" when others;  -- Segments off (all low)

end Behavioral;