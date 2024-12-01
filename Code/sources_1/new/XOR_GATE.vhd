library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration for the 8-bit XOR gate
entity xor_gate_8bit is
    port(
        a      : in std_logic_vector(7 downto 0);  -- 8-bit input A
        b      : in std_logic_vector(7 downto 0);  -- 8-bit input B
        result : out std_logic_vector(7 downto 0)  -- 8-bit XOR result
    );
end xor_gate_8bit;

-- Architecture Definition for the 8-bit XOR gate
architecture Behavioral of xor_gate_8bit is
begin
    -- XOR operation between the 8-bit inputs
    result <= a xor b;
end Behavioral;
