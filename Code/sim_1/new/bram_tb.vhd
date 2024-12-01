library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_bram_access is
end tb_bram_access;

architecture Behavioral of tb_bram_access is

    -- Signals for connecting to the `bram_access` entity
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal ena     : std_logic := '0';
    signal we      : std_logic_vector(0 downto 0) := "0";
    signal addr    : std_logic_vector(10 downto 0) := (others => '0');
    signal din     : std_logic_vector(7 downto 0) := (others => '0');
    signal dout    : std_logic_vector(7 downto 0);

    -- Instantiate the `bram_access` component (Unit Under Test - UUT)
    component bram_access
        Port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            ena   : in  std_logic;
            we    : in  std_logic_vector(0 downto 0);
            addr  : in  std_logic_vector(10 downto 0);
            din   : in  std_logic_vector(7 downto 0);
            dout  : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    -- Instantiate the `bram_access` UUT
    UUT: bram_access
        Port map (
            clk  => clk,
            rst  => rst,
            ena  => ena,
            we   => we,
            addr => addr,
            din  => din,
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

    -- Test process
    process
    begin
        -- Reset the system
        rst <= '1';
        ena <= '0';
        wait for 20 ns;
        rst <= '0';

        -- Enable BRAM access and write data
        ena <= '1';
        
        -- Test Case 1: Write data to address 0x001
        addr <= "00000000001";
        din  <= x"AA";
        we   <= "1";  -- Enable write
        wait for 10 ns;
        we   <= "0";  -- Disable write

        -- Test Case 2: Read back from address 0x001
        addr <= "00000000001";
        wait for 10 ns;
        assert (dout = x"AA") report "Test Case 1 Failed: Expected x'AA'" severity error;

        -- Test Case 3: Write data to address 0x002
        addr <= "00000000010";
        din  <= x"BB";
        we   <= "1";  -- Enable write
        wait for 10 ns;
        we   <= "0";  -- Disable write

        -- Test Case 4: Read back from address 0x002
        addr <= "00000000010";
        wait for 10 ns;
        assert (dout = x"BB") report "Test Case 3 Failed: Expected x'BB'" severity error;

        -- Test Case 5: Read back from an uninitialized address 0x003
        addr <= "00000000011";
        wait for 10 ns;
        assert (dout = x"00") report "Test Case 5 Failed: Expected x'00' (default value)" severity warning;

        -- Simulation complete
        report "Test completed successfully" severity note;
        wait;
    end process;

end Behavioral;
