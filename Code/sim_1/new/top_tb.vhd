library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    -- Component signals to connect to the TopModule entity
    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal start           : std_logic := '0';
    signal anodes          : std_logic_vector(3 downto 0);
    signal a, b, c, d, e, f, g : std_logic;
--    signal debug_input_vector  : std_logic_vector(31 downto 0);
--    signal debug_display_offset : integer range 0 to 1023;
--    signal debug_phase_counter  : integer range 0 to 3;
--    signal debug_intermediate_vector : std_logic_vector(7 downto 0);
--    signal debug_offset : integer range 0 to 1;
--    signal debug_byte_counter : integer range 0 to 3;
--    signal debug_row_counter : integer range 0 to 3;
--    signal debug_decrypted_data0 : std_logic_vector(31 downto 0);
--    signal debug_decrypted_data1 : std_logic_vector(31 downto 0);
--    signal debug_decrypted_data2 : std_logic_vector(31 downto 0);
--    signal debug_decrypted_data3 : std_logic_vector(31 downto 0);
--    signal debug_ram_addr : std_logic_vector(4 downto 0);
--    signal debug_ram_data_in : std_logic_vector(7 downto 0);
    -- Clock period constant (assuming 100 MHz clock for Basys3 board)
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the TopModule
    uut: entity work.TopModule
        port map (
            clk               => clk,
            reset             => reset,
            start             => start,
            anodes            => anodes,
            a                 => a,
            b                 => b,
            c                 => c,
            d                 => d,
            e                 => e,
            f                 => f,
            g                 => g
--            debug_input_vector => debug_input_vector,
--            debug_display_offset => debug_display_offset,
--            debug_phase_counter => debug_phase_counter,
--            debug_intermediate_vector => debug_intermediate_vector,
--            debug_offset => debug_offset,
--            debug_byte_counter => debug_byte_counter,
--            debug_row_counter => debug_row_counter, 
--           debug_decrypted_data0 => debug_decrypted_data0,
--           debug_decrypted_data1 => debug_decrypted_data1,
--           debug_decrypted_data2 => debug_decrypted_data2,
--           debug_decrypted_data3 => debug_decrypted_data3,
--              debug_ram_addr => debug_ram_addr,
--                debug_ram_data_in => debug_ram_data_in 
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test stimulus process
    stimulus : process
    begin
        -- Apply reset at the beginning
        reset <= '1';
        wait for 20 ns;  -- Hold reset for some time
        reset <= '0';

        -- Start the decryption process
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Observe behavior over a simulated duration
        -- Monitor `debug_input_vector`, `debug_display_offset`, and `debug_phase_counter`
        wait for 1000 ns;  -- Adjust this as needed for longer observation

        -- Stop simulation
        wait;
    end process;

end Behavioral;
