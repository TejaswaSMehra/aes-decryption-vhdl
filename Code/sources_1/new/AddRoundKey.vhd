library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity for AddRoundKey
entity AddRoundKey is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;                       -- Reset signal
        round       : in std_logic_vector(3 downto 0);    -- Round selection signal (0 to 9 for 10 rounds)
        input_data  : in std_logic_vector(127 downto 0);  -- Current state matrix (128 bits)
        output_data : out std_logic_vector(127 downto 0)  -- Resulting XORed state matrix
    );
end AddRoundKey;

architecture Behavioral of AddRoundKey is

    -- Component declaration for the ROM holding round keys (keys.coe)
    component blk_mem_gen_2  -- Your keys ROM
        Port (
            clka  : in std_logic;
            addra : in std_logic_vector(7 downto 0);         -- Address input for round keys (160 depth for 10 rounds of 16 bytes)
            douta : out std_logic_vector(7 downto 0)         -- 8-bit output for each byte
        );
    end component;

    -- Component for the 8-bit XOR gate
    component xor_gate_8bit
        Port (
            a      : in std_logic_vector(7 downto 0);        -- 8-bit input A
            b      : in std_logic_vector(7 downto 0);        -- 8-bit input B
            result : out std_logic_vector(7 downto 0)        -- 8-bit XOR result
        );
    end component;

    -- Internal signals
    signal selected_key_byte : std_logic_vector(7 downto 0); -- Byte fetched from round keys
    signal xor_result        : std_logic_vector(7 downto 0); -- Result of each byte XOR
    signal byte_counter      : integer range 0 to 15 := 0;   -- Byte counter from 0 to 15
    -- Corrected base address calculation signal with 8-bit width
    signal address_base : std_logic_vector(7 downto 0);      -- Base address for the round in ROM

begin

    -- Corrected calculation of address_base with 8-bit width
    address_base <= std_logic_vector(to_unsigned(to_integer(unsigned(round)) * 16, 8));  -- Each round key starts 16 bytes apart

    -- Instantiate the ROM for round keys
    ROM_RoundKeys : blk_mem_gen_2
        Port map (
            clka => clk,
            addra => address_base + std_logic_vector(to_unsigned(byte_counter, 8)),  -- Fetch the specific byte of the round key
            douta => selected_key_byte  -- Output the fetched byte
        );
    xor_instd: xor_gate_8bit
        Port map (
            a => input_data((byte_counter * 8 + 7) downto byte_counter * 8),  -- Current byte from input data
            b => selected_key_byte,                                       -- Corresponding round key byte
            result => xor_result                                          -- XOR result
        );
    -- Process for XORing each byte one by one
    process(clk, reset)
    begin
        if reset = '1' then
            byte_counter <= 0;                   -- Reset byte counter on reset
        elsif rising_edge(clk) then
            if byte_counter < 16 then
                -- Instantiate the XOR gate for the current byte

                -- Store the XOR result into the output register
                output_data(byte_counter * 8 + 7 downto byte_counter * 8) <= xor_result;
                
                -- Increment the byte counter
                byte_counter <= byte_counter + 1;
            else
                byte_counter <= 0;  -- Reset byte counter for the next round
            end if;
        end if;
    end process;

end Behavioral;
