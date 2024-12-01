library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity rom_tb is
end rom_tb;

architecture Behavioral of rom_tb is
    -- Component declaration for the ROM
    component rom
        Port ( 
            clk      : in  std_logic;
            addr     : in  std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Testbench signals
    signal clk_tb      : std_logic := '0';
    signal addr_tb     : std_logic_vector(3 downto 0) := (others => '0');
    signal data_out_tb : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the ROM module
    uut: rom
        port map (
            clk      => clk_tb,
            addr     => addr_tb,
            data_out => data_out_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;
    
    -- Stimulus process
    stimulus: process
    begin
        -- Wait for the clock to stabilize
        wait for clk_period;

        -- Apply address 0 and read data
        addr_tb <= "0000";  -- Address 0
        wait for clk_period;
        
        -- Apply address 1 and read data
        addr_tb <= "0001";  -- Address 1
        wait for clk_period;

        -- Apply address 2 and read data
        addr_tb <= "0010";  -- Address 2
        wait for clk_period;

        -- Apply address 3 and read data
        addr_tb <= "0011";  -- Address 3
        wait for clk_period;

        -- Apply address 4 and read data
        addr_tb <= "0100";  -- Address 4
        wait for clk_period;

        -- Apply address 5 and read data
        addr_tb <= "0101";  -- Address 5
        wait for clk_period;

        -- Apply address 6 and read data
        addr_tb <= "0110";  -- Address 6
        wait for clk_period;

        -- Apply address 7 and read data
        addr_tb <= "0111";  -- Address 7
        wait for clk_period;

        -- Apply address 8 and read data
        addr_tb <= "1000";  -- Address 8
        wait for clk_period;

        -- Apply address 9 and read data
        addr_tb <= "1001";  -- Address 9
        wait for clk_period;

        -- Apply address 10 and read data
        addr_tb <= "1010";  -- Address 10
        wait for clk_period;

        -- Apply address 11 and read data
        addr_tb <= "1011";  -- Address 11
        wait for clk_period;

        -- Apply address 12 and read data
        addr_tb <= "1100";  -- Address 12
        wait for clk_period;

        -- Apply address 13 and read data
        addr_tb <= "1101";  -- Address 13
        wait for clk_period;

        -- Apply address 14 and read data
        addr_tb <= "1110";  -- Address 14
        wait for clk_period;

        -- Apply address 15 and read data
        addr_tb <= "1111";  -- Address 15
        wait for clk_period;

        -- End simulation
        wait;
    end process;

end Behavioral;
