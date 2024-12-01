library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InverseSubBytes is
    port(
        input_byte  : in std_logic_vector(7 downto 0);  -- 11-bit input for addressing
        output_byte : out std_logic_vector(7 downto 0)   -- 8-bit output after substitution
    );
end InverseSubBytes;

architecture Behavioral of InverseSubBytes is

    -- Signal for addressing the memory
    signal address : std_logic_vector(7 downto 0);
    signal data_out : std_logic_vector(7 downto 0);

    -- Component declaration for dist_mem_gen_0
    component dist_mem_gen_0
        port (
            a    : in  std_logic_vector(7 downto 0);  -- 8-bit address input
            spo  : out std_logic_vector(7 downto 0)    -- 8-bit data output
        );
    end component;

begin
    -- Map input_byte to the memory address and assign the output
    address <=  input_byte;
    output_byte <= data_out;

    -- Memory instantiation (asynchronous read)
    mem_inst : dist_mem_gen_0
        port map (
            a    => address,
            spo  => data_out
        );

end Behavioral;
