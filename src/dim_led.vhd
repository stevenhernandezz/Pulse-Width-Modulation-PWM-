library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dim_led is
    Port ( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        rgb : out std_logic_vector(2 downto 0)
    );
end dim_led;

architecture Behavioral of dim_led is
    component pwm_enhanced is
        generic (
            R : integer := 8
        );
        port (
            clk : in std_logic ;
            reset : in std_logic ;
            dvsr : in std_logic_vector (31 downto 0);
            duty : in std_logic_vector (R downto 0);
            pwm_out : out std_logic
        );
    end component ;

    constant resolution : integer := 8;
    constant gradient_thresh : integer := 2499999;
    signal pwm_out1 : STD_LOGIC;
    signal counter : integer;
    signal gradient_pulse : STD_LOGIC;
    signal duty_cycle : std_logic_vector(resolution downto 0);
    signal duty : STD_LOGIC_VECTOR(resolution downto 0);
    constant diviser : std_logic_vector(31 downto 0) := "00000000000000000000100110000010";
    
begin
--pwm instantiate
     pwm: pwm_enhanced
        generic map (R => resolution)
        port map (clk => clk, 
                  reset => rst, dvsr => diviser, 
                  duty => duty, pwm_out => pwm_out1);
      
    duty <= duty_cycle;
process(clk, rst)
   begin
        if rst = '1' then
            -- reset 
            counter <= 0;
            duty_cycle <= "000000000";
        elsif rising_edge(clk) then
        --This counter is used to control the speed of the gradient effect.
    -- The duty cycle gradually increases until it reaches its maximum value,
            if (counter <= gradient_thresh) then
                counter <= counter + 1;
                gradient_pulse <= '0';
            else
                counter <= 0; 
                gradient_pulse <= '1';
            end if;
            -- Increase duty cycle 
            if gradient_pulse = '1' then
                duty_cycle <= (duty_cycle + 1);
            end if;
            -- Reset duty cycle when it reaches 256
            if duty_cycle = 256 then
                    duty_cycle <= (others => '0');
            end if;
        end if;
    end process; 
    
     -- rgb
     rgb(0) <= pwm_out1;
     rgb(1 downto 2) <= (others => '0');
 
end Behavioral;