library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_InverseSubBytes is
end tb_InverseSubBytes;

architecture Behavioral of tb_InverseSubBytes is
    signal input_byte  : std_logic_vector(7 downto 0);  -- 11-bit input address
    signal output_byte : std_logic_vector(7 downto 0);   -- 8-bit output

    component InverseSubBytes
        port(
            input_byte  : in std_logic_vector(7 downto 0);
            output_byte : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    UUT: InverseSubBytes
        port map (
            input_byte  => input_byte,
            output_byte => output_byte
        );

    process
    begin
        input_byte <= "00000000";  -- Read from address 0
        wait for 10 ns;

        input_byte <= "00000001";  -- Read from address 1
        wait for 10 ns;

        input_byte <= "00000010";  -- Read from address 2
        wait for 10 ns;

        input_byte <= "00010000";  -- Read from address 16
        wait for 10 ns;

        input_byte <= "10000000";  -- Read from address 128
        wait for 10 ns;

        input_byte <= "11111111";  -- Read from address 255
        wait for 10 ns;


        wait;
    end process;
end Behavioral;
