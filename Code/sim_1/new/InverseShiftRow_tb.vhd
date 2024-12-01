library ieee;
use ieee.std_logic_1164.all;

entity InverseShiftRow_tb is
end InverseShiftRow_tb;

architecture Behavioral of InverseShiftRow_tb is
    -- Component declaration of the UUT (Unit Under Test)
    component InverseShiftRows
        port(
            state   : in std_logic_vector(31 downto 0);
            s       : in std_logic_vector(1 downto 0);
            result  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Test signals
    signal state   : std_logic_vector(31 downto 0) := (others => '0');
    signal s       : std_logic_vector(1 downto 0) := "00";
    signal result  : std_logic_vector(31 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: InverseShiftRows
        port map (
            state   => state,
            s       => s,
            result  => result
        );

    -- Test process
    process
    begin
        -- Test Case 1: No Shift (s = "00")
        state <= x"11223344";
        s <= "00";
        wait for 10 ns;
        assert (result = x"11223344") report "Test Case 1 failed" severity error;

        -- Test Case 2: Shift 1 byte to the right (s = "01")
        state <= x"11223344";
        s <= "01";
        wait for 10 ns;
        assert (result = x"44112233") report "Test Case 2 failed" severity error;

        -- Test Case 3: Shift 2 bytes to the right (s = "10")
        state <= x"11223344";
        s <= "10";
        wait for 10 ns;
        assert (result = x"33441122") report "Test Case 3 failed" severity error;

        -- Test Case 4: Shift 3 bytes to the right (s = "11")
        state <= x"11223344";
        s <= "11";
        wait for 10 ns;
        assert (result = x"22334411") report "Test Case 4 failed" severity error;

        -- Simulation complete
        report "Test completed successfully" severity note;
        wait;
    end process;

end Behavioral;
