library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_InvMixColumns is
end tb_InvMixColumns;

architecture Behavioral of tb_InvMixColumns is

    -- Signals for input and output
    signal input_column  : std_logic_vector(31 downto 0); -- 32-bit input column (8 bits per element)
    signal output_column : std_logic_vector(31 downto 0); -- 32-bit output column after transformation

    -- Instantiate the InvMixColumns module
    component InvMixColumns
        port (
            input_column  : in  std_logic_vector(31 downto 0);
            output_column : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    -- Instantiate the UUT (Unit Under Test)
    UUT: InvMixColumns
        port map (
            input_column  => input_column,
            output_column => output_column
        );

    -- Test process for all columns in the given matrix
    process
    begin
        -- Test Case 1: First column (8B, 42, 6D, D5)
        input_column <= x"8B426D00";
        wait for 20 ns;

        -- Test Case 2: Second column (0C, 70, 30, 1F)
        input_column <= x"0C70301F";
        wait for 20 ns;

        -- Test Case 3: Third column (68, 43, 00, 8A)
        input_column <= x"6843008A";
        wait for 20 ns;

        -- Test Case 4: Fourth column (DA, 4E, D7, EE)
        input_column <= x"DA4ED7EE";
        wait for 20 ns;

        wait; -- End simulation
    end process;

end Behavioral;
