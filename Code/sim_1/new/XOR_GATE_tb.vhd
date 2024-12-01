library ieee;
use ieee.std_logic_1164.all;

-- Testbench for the 8-bit XOR gate
entity tb_xor_gate_8bit is
end tb_xor_gate_8bit;

architecture Behavioral of tb_xor_gate_8bit is

    -- Component declaration for xor_gate_8bit
    component xor_gate_8bit
        port(
            a      : in std_logic_vector(7 downto 0);
            b      : in std_logic_vector(7 downto 0);
            result : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals to connect to the XOR gate
    signal a      : std_logic_vector(7 downto 0);
    signal b      : std_logic_vector(7 downto 0);
    signal result : std_logic_vector(7 downto 0);

begin

    -- Instantiate the XOR gate
    uut: xor_gate_8bit
        port map(
            a => a,
            b => b,
            result => result
        );

    -- Test process
    process
    begin
        -- Test case 1: XOR two different 8-bit inputs
        a <= "10101010";  -- Input A
        b <= "11001100";  -- Input B
        wait for 10 ns;   -- Wait for 10 ns to observe the result

        -- Test case 2: XOR two equal inputs
        a <= "11110000";
        b <= "11110000";
        wait for 10 ns;

        -- Test case 3: XOR with all 1s
        a <= "00001111";
        b <= "11111111";
        wait for 10 ns;

        -- Test case 4: XOR with all 0s
        a <= "00000000";
        b <= "00000000";
        wait for 10 ns;

        -- Stop the simulation
        wait;
    end process;

end Behavioral;
