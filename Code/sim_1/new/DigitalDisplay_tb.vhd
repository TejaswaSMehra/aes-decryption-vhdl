library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DigitalDisplay_tb is
end DigitalDisplay_tb;

architecture Behavioral of DigitalDisplay_tb is
    -- Signals for interfacing with DigitalDisplay
    signal input_vector : std_logic_vector(31 downto 0); -- 32-bit input vector for test
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal anodes       : std_logic_vector(3 downto 0);
    signal a, b, c, d, e, f, g : std_logic;  -- Segment outputs for 7-segment display
--    signal byte_vector : std_logic_vector(7 downto 0) := "11110111" ;
    -- New signal to observe ascii_values
--    signal ascii_values : std_logic_vector(15 downto 0);

    -- Instantiate the DigitalDisplay module
    component DigitalDisplay
        Port (
            input_vector : in  std_logic_vector(31 downto 0);
            clk          : in  std_logic;
            reset        : in  std_logic;
            anodes       : out std_logic_vector(3 downto 0);
            a, b, c, d, e, f, g : out std_logic
--            asci_values : out std_logic_vector(15 downto 0)  -- New port for ASCII output
        );
    end component;

begin
    -- Clock process for generating 100MHz clock signal
    clk_process : process
    begin
        clk <= not clk after 5 ns;
        wait for 5 ns;
    end process;

    -- Instantiate DigitalDisplay for testing
    uut: DigitalDisplay
        port map (
            input_vector => input_vector,
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
--            asci_values => ascii_values  -- Map ascii_values signal
        );

    -- Test process to provide different input values
    process
    begin
        -- Test case 1: All valid hexadecimal characters
        input_vector <= x"61323334";  -- ASCII for '1', '2', '3', '4'
        wait for 1000 ns;

        -- Test case 2: Mixed valid and invalid hex characters
        input_vector <= x"42323A3F";  -- ASCII for 'A', '2', ':' (invalid), '?' (invalid)
        wait for 1000 ns;

        -- Test case 3: All non-hexadecimal characters
        input_vector <= x"3A3F7E5E";  -- ASCII for ':', '?', '~', '^' (all invalid for hex)
        wait for 1000 ns;

        -- Test case 4: Edge case with ASCII characters '0' to 'F'
        input_vector <= x"30394646";  -- ASCII for '0', '9', 'F', 'F'
        wait for 1000 ns;

        -- Reset signal to simulate a reset behavior
        reset <= '1';
        wait for 200 ns;
        reset <= '0';

        -- Additional test case after reset: Lowercase hex letters
        input_vector <= x"61626364";  -- ASCII for 'a', 'b', 'c', 'd'
        wait for 1000 ns;

        wait;
    end process;

end Behavioral;
