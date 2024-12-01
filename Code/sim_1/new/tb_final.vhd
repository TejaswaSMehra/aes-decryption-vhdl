library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_final is
-- Testbench has no ports
end tb_final;

architecture Behavioral of tb_final is

    -- Component declaration for the unit under test (UUT)
    component final is
        Port (
            inputi   : in  STD_LOGIC_VECTOR (15 downto 0);  -- 4-digit input vector
            clk_ini  : in  STD_LOGIC;
            reseti   : in  STD_LOGIC;
            t        : in  STD_LOGIC_VECTOR (3 downto 0);   -- Control for display visibility
            anodesi  : out STD_LOGIC_VECTOR (3 downto 0);
            aii, bii, cii, dii, eii, fii, gii : out STD_LOGIC
        );
    end component;

    -- Signals to connect to the UUT
    signal inputi   : STD_LOGIC_VECTOR (15 downto 0);
    signal clk_ini  : STD_LOGIC := '0';
    signal reseti   : STD_LOGIC := '0';
    signal t        : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal anodesi  : STD_LOGIC_VECTOR (3 downto 0);
    signal aii, bii, cii, dii, eii, fii, gii : STD_LOGIC;

    -- Clock generation process
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the UUT
    UUT: final
        port map (
            inputi   => inputi,
            clk_ini  => clk_ini,
            reseti   => reseti,
            t        => t,
            anodesi  => anodesi,
            aii      => aii,
            bii      => bii,
            cii      => cii,
            dii      => dii,
            eii      => eii,
            fii      => fii,
            gii      => gii
        );

    -- Clock generation
    clk_process : process
    begin
        clk_ini <= '0';
        wait for clk_period/2;
        clk_ini <= '1';
        wait for clk_period/2;
    end process;

    -- Test process
    stimulus: process
    begin
        -- Reset sequence
        reseti <= '1';
        wait for 10 ns;
        reseti <= '0';

        -- Test Case 1: Valid hexadecimal values, all segments should display normally
        inputi <= "0001001000110100"; -- Corresponds to 0x1234 in binary
        t <= "0000";       -- Enable all displays
        wait for 200 ns;

        -- Test Case 2: Invalid character in third position (disable 3rd digit)
        inputi <= "0001001001110100"; -- "G" represented by binary pattern in third digit
        t <= "0010";       -- Disable third display
        wait for 200 ns;

        -- Test Case 3: All invalid characters (disable all displays)
        inputi <= "1110111111101111"; -- Simulate "ZZZZ" by using binary patterns for invalid values
        t <= "1111";       -- Disable all displays
        wait for 200 ns;

        -- Test Case 4: Mixed valid/invalid (disable first and last displays)
        inputi <= "0001001010111111"; -- Mixed valid (1, F) and invalid (B, Z) patterns
        t <= "0001";       -- Disable first and last displays
        wait for 200 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
