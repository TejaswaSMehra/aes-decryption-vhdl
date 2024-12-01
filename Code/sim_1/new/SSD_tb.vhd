library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
    -- Testbench does not have ports
end testbench;

architecture tb of testbench is

    -- Component Declaration
    component seven_segment_decoder
        Port (
            input : in STD_LOGIC_VECTOR (3 downto 0);
            ai, bi, ci, di, ei, fi, gi : out STD_LOGIC;
            t : in STD_LOGIC
        );
    end component;

    -- Signals for connecting to the DUT
    signal input : STD_LOGIC_VECTOR (3 downto 0);
    signal ai, bi, ci, di, ei, fi, gi : STD_LOGIC;
    signal t : STD_LOGIC;  -- Make sure `t` is used as an input

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: seven_segment_decoder
        Port map (
            input => input,
            ai => ai,
            bi => bi,
            ci => ci,
            di => di,
            ei => ei,
            fi => fi,
            gi => gi,
            t => t
        );

    -- Test process
    process
    begin
        -- Apply test vectors with `t` as '0' (normal display)
        t <= '0';
        
        input <= "0000"; -- Test case 1: Display "0"
        wait for 10 ns;

        input <= "0001"; -- Test case 2: Display "1"
        wait for 10 ns;

        input <= "0010"; -- Test case 3: Display "2"
        wait for 10 ns;

        input <= "0011"; -- Test case 4: Display "3"
        wait for 10 ns;

        input <= "0100"; -- Test case 5: Display "4"
        wait for 10 ns;

        input <= "0101"; -- Test case 6: Display "5"
        wait for 10 ns;

        input <= "0110"; -- Test case 7: Display "6"
        wait for 10 ns;

        input <= "0111"; -- Test case 8: Display "7"
        wait for 10 ns;

        input <= "1000"; -- Test case 9: Display "8"
        wait for 10 ns;

        input <= "1001"; -- Test case 10: Display "9"
        wait for 10 ns;

        input <= "1010"; -- Test case 11: Display "A"
        wait for 10 ns;

        input <= "1011"; -- Test case 12: Display "B"
        wait for 10 ns;

        -- Set `t` to '1' to disable display for the remaining cases
        t <= '1';

        input <= "1100"; -- Test case 13: Display disabled
        wait for 10 ns;

        input <= "1101"; -- Test case 14: Display disabled
        wait for 10 ns;

        input <= "1110"; -- Test case 15: Display disabled
        wait for 10 ns;

        input <= "1111"; -- Test case 16: Display disabled
        wait for 10 ns;

        -- End simulation
        wait;
    end process;

end tb;
