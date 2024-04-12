library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity sine_func is
    Port ( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        rgb : out STD_LOGIC_VECTOR(2 downto 0)
    );
end sine_func;

architecture Behavioral of sine_func is
--instantiate pwm enhanced
    component pwm_enhanced is
        generic (
            R : integer := 8
        );
        port(
            clk : in std_logic ;
            reset : in std_logic ;
            dvsr : in std_logic_vector (31 downto 0);
            duty : in std_logic_vector (R downto 0);
            pwm_out : out std_logic
        );
    end component ;

--signals
    constant resolution : integer := 8;
    
    signal addr: unsigned(resolution-1 downto 0);

    subtype addr_range is integer range 0 to 2**resolution - 1;

    type rom_type is array (addr_range) of unsigned(resolution - 1 downto 0);

    function init_rom return rom_type is
        variable rom_v : rom_type;
        variable angle : real;
        variable sin_scaled : real;
    begin
        for i in addr_range loop
            angle := real(i) * ((2.0 * MATH_PI) / 2.0**resolution);
            sin_scaled := (1.0 + sin(angle)) * (2.0**resolution - 1.0) / 2.0;
            rom_v(i) := to_unsigned(integer(round(sin_scaled)), resolution);
        end loop;
        return rom_v;
    end init_rom;
    
    signal counter: integer;
    constant clk_50hz_thresh : integer := 1250000;
    signal clk_50hz: std_logic := '0';
    signal sin_data: unsigned(resolution-1 downto 0);
    signal pwm_out_init1: std_logic;
    signal pwm_out_init2: std_logic;
    signal duty_cycle: std_logic_vector(resolution downto 0);
    signal duty_cycle_sine: std_logic_vector(resolution downto 0);
    --4882
    constant diviser : std_logic_vector(31 downto 0) := "00000000000000000000100110000010";
    constant rom : rom_type := init_rom;  
    signal red_led: std_logic;

    
begin
 --port mapping for pwm
    pwm1: pwm_enhanced 
        generic map(R => resolution)
        port map (clk => clk,
                  reset => rst,
                  dvsr => diviser,
                  duty => duty_cycle,
                  pwm_out => pwm_out_init1);
    pwm2: pwm_enhanced  
        generic map(R => resolution)
        port map (clk => clk,
                  reset => rst,
                  dvsr => diviser,
                  duty => duty_cycle_sine,
                  pwm_out => pwm_out_init2);
--50hz clk 
    process(clk, rst)
    begin 
        if(rst = '1') then 
          counter <= 0;
          clk_50hz <= '0';
         elsif rising_edge (clk) then
          if counter < clk_50hz_thresh then
           counter <= counter + 1;
           clk_50hz <= '1';
          else 
            counter <= 0;
            clk_50hz <= '0';
            end if;
       end if;
end process;
 
--duty cycle 
--changes duty cycle to generate differnet output
  --percentage of time a periodic pulse train is 1
 
process(clk_50hz, rst)
    begin 
        if (rst = '1') then 
            --resetting to all 0's if reset
            duty_cycle <= (others => '0');
            elsif rising_edge(clk_50hz) then
            --checking the duty cycle is within range
            if unsigned(duty_cycle) <= 2**resolution then
            --increment duty cycle
            duty_cycle <= std_logic_vector(unsigned(duty_cycle)+1);
            else 
             duty_cycle <= (others => '0');
         end if;
       end if;
 end process;

      --duty cycle 2 (sine wave)
process(clk, rst)
begin
    if rst = '1' then
        duty_cycle_sine <= (others=>'0');
    elsif rising_edge(clk) then
        if clk_50Hz = '1' then
        -- Increment the duty cycle only when the 50Hz clock is high
            if unsigned(duty_cycle_sine) <= 2**resolution then
             -- Increment duty cycle and fetching corresponding sine value
                addr <= addr + 1;
                sin_data <= rom(to_integer(addr));
                duty_cycle_sine <= '0' & std_logic_vector(unsigned(sin_data));
            else
            -- Reset duty cycle when reaches its maximum 
                duty_cycle_sine <= (others=>'0');
            end if;
        end if;
    end if;
end process;          
     
   process(clk_50Hz, rst)
begin
    if rst = '1' then
        -- Reset  
        red_led <= '0';
    elsif rising_edge(clk_50Hz) then
        red_led <= pwm_out_init2;  -- PWM sine signal for the red LED

            -- Turn off green and blue LEDs
            rgb(1) <= '0';
            rgb(2) <= '0';
        end if;
    end process;


rgb(0) <= red_led;
end Behavioral;