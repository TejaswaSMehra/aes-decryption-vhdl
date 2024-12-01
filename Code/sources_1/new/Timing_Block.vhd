library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Timing_block is
    Port (
        clk_in     : in  STD_LOGIC;                -- 100 MHz input clock
        reset      : in  STD_LOGIC;                -- Reset signal
        mux_select : out STD_LOGIC_VECTOR (1 downto 0); -- Signal for the mux
        anodes     : out STD_LOGIC_VECTOR (3 downto 0)  -- Anode control signals
    );
end Timing_block;

architecture Behavioral of Timing_block is
    constant N : integer := 5;             -- Set N for 1 kHz new clock
    signal counter           : integer := 0;
    signal internal_new_clk  : STD_LOGIC := '0';      -- Internal divided clock signal
    signal internal_mux_select : STD_LOGIC_VECTOR (1 downto 0) := "00"; -- Internal mux_select signal
begin

    -- Process 1: Clock Divider
    NE_CLK: process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= 0;
            internal_new_clk <= '0';
        elsif rising_edge(clk_in) then
            if counter = N-1 then
                counter <= 0;
                internal_new_clk <= not internal_new_clk; -- Toggle internal_new_clk
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Process 2: MUX Select Signal
    MU_select: process(internal_new_clk)
    begin
        if rising_edge(internal_new_clk) then
            internal_mux_select <= internal_mux_select + 1;
        end if;
    end process;

    -- Assign internal signal to output
    mux_select <= internal_mux_select;

    -- Process 3: Anode Signal
    ANODE_select: process(internal_mux_select)
    begin
        case internal_mux_select is
            when "00" => anodes <= "1110"; -- Activate digit 0
            when "01" => anodes <= "1101"; -- Activate digit 1
            when "10" => anodes <= "1011"; -- Activate digit 2
            when "11" => anodes <= "0111"; -- Activate digit 3
            when others => anodes <= "1111"; -- Default (all off)
        end case;
    end process;

end Behavioral;
