library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InvMixColumns is
    port (
        input_column  : in  std_logic_vector(31 downto 0); -- 32-bit input column (8 bits per element)
        output_column : out std_logic_vector(31 downto 0)   -- 32-bit output column after transformation
    );
end InvMixColumns;

architecture Behavioral of InvMixColumns is

    -- Constant 128-bit matrix, with each row occupying 32 bits
    constant inv_mix_matrix1 : std_logic_vector(31 downto 0) := x"0E0B0D09";
    constant inv_mix_matrix2 : std_logic_vector(31 downto 0) := x"090E0B0D";
    constant inv_mix_matrix3 : std_logic_vector(31 downto 0) := x"0D090E0B";
    constant inv_mix_matrix4 : std_logic_vector(31 downto 0) := x"0B0D090E";

    -- Signals to hold each byte of the input column
    signal s0, s1, s2, s3 : std_logic_vector(7 downto 0);

    -- Function to multiply two bytes in GF(2^8) with irreducible polynomial x^8 + x^4 + x^3 + x + 1 (0x11B)
    function galois_multiply(a, b : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable p : std_logic_vector(7 downto 0) := (others => '0');
        variable temp_a : std_logic_vector(7 downto 0) := a;
        variable temp_b : std_logic_vector(7 downto 0) := b;
    begin
        for i in 0 to 7 loop
            if temp_b(0) = '1' then
                p := p xor temp_a;
            end if;
            if temp_a(7) = '1' then
                temp_a := (temp_a(6 downto 0) & '0') xor x"1B";
            else
                temp_a := temp_a(6 downto 0) & '0';
            end if;
            temp_b := '0' & temp_b(7 downto 1);
        end loop;
        return p;
    end function;

    -- Function to calculate one row transformation
    function row_transform(row : std_logic_vector(31 downto 0);
                           s0, s1, s2, s3 : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(7 downto 0);
    begin
        result := galois_multiply(row(31 downto 24), s0) xor
                  galois_multiply(row(23 downto 16), s1) xor
                  galois_multiply(row(15 downto 8), s2) xor
                  galois_multiply(row(7 downto 0), s3);
        return result;
    end function;

begin
    -- Extract bytes from input column
    s0 <= input_column(31 downto 24);
    s1 <= input_column(23 downto 16);
    s2 <= input_column(15 downto 8);
    s3 <= input_column(7 downto 0);

    -- Calculate each byte of the output column by transforming each row of the matrix
    output_column(31 downto 24) <= row_transform(inv_mix_matrix1, s0, s1, s2, s3); -- Row 0 transformation
    output_column(23 downto 16) <= row_transform(inv_mix_matrix2, s0, s1, s2, s3);  -- Row 1 transformation
    output_column(15 downto 8)  <= row_transform(inv_mix_matrix3, s0, s1, s2, s3);  -- Row 2 transformation
    output_column(7 downto 0)   <= row_transform(inv_mix_matrix4, s0, s1, s2, s3);   -- Row 3 transformation

end Behavioral;
