library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scrolling_Display is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        input1        : in  std_logic_vector(31 downto 0);
        input2        : in  std_logic_vector(31 downto 0);
        input3        : in  std_logic_vector(31 downto 0);
        input4        : in  std_logic_vector(31 downto 0);
        anodes        : out std_logic_vector(3 downto 0);
        a, b, c, d, e, f, g : out std_logic;
        cycle_completed : out std_logic  -- New output for cycle completion signal
    );
end Scrolling_Display;

architecture Behavioral of Scrolling_Display is
    signal selected_input : std_logic_vector(31 downto 0);
    signal display_counter : integer range 0 to 100 := 0;  -- Adjusted for 100 MHz clock
    signal current_display : integer range 0 to 3 := 0;
    signal displays_completed : integer range 0 to 4 := 0;  -- Track completed displays
    signal cycle_complete : std_logic := '0';
    -- Component declaration for DigitalDisplay
    component DigitalDisplay
        Port (
            input_vector : in  std_logic_vector(31 downto 0);
            clk          : in  std_logic;
            reset        : in  std_logic;
            anodes       : out std_logic_vector(3 downto 0);
            a, b, c, d, e, f, g : out std_logic
        );
    end component;

begin
    -- Instantiate the DigitalDisplay component
    display_inst : DigitalDisplay
        port map (
            input_vector => selected_input,
            clk          => clk,
            reset        => reset,
            anodes       => anodes,
            a            => a,
            b            => b,
            c            => c,
            d            => d,
            e            => e,
            f            => f,
            g            => g
        );

    -- Process to cycle through inputs every 4-5 seconds and set `cycle_complete`
    cycle_completed <= cycle_complete;
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                display_counter <= 0;
                current_display <= 0;
                displays_completed <= 0;
                cycle_complete <= '0';
                selected_input <= input1;  -- Initialize selected input
            else
                if display_counter = 1000 then  -- Interval for display time
                    display_counter <= 0;
                    current_display <= (current_display + 1) mod 4;  -- Cycle through 0 to 3
                    displays_completed <= displays_completed + 1;  -- Increment completed displays
                    
                    -- Check if all 4 displays have been shown
                    if displays_completed = 4 then
                        cycle_complete <= '1';
                        displays_completed <= 0;  -- Reset completed displays
                    else
                        cycle_complete <= '0';
                    end if;
                else
                    display_counter <= display_counter + 1;
                end if;

                -- Update `selected_input` based on `current_display`
                case current_display is
                    when 0 => selected_input <= input1;
                    when 1 => selected_input <= input2;
                    when 2 => selected_input <= input3;
                    when 3 => selected_input <= input4;
                    when others => selected_input <= input1;  -- Default case
                end case;
            end if;
        end if;
    end process;

end Behavioral;
 