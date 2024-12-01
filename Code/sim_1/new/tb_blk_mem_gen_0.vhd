library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_blk_mem_gen_0 is
end tb_blk_mem_gen_0;

architecture Behavioral of tb_blk_mem_gen_0 is

    -- Signals for connecting to blk_mem_gen_0
    signal clk         : std_logic := '0';
    signal we          : std_logic := '0';  -- Write Enable
    signal ena         : std_logic := '1';  -- Enable signal
    signal addr        : std_logic_vector(10 downto 0) := (others => '0');  -- Address signal (11-bit for 2000-depth memory)
    signal din         : std_logic_vector(7 downto 0) := (others => '0');  -- Data input (8-bit width)
    signal dout        : std_logic_vector(7 downto 0);                      -- Data output

    -- Component Declaration for blk_mem_gen_0
    component blk_mem_gen_0
        port (
            clka   : in  std_logic;
            wea    : in  std_logic;
            ena    : in  std_logic;                           -- Added enable signal
            addra  : in  std_logic_vector(10 downto 0);       -- 11-bit address width
            dina   : in  std_logic_vector(7 downto 0);
            douta  : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    -- Instantiate the blk_mem_gen_0 component
    uut: blk_mem_gen_0
        port map (
            clka   => clk,
            wea    => we,
            ena    => ena,       -- Connect the enable signal
            addra  => addr,
            dina   => din,
            douta  => dout
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
        -- Test Case 1: Read from an address in initialized memory
        addr <= "00000000000";  -- Address 0
        we <= '0';              -- Disable write
        wait for 50 ns;
        
        -- Test Case 2: Write a value to a new address
        addr <= "00100000000";  -- New address to write (ensure 11-bit width)
        din <= x"AA";           -- Data to write
        we <= '1';              -- Enable write
        wait for 50 ns;
        we <= '0';              -- Disable write after one clock cycle
        
        -- Test Case 3: Read back from the written address
        addr <= "00100000000";  -- Address to read back
        wait for 50 ns;

        -- Test Case 4: Read another initialized memory address
        addr <= "00000000001";  -- Address 1
        we <= '0';              -- Ensure write is disabled
        wait for 50 ns;
        
        -- Additional Test Case 5: Write and read at a different address
        addr <= "00000000101";  -- New write address
        din <= x"5A";           -- Write different data
        we <= '1';              -- Enable write
        wait for 50 ns;
        we <= '0';              -- Disable write after one clock cycle
        addr <= "00000000101";  -- Read back to verify
        wait for 50 ns;

        -- Additional Test Case 6: Check initial data at high address
        addr <= "11111111110";  -- Near max depth to check initialization
        we <= '0';              -- Ensure write is disabled
        wait for 50 ns;

        -- Additional Test Case 7: Write and read at out of bounds address
        addr <= "11111111111";  -- Max depth - boundary test
        din <= x"FF";           -- Write boundary data
        we <= '1';              -- Enable write
        wait for 50 ns;
        we <= '0';              -- Disable write after one clock cycle
        addr <= "11111111111";  -- Read back to verify boundary write
        wait for 50 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
