library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_dist_mem_gen_0 is
end tb_dist_mem_gen_0;

architecture Behavioral of tb_dist_mem_gen_0 is

    -- Signals for connecting to dist_mem_gen_0
    signal clk         : std_logic := '0';
    signal addr        : std_logic_vector(7 downto 0) := (others => '0');  -- Address signal (8-bit width)
    signal dout        : std_logic_vector(7 downto 0);                      -- Data output

    -- Component Declaration for dist_mem_gen_0
    component dist_mem_gen_0
        port (
            a      : in  std_logic_vector(7 downto 0);  -- Address input (match address width in your ROM)
            spo    : out std_logic_vector(7 downto 0)   -- Data output
        );
    end component;

begin
    -- Instantiate the dist_mem_gen_0 component
    uut: dist_mem_gen_0
        port map (
            a   => addr,
            spo => dout
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test Process
    test_process : process
    begin
        -- Test Case 1: Read from address 0
        addr <= "00000000";  -- Address 0
        wait for 20 ns;
        
        -- Test Case 2: Read from address 1
        addr <= "00000001";  -- Address 1
        wait for 20 ns;

        -- Test Case 3: Read from address 16
        addr <= "00010000";  -- Address 16
        wait for 20 ns;

        -- Test Case 4: Read from address 127
        addr <= "01111111";  -- Address 127
        wait for 20 ns;

        -- Test Case 5: Read from address 255
        addr <= "11111111";  -- Address 255
        wait for 20 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
