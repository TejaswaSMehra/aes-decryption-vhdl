library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;

entity tb_brom_access is
end tb_brom_access;

architecture Behavioral of tb_brom_access is
    signal clk   : std_logic := '0';
    signal ena   : std_logic := '1'; -- Set enable high by default
    signal addr  : std_logic_vector(10 downto 0) := (others => '0');
    signal dout  : std_logic_vector(7 downto 0);

    component brom_access
        Port (
            clk   : in  std_logic;
            ena   : in  std_logic;  -- Enable port for the testbench
            addr  : in  std_logic_vector(10 downto 0);
            dout  : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    UUT: brom_access
        Port map (
            clk  => clk,
            ena  => ena,   -- Map the enable signal
            addr => addr,
            dout => dout
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process to exercise `ena`, `addr`, and `dout`
    process
    begin
        -- Test Case: Use addr values while ena is high
        ena <= '1'; -- Enable the memory
        addr <= "00000000000";
        wait for 10 ns;
        
        addr <= "00000000001";
        wait for 10 ns;
        
        -- Additional tests as needed
        
        report "Test completed successfully" severity note;
        wait;
    end process;

end Behavioral;

