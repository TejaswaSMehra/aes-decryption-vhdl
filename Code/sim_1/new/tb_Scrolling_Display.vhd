library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scrolling_Display_tb is
end Scrolling_Display_tb;

architecture Behavioral of Scrolling_Display_tb is
    -- Signals to connect to the Scrolling_Display module
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal input1        : std_logic_vector(31 downto 0);
    signal input2        : std_logic_vector(31 downto 0);
    signal input3        : std_logic_vector(31 downto 0);
    signal input4        : std_logic_vector(31 downto 0);
    signal anodes        : std_logic_vector(3 downto 0);
    signal a, b, c, d, e, f, g : std_logic;
--    signal current_input : std_logic_vector(31 downto 0);  -- New signal to observe selected input

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Scrolling_Display component
    uut: entity work.Scrolling_Display
        Port map (
            clk           => clk,
            reset         => reset,
            input1        => input1,
            input2        => input2,
            input3        => input3,
            input4        => input4,
            anodes        => anodes,
            a             => a,
            b             => b,
            c             => c,
            d             => d,
            e             => e,
            f             => f,
            g             => g
--            current_input => current_input   -- Connect the new output
        );

    -- Clock process to generate a clock signal
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process to apply test inputs
    stimulus: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 20 ns;  -- Hold reset for a short time
        reset <= '0';

        -- Initialize inputs with test data
        input1 <= x"61626364";  -- Example data: 54 20 61 63
        input2 <= x"68692072";  -- Example data: 68 69 20 72
        input3 <= x"69737365";  -- Example data: 69 73 73 65
        input4 <= x"73206574";  -- Example data: 73 20 65 74

        -- Run simulation for sufficient time to observe cycling through all inputs
        wait for 40 sec;  -- Adjust time as needed to observe multiple cycles

        -- Stop simulation
        wait;
    end process;
end Behavioral;
