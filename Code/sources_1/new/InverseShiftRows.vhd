library ieee;
use ieee.std_logic_1164.all;

entity InverseShiftRows is
    port(
        state   : in std_logic_vector(31 downto 0);  -- 32-bit row input
        s  : in std_logic_vector(1 downto 0);   -- 2-bit select signal for row shift selection
        result  : out std_logic_vector(31 downto 0)  -- 32-bit row output after shift
    );
end InverseShiftRows;

architecture Behavioral of InverseShiftRows is
begin
    -- Process to shift the row based on the `select` signal
    process(s, state)
    begin
        case s is
            when "00" =>
                -- First row: no shift
                result <= state;

            when "01" =>
                -- Second row: shift 1 byte to the right
                result(31 downto 24) <= state(7 downto 0);
                result(23 downto 16) <= state(31 downto 24);
                result(15 downto 8)  <= state(23 downto 16);
                result(7 downto 0)   <= state(15 downto 8);

            when "10" =>
                -- Third row: shift 2 bytes to the right
                result(31 downto 24) <= state(15 downto 8);
                result(23 downto 16) <= state(7 downto 0);
                result(15 downto 8)  <= state(31 downto 24);
                result(7 downto 0)   <= state(23 downto 16);

            when "11" =>
                -- Fourth row: shift 3 bytes to the right
                result(31 downto 24) <= state(23 downto 16);
                result(23 downto 16) <= state(15 downto 8);
                result(15 downto 8)  <= state(7 downto 0);
                result(7 downto 0)   <= state(31 downto 24);

            when others =>
                -- Default case, if select is out of bounds
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
