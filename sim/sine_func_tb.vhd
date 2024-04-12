library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_sine_func is
end tb_sine_func;

architecture testbench of tb_sine_func is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal rgb : std_logic_vector(2 downto 0);

    component sine_func
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rgb : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;  -- Adjust the clock period as needed
    constant SIM_TIME : time := 500 ns;   -- Total simulation time

    begin
    UUT : sine_func
        port map (
            clk => clk,
            reset => reset,
            rgb => rgb
        );

    clock_process : process
    begin
        while now < SIM_TIME loop
            clk <= not clk;
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stimulus_process : process
    begin
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        wait for SIM_TIME - CLK_PERIOD;  -- Allow simulation to run

        wait;
    end process;

    end architecture testbench;