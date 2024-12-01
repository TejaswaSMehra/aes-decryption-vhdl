library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES_decryptor_tb2 is
end AES_decryptor_tb2;

architecture testbench of AES_decryptor_tb2 is
    -- Component declaration for AES_decryptor
    component AES_decryptor2
        Port (
            clk             : in std_logic;
            reset           : in std_logic;
            start           : in std_logic;
            decrypted_data0 : out std_logic_vector(31 downto 0);
            decrypted_data1 : out std_logic_vector(31 downto 0);
            decrypted_data2 : out std_logic_vector(31 downto 0);
            decrypted_data3 : out std_logic_vector(31 downto 0);
            done            : out std_logic;
            round_port      : out integer;
            byte_counter_port: out integer;
            phase_counter_port: out integer;
            cipher_text_dout_port   : out std_logic_vector(7 downto 0);
            ram_address: out std_logic_vector(3 downto 0);
            state0_output : out std_logic_vector (31 downto 0)
        );
    end component;

    -- Signal declarations to connect to the AES_decryptor
    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal start           : std_logic := '0';
    signal decrypted_data0 : std_logic_vector(31 downto 0);
    signal decrypted_data1 : std_logic_vector(31 downto 0);
    signal decrypted_data2 : std_logic_vector(31 downto 0);
    signal decrypted_data3 : std_logic_vector(31 downto 0);
    signal done            : std_logic;
    signal round_port      : integer;
    signal byte_counter    : integer;
    signal phase_counter    : integer;
    -- Clock generation: 100 MHz clock (10 ns period)
    constant CLK_PERIOD : time := 10 ns;
    signal ciphertext_dout : std_logic_vector(7 downto 0);
    signal ram_address: std_logic_vector(3 downto 0);
    signal state0_output : std_logic_vector (31 downto 0);
begin

    -- Instantiate the AES_decryptor component
    uut: AES_decryptor2
        Port map (
            clk             => clk,
            reset           => reset,
            start           => start,
            decrypted_data0 => decrypted_data0,
            decrypted_data1 => decrypted_data1,
            decrypted_data2 => decrypted_data2,
            decrypted_data3 => decrypted_data3,
            done            => done,
            round_port      => round_port,
            byte_counter_port    => byte_counter,
            phase_counter_port    => phase_counter,
            cipher_text_dout_port => ciphertext_dout,
            ram_address => ram_address,
            state0_output => state0_output
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Test process
    stimulus_process : process
    begin
        -- Reset the AES decryptor
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Start the AES decryption process
        start <= '1';
        wait for 20 ns;
        start <= '0';

        -- Wait until 'done' is asserted
        wait until done = '1';
        
        -- Check output values (based on expected values)
        -- Assuming expected output values for demonstration
        assert decrypted_data0 = x"F3b2f803" report "Decrypted Data 0 Mismatch" severity error;
        assert decrypted_data1 = x"FB9B4e3f" report "Decrypted Data 1 Mismatch" severity error;
        assert decrypted_data2 = x"3DaE3deA" report "Decrypted Data 2 Mismatch" severity error;
        assert decrypted_data3 = x"71AA2Cc0" report "Decrypted Data 3 Mismatch" severity error;

        -- End simulation
        wait;
    end process;

end testbench;
