library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DigitalDisplay is
    Port (
        input_vector : in  std_logic_vector(31 downto 0); -- 32-bit input vector
        clk          : in  std_logic;
        reset        : in  std_logic;
        anodes       : out std_logic_vector(3 downto 0);
--        asci_values  : out std_logic_vector(15 downto 0); -- Output for ASCII values
        a, b, c, d, e, f, g : out std_logic  -- Segment outputs for 7-segment display
    );
end DigitalDisplay;

architecture Behavioral of DigitalDisplay is

    signal ascii_values : std_logic_vector(15 downto 0); -- Internal ASCII representation for each hex digit
    signal t            : std_logic_vector(3 downto 0);  -- 4-bit flag, '1' means not displayable as hex
    
    -- Component declaration for final
    component final
        Port (
            inputi    : in  std_logic_vector(15 downto 0);
            clk_ini   : in  std_logic;
            reseti    : in  std_logic;
            anodesi   : out std_logic_vector(3 downto 0);
            aii, bii, cii, dii, eii, fii, gii : out std_logic;
            t         : in  std_logic_vector(3 downto 0)
        );
    end component;

begin
    -- Assign internal signal `ascii_values` to output port `asci_values`
--    asci_values <= ascii_values;

    -- Process to calculate `ascii_values` and `t` using brute-force comparisons for each hex digit
    process(input_vector, reset)
        variable byte_value : std_logic_vector(7 downto 0);
    begin
        -- Reset handling
        if reset = '1' then
            ascii_values <= (others => '0');
            t <= "0000";
        else
            -- Initialize `t` to "0000" assuming all characters are displayable
            t <= "0000";

            -- First 8 bits (most significant byte)
            byte_value := input_vector(31 downto 24);
            if byte_value = x"30" then
                ascii_values(15 downto 12) <= "0000";  -- '0'
            elsif byte_value = x"31" then
                ascii_values(15 downto 12) <= "0001";  -- '1'
            elsif byte_value = x"32" then
                ascii_values(15 downto 12) <= "0010";  -- '2'
            elsif byte_value = x"33" then
                ascii_values(15 downto 12) <= "0011";  -- '3'
            elsif byte_value = x"34" then
                ascii_values(15 downto 12) <= "0100";  -- '4'
            elsif byte_value = x"35" then
                ascii_values(15 downto 12) <= "0101";  -- '5'
            elsif byte_value = x"36" then
                ascii_values(15 downto 12) <= "0110";  -- '6'
            elsif byte_value = x"37" then
                ascii_values(15 downto 12) <= "0111";  -- '7'
            elsif byte_value = x"38" then
                ascii_values(15 downto 12) <= "1000";  -- '8'
            elsif byte_value = x"39" then
                ascii_values(15 downto 12) <= "1001";  -- '9'
            elsif byte_value = x"41" or byte_value = x"61" then
                ascii_values(15 downto 12) <= "1010";  -- 'A' or 'a'
            elsif byte_value = x"42" or byte_value = x"62" then
                ascii_values(15 downto 12) <= "1011";  -- 'B' or 'b'
            elsif byte_value = x"43" or byte_value = x"63" then
                ascii_values(15 downto 12) <= "1100";  -- 'C' or 'c'
            elsif byte_value = x"44" or byte_value = x"64" then
                ascii_values(15 downto 12) <= "1101";  -- 'D' or 'd'
            elsif byte_value = x"45" or byte_value = x"65" then
                ascii_values(15 downto 12) <= "1110";  -- 'E' or 'e'
            elsif byte_value = x"46" or byte_value = x"66" then
                ascii_values(15 downto 12) <= "1111";  -- 'F' or 'f'
            else
                ascii_values(15 downto 12) <= "0000";
                t(3) <= '1';  -- Mark as non-displayable
            end if;

            -- Second 8 bits
            byte_value := input_vector(23 downto 16);
            if byte_value = x"30" then
                ascii_values(11 downto 8) <= "0000";  -- '0'
            elsif byte_value = x"31" then
                ascii_values(11 downto 8) <= "0001";  -- '1'
            elsif byte_value = x"32" then
                ascii_values(11 downto 8) <= "0010";  -- '2'
            elsif byte_value = x"33" then
                ascii_values(11 downto 8) <= "0011";  -- '3'
            elsif byte_value = x"34" then
                ascii_values(11 downto 8) <= "0100";  -- '4'
            elsif byte_value = x"35" then
                ascii_values(11 downto 8) <= "0101";  -- '5'
            elsif byte_value = x"36" then
                ascii_values(11 downto 8) <= "0110";  -- '6'
            elsif byte_value = x"37" then
                ascii_values(11 downto 8) <= "0111";  -- '7'
            elsif byte_value = x"38" then
                ascii_values(11 downto 8) <= "1000";  -- '8'
            elsif byte_value = x"39" then
                ascii_values(11 downto 8) <= "1001";  -- '9'
            elsif byte_value = x"41" or byte_value = x"61" then
                ascii_values(11 downto 8) <= "1010";  -- 'A' or 'a'
            elsif byte_value = x"42" or byte_value = x"62" then
                ascii_values(11 downto 8) <= "1011";  -- 'B' or 'b'
            elsif byte_value = x"43" or byte_value = x"63" then
                ascii_values(11 downto 8) <= "1100";  -- 'C' or 'c'
            elsif byte_value = x"44" or byte_value = x"64" then
                ascii_values(11 downto 8) <= "1101";  -- 'D' or 'd'
            elsif byte_value = x"45" or byte_value = x"65" then
                ascii_values(11 downto 8) <= "1110";  -- 'E' or 'e'
            elsif byte_value = x"46" or byte_value = x"66" then
                ascii_values(11 downto 8) <= "1111";  -- 'F' or 'f'
            else
                ascii_values(11 downto 8) <= "0000";
                t(2) <= '1';
            end if;

            -- Third 8 bits
            byte_value := input_vector(15 downto 8);
            if byte_value = x"30" then
                ascii_values(7 downto 4) <= "0000";  -- '0'
            elsif byte_value = x"31" then
                ascii_values(7 downto 4) <= "0001";  -- '1'
            elsif byte_value = x"32" then
                ascii_values(7 downto 4) <= "0010";  -- '2'
            elsif byte_value = x"33" then
                ascii_values(7 downto 4) <= "0011";  -- '3'
            elsif byte_value = x"34" then
                ascii_values(7 downto 4) <= "0100";  -- '4'
            elsif byte_value = x"35" then
                ascii_values(7 downto 4) <= "0101";  -- '5'
            elsif byte_value = x"36" then
                ascii_values(7 downto 4) <= "0110";  -- '6'
            elsif byte_value = x"37" then
                ascii_values(7 downto 4) <= "0111";  -- '7'
            elsif byte_value = x"38" then
                ascii_values(7 downto 4) <= "1000";  -- '8'
            elsif byte_value = x"39" then
                ascii_values(7 downto 4) <= "1001";  -- '9'
            elsif byte_value = x"41" or byte_value = x"61" then
                ascii_values(7 downto 4) <= "1010";  -- 'A' or 'a'
            elsif byte_value = x"42" or byte_value = x"62" then
                ascii_values(7 downto 4) <= "1011";  -- 'B' or 'b'
            elsif byte_value = x"43" or byte_value = x"63" then
                ascii_values(7 downto 4) <= "1100";  -- 'C' or 'c'
            elsif byte_value = x"44" or byte_value = x"64" then
                ascii_values(7 downto 4) <= "1101";  -- 'D' or 'd'
            elsif byte_value = x"45" or byte_value = x"65" then
                ascii_values(7 downto 4) <= "1110";  -- 'E' or 'e'
            elsif byte_value = x"46" or byte_value = x"66" then
                ascii_values(7 downto 4) <= "1111";  -- 'F' or 'f'
            else
                ascii_values(7 downto 4) <= "0000";
                t(1) <= '1';
            end if;

            -- Fourth 8 bits (least significant byte)
            byte_value := input_vector(7 downto 0);
            if byte_value = x"30" then
                ascii_values(3 downto 0) <= "0000";  -- '0'
            elsif byte_value = x"31" then
                ascii_values(3 downto 0) <= "0001";  -- '1'
            elsif byte_value = x"32" then
                ascii_values(3 downto 0) <= "0010";  -- '2'
            elsif byte_value = x"33" then
                ascii_values(3 downto 0) <= "0011";  -- '3'
            elsif byte_value = x"34" then
                ascii_values(3 downto 0) <= "0100";  -- '4'
            elsif byte_value = x"35" then
                ascii_values(3 downto 0) <= "0101";  -- '5'
            elsif byte_value = x"36" then
                ascii_values(3 downto 0) <= "0110";  -- '6'
            elsif byte_value = x"37" then
                ascii_values(3 downto 0) <= "0111";  -- '7'
            elsif byte_value = x"38" then
                ascii_values(3 downto 0) <= "1000";  -- '8'
            elsif byte_value = x"39" then
                ascii_values(3 downto 0) <= "1001";  -- '9'
            elsif byte_value = x"41" or byte_value = x"61" then
                ascii_values(3 downto 0) <= "1010";  -- 'A' or 'a'
            elsif byte_value = x"42" or byte_value = x"62" then
                ascii_values(3 downto 0) <= "1011";  -- 'B' or 'b'
            elsif byte_value = x"43" or byte_value = x"63" then
                ascii_values(3 downto 0) <= "1100";  -- 'C' or 'c'
            elsif byte_value = x"44" or byte_value = x"64" then
                ascii_values(3 downto 0) <= "1101";  -- 'D' or 'd'
            elsif byte_value = x"45" or byte_value = x"65" then
                ascii_values(3 downto 0) <= "1110";  -- 'E' or 'e'
            elsif byte_value = x"46" or byte_value = x"66" then
                ascii_values(3 downto 0) <= "1111";  -- 'F' or 'f'
            else
                ascii_values(3 downto 0) <= "0000";
                t(0) <= '1';
            end if;
        end if;
    end process;

    -- Instantiate final and connect signals
    display_inst : final
        port map (
            inputi    => ascii_values,
            clk_ini   => clk,
            reseti    => reset,
            anodesi   => anodes,
            aii       => a,
            bii       => b,
            cii       => c,
            dii       => d,
            eii       => e,
            fii       => f,
            gii       => g,
            t         => t
        );

end Behavioral;
