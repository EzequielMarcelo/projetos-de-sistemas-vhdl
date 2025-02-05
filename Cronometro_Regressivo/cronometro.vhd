library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cronometro is
    Port (
        clk_50MHz : in STD_LOGIC;             
        chave_modo : in STD_LOGIC;            
        botao_inc : in STD_LOGIC;             
        botao_dec : in STD_LOGIC;            
		  botao_silenciar : in STD_LOGIC;       
        buzzer : out STD_LOGIC;
		  led : out STD_LOGIC;               
        display : out STD_LOGIC_VECTOR(6 downto 0); 
        digit_select : out STD_LOGIC_VECTOR(3 downto 0) 
    );
end cronometro;

architecture Behavioral of cronometro is

	constant DIVISOR_MULTIPLEX : INTEGER := 50000 / 2;
	signal contador_multiplex : INTEGER := 0;
	signal clk_multiplex : STD_LOGIC := '0';
	signal valor_plotado : std_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal digito1out : std_logic_vector (3 downto 0):= (others => '0'); -- 4bits
	signal digito2out : std_logic_vector (3 downto 0):= (others => '0'); -- 4bits
	
	signal digito_atual : std_lOGIC_VECTOR (1 downto 0) := (others => '0');
	signal digito1 : std_lOGIC_VECTOR (3 downto 0) := (others => '0');
	signal digito2 : std_lOGIC_VECTOR (3 downto 0) := (others => '0');

    constant DIVISOR_1Hz : INTEGER := 50000000 / 2; 
    constant DIVISOR_BEEP : INTEGER := 50000000 / 500; 

    signal contador_1Hz : INTEGER range 0 to DIVISOR_1Hz - 1 := 0;
    signal contador_beep : INTEGER range 0 to DIVISOR_BEEP - 1 := 0;

    signal clk_1Hz : STD_LOGIC := '0';
    signal clk_beep : STD_LOGIC := '0';

    signal contador : INTEGER range 0 to 100 := 0;
    signal beep_ativo : STD_LOGIC := '0';
	 signal buzzer_s : STD_LOGIC := '0';
	 signal botao_pressionado : STD_LOGIC := '0';

    signal valor_display : INTEGER range 0 to 100 := 0;

begin
    
    process(clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            if contador_1Hz = DIVISOR_1Hz - 1 then
                contador_1Hz <= 0;
                clk_1Hz <= not clk_1Hz;
            else
                contador_1Hz <= contador_1Hz + 1;
            end if;
				
				if contador_multiplex = DIVISOR_MULTIPLEX - 1 then
                contador_multiplex <= 0;
                clk_multiplex <= not clk_multiplex;
            else
                contador_multiplex <= contador_multiplex + 1;
            end if;
				
				if contador_beep = DIVISOR_BEEP - 1 then
                contador_beep <= 0;
					 clk_beep <= not clk_beep;					 
            else
                contador_beep <= contador_beep + 1;
            end if;
        end if;
    end process;

    
    process(clk_1Hz)
    begin
        if rising_edge(clk_1Hz) then
            if chave_modo = '1' then
					 beep_ativo <= '0'; 	
                if botao_inc = '0' and contador < 100 then
							contador <= contador + 1;
							digito1 <= digito1 + 1;
							if digito1 = "1001" then
								digito1 <= "0000";
								digito2 <= digito2 + 1;
							end if;
                elsif botao_dec = '0' and contador > 0 then
							contador <= contador - 1;
							digito1 <= digito1 - 1;
							if digito1 = "0000" then
								digito2 <= digito2 - 1;
								digito1 <= "1001";
							end if;
                end if;
            else 
                if contador > 0 then
							beep_ativo <= '0';
							contador <= contador - 1;
							digito1 <= digito1 - 1;
							if digito1 = "0000" then
								digito2 <= digito2 - 1;
								digito1 <= "1001";
							end if;
                else 
						  if botao_pressionado = '1' then
								beep_ativo <= '0';
							else
								beep_ativo <= '1';
						  end if;
                end if;
            end if;
				if botao_silenciar = '0' then
					botao_pressionado <= not botao_pressionado; 
            	end if;
        end if;
    end process;
	 
	 process(clk_beep)
    begin
        if rising_edge(clk_beep) then
            if beep_ativo = '1' then
                buzzer_s <= not buzzer_s;
            else
                buzzer_s <= '0';
            end if;
				buzzer <= buzzer_s;
        end if;
    end process;

	 
	 --varre digito
	 process(clk_multiplex)
	 begin
		  if rising_edge(clk_multiplex) then
				if digito_atual = "01" then
					 digito_atual <= "00";
				else
					digito_atual <= digito_atual + 1;
				end if;
		  end if;
	 end process;
	 
	 -- seleciona o digito a ser plotado
	with digito_atual select
		valor_plotado <=	digito1 when "00", -- Valor a ser plotado recebe valor da unidade
								digito2 when "01", -- Valor a ser plotado recebe valor da dezena
								"0000" when others; -- Plota zero
	
	with valor_plotado select
    display <= "1111110" when "0000",  -- Display mostra 0
                  "0110000" when "0001",  -- Display mostra 1
                  "1101101" when "0010",  -- Display mostra 2
                  "1111001" when "0011",  -- Display mostra 3
                  "0110011" when "0100",  -- Display mostra 4
                  "1011011" when "0101",  -- Display mostra 5
                  "1011111" when "0110",  -- Display mostra 6
                  "1110000" when "0111",  -- Display mostra 7
                  "1111111" when "1000",  -- Display mostra 8
                  "1111011" when "1001",  -- Display mostra 9
                  "1110111" when "1010",  -- Display mostra A
                  "0011111" when "1011",  -- Display mostra B
                  "1001110" when "1100",  -- Display mostra C
                  "0111101" when "1101",  -- Display mostra D
                  "1001111" when "1110",  -- Display mostra E
                  "1000111" when "1111",  -- Display mostra F
                  "0000000" when others;  -- Segments off (all low)

	
	with digito_atual select
        digit_select <= "1110" when "00",  -- Habilita o digito da unidade
								"1101" when "01",  -- Habilita o digito da dezena
								"1011" when "10",  -- Habilita o digito da centena unidades
								"0111" when "11",  -- Habilita o digito do milhar
								"1111" when others;  -- Desabilita todos os digitos
								
end Behavioral;