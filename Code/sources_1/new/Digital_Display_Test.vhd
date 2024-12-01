library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DigitalDisplayCycler is
    Port (
        clk          : in  std_logic;  -- 100 MHz clock input
        reset        : in  std_logic;
        anodes       : out std_logic_vector(3 downto 0);
        a, b, c, d, e, f, g : out std_logic  -- 7-segment display outputs
    );
end DigitalDisplayCycler;

architecture Behavioral of DigitalDisplayCycler is
    -- Test vectors to cycle through
    constant vectors : std_logic_vector(127 downto 0) := x"30313233343536373839414243444546";  -- ASCII for "0123", "4567", "89AB", "CDEF"
    
    -- Signals
    signal current_vector : std_logic_vector(31 downto 0); -- Current vector to display
    signal clk_counter    : integer := 0;                  -- Clock cycle counter
    signal vector_index   : integer range 0 to 3 := 0;     -- Index to select one of the four vectors

    -- Clock divider constant (100 million cycles for 1 Hz at 100 MHz)
    constant ONE_SECOND_CYCLES : integer := 100000000;

    -- DigitalDisplay component declaration
    component DigitalDisplay
        Port (
            input_vector : in  std_logic_vector(31 downto 0); -- 32-bit input vector
            clk          : in  std_logic;
            reset        : in  std_logic;
            anodes       : out std_logic_vector(3 downto 0);
--            asci_values  : out std_logic_vector(15 downto 0); -- ASCII values output (can be left unconnected if unused)
            a, b, c, d, e, f, g : out std_logic  -- 7-segment display outputs
        );
    end component;

begin
    -- Process to manage cycling through the vectors
    process(clk, reset)
    begin
        if reset = '1' then
            clk_counter <= 0;
            vector_index <= 0;
        elsif rising_edge(clk) then
            if clk_counter < ONE_SECOND_CYCLES - 1 then
                clk_counter <= clk_counter + 1;
            else
                clk_counter <= 0;  -- Reset the counter after 1 second
                vector_index <= (vector_index + 1) mod 4;  -- Move to the next vector in a loop
            end if;

            -- Select the current vector based on vector_index
            case vector_index is
                when 0 => current_vector <= vectors(127 downto 96); -- "0123"
                when 1 => current_vector <= vectors(95 downto 64);  -- "4567"
                when 2 => current_vector <= vectors(63 downto 32);  -- "89AB"
                when 3 => current_vector <= vectors(31 downto 0);   -- "CDEF"
                when others => current_vector <= (others => '0');
            end case;
        end if;
    end process;

    -- Instantiate the DigitalDisplay component
    display_inst : DigitalDisplay
        port map (
            input_vector => current_vector,
            clk          => clk,
            reset        => reset,
            anodes       => anodes,
--            asci_values  => open,  -- Not needed for display, can be left unconnected
            a            => a,
            b            => b,
            c            => c,
            d            => d,
            e            => e,
            f            => f,
            g            => g
        );

end Behavioral;
