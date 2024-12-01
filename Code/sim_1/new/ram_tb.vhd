library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity
entity ram_tb is
end ram_tb;

architecture Behavioral of ram_tb is
    -- Component declaration for the RAM
    component ram
        Port ( 
            clk      : in  std_logic;
            we       : in  std_logic;
            addr     : in  std_logic_vector(3 downto 0);
            data_in  : in  std_logic_vector(15 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Testbench signals
    signal clk_tb      : std_logic := '0';
    signal we_tb       : std_logic := '0';
    signal addr_tb     : std_logic_vector(3 downto 0) := (others => '0');
    signal data_in_tb  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out_tb : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the RAM module
    uut: ram
        port map (
            clk      => clk_tb,
            we       => we_tb,
            addr     => addr_tb,
            data_in  => data_in_tb,
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
        -- Wait for a falling edge to align with the new logic
--        wait for clk_period / 2; -- First falling edge
        -- Write data to RAM at address 0
        we_tb <= '1';
        addr_tb <= "0000";  -- Address 0
        data_in_tb <= x"ABCD";  -- Write value 0xABCD
        wait for clk_period;

        we_tb <= '0';
        wait for clk_period;
        -- Write data to RAM at address 1
        we_tb <= '1';

        addr_tb <= "0001";  -- Address 1
        data_in_tb <= x"1234";  -- Write value 0x1234
        wait for clk_period;

        -- Disable write, enable read
        we_tb <= '0';
        addr_tb <= "0000";
        wait for clk_period;
        -- Read data from address 0
        addr_tb <= "0001";
        wait for clk_period;

        -- Read data from address 1
        addr_tb <= "0001";
        wait for clk_period;

        -- Write new data to address 2
        we_tb <= '1';
        addr_tb <= "0010";  -- Address 2
        data_in_tb <= x"5678";  -- Write value 0x5678
        wait for clk_period;

        -- Read back data from address 2
        we_tb <= '0';
        addr_tb <= "0010";
        wait for clk_period;

        -- End simulation
        wait;
    end process;

end Behavioral;
