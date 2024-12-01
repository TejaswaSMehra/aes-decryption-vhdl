library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopModule is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        start         : in  std_logic;
        anodes        : out std_logic_vector(3 downto 0);
        a, b, c, d, e, f, g : out std_logic
--        debug_led : out std_logic
        
    );
end TopModule;

architecture Behavioral of TopModule is
    -- Internal signals for AES_decryptor and display components
    signal decrypted_data0, decrypted_data1, decrypted_data2, decrypted_data3 : std_logic_vector(31 downto 0);
    signal done           : std_logic := '0';
    signal offset         : integer := 0;
    signal display_offset : integer := 0;
    signal start_decrypt  : std_logic := '0';
    signal done_d         : std_logic := '0';
    signal all_decrypted  : std_logic := '0';
    signal current_mode   : std_logic := '0';  -- 0 for decryption mode, 1 for display mode
    signal reset_pulse    : std_logic := '0';
--    signal debug_led_changer : std_logic := '1';

    -- Constants
    constant NUM_BLOCKS    : integer := 8;
    constant offset_NUM_BLOCKS : integer := 2; --this gives number of 128 bit blocks 
    constant a2 : integer := 1; --this gives the number of bits in offset_num_blocks ki max value
    constant RAM_ADDR_WIDTH: integer := a2+4;  
    constant ROW_SIZE      : integer := 4;    

    -- RAM signals
    signal ram_addr        : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ram_data_out    : std_logic_vector(7 downto 0);
    signal ram_en          : std_logic := '1';
    signal ram_we          : std_logic_vector(0 downto 0) := (others => '0');
    signal ram_data_in     : std_logic_vector(7 downto 0) := (others => '0');  

    -- Display signals
    signal input_vector    : std_logic_vector(31 downto 0); -- 32-bit word for display
    signal display_ready   : std_logic := '0'; -- Flag for 32-bit read completion
    signal cycle_complete  : std_logic;
    signal phase_counter   : integer range 0 to 3 := 0;
    signal byte_counter    : integer range 0 to 3 := 0;
    signal byte_counter2    : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal row_counter     : integer range 0 to 3 := 0;
    signal memory_cycles   : integer := 0;
    signal write_phase     : std_logic := '0';
    signal display_delay_counter : integer range 0 to 1000 := 0;

    -- Component declarations
    component AES_decryptor
        Port (
            clk             : in std_logic;
            reset           : in std_logic;
            start           : in std_logic;
            offset          : in integer;
            decrypted_data0 : out std_logic_vector(31 downto 0);
            decrypted_data1 : out std_logic_vector(31 downto 0);
            decrypted_data2 : out std_logic_vector(31 downto 0);
            decrypted_data3 : out std_logic_vector(31 downto 0);
            done2           : out std_logic
        );
    end component;

    component DigitalDisplay
        Port (
            input_vector : in  std_logic_vector(31 downto 0); -- 32-bit input vector
            clk          : in  std_logic;
            reset        : in  std_logic;
            anodes       : out std_logic_vector(3 downto 0);
--            asci_values  : out std_logic_vector(15 downto 0); -- Output for ASCII values
            a, b, c, d, e, f, g : out std_logic  -- Segment outputs for 7-segment display
        );
    end component;

    component Output_RAM
        Port (
            clka    : in std_logic;
            rsta    : in std_logic;
            ena     : in std_logic;
            wea     : in std_logic_vector(0 downto 0);  -- Write enable
            addra   : in std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);  
            dina    : in std_logic_vector(7 downto 0);  
            douta   : out std_logic_vector(7 downto 0)  
        );
    end component;

begin

    -- Instantiate AES_decryptor
    decryptor_inst : AES_decryptor
        port map (
            clk             => clk,
            reset           => reset_pulse,
            start           => start_decrypt,
            offset          => offset,
            decrypted_data0 => decrypted_data0,
            decrypted_data1 => decrypted_data1,
            decrypted_data2 => decrypted_data2,
            decrypted_data3 => decrypted_data3,
            done2           => done
        );

    -- Instantiate Output_RAM
    ram_inst : Output_RAM
        port map (
            clka    => clk,
            rsta    => reset,
            ena     => ram_en,
            wea     => ram_we,
            addra   => ram_addr,
            dina    => ram_data_in,
            douta   => ram_data_out
        );

    -- Instantiate DigitalDisplay for final display output
    display_output : DigitalDisplay
        port map (
            input_vector => input_vector,
            clk          => clk,
            reset        => reset,
            anodes       => anodes,
--            asci_values  => open, -- Or connect to a signal if needed
            a            => a,
            b            => b,
            c            => c,
            d            => d,
            e            => e,
            f            => f,
            g            => g
        );

    -- Process for decryption, insertion into RAM, and switching to display mode
    process(clk)
        variable intermediate_vector : std_logic_vector(31 downto 0); -- Process variable for 32-bit read
    begin
        if rising_edge(clk) then
            if reset = '1' then
                display_offset <= 0;
                start_decrypt <= '0';
                done_d <= '0';
                all_decrypted <= '0';
                row_counter <= 0;
                phase_counter <= 0;
                byte_counter <= 0;
                byte_counter2 <= (others => '0');
                memory_cycles <= 10;
                input_vector <= (others => '0');
                intermediate_vector := (others => '0');
                display_delay_counter <= 0;  -- Reset display counter
            elsif memory_cycles > 0 then
                memory_cycles <= memory_cycles - 1;
            elsif current_mode = '0' then  -- Decryption Phase
                done_d <= done;
                reset_pulse <= '0';
                start_decrypt <= '1';

                if done = '1' and done_d = '0' then
                    write_phase <= '1';
                    ram_we <= "1";
                    done_d <= '1';  -- Set done_d to '1' only after processing done signal
                elsif write_phase = '1' then
                    ram_addr <= std_logic_vector(to_unsigned((16 * offset) + (row_counter * 4) + byte_counter, RAM_ADDR_WIDTH));
                    case row_counter is
                        when 0 => ram_data_in <= decrypted_data0((3-byte_counter)*8+7 downto (3-byte_counter)*8);
                        when 1 => ram_data_in <= decrypted_data1((3-byte_counter)*8+7 downto (3-byte_counter)*8);
                        when 2 => ram_data_in <= decrypted_data2((3-byte_counter)*8+7 downto (3-byte_counter)*8);
                        when 3 => ram_data_in <= decrypted_data3((3-byte_counter)*8+7 downto (3-byte_counter)*8);
                        when others => null;
                    end case;

                    memory_cycles <= 10;

                    if byte_counter < 3 then
                        byte_counter <= byte_counter + 1;
                    else
                        byte_counter <= 0;
                        if row_counter < 3 then
                            row_counter <= row_counter + 1;
                        else
                            row_counter <= 0;
                            if offset < offset_NUM_BLOCKS - 1  then  -- Adjust condition here to check for multiple blocks
                                offset <= offset + 1;  -- Increment offset to process the next block
                                done_d <= '0';  -- Reset done_d to allow further processing
                                write_phase <= '0';  -- Reset write phase
                                reset_pulse <= '1';  -- Reset AES_decryptor
                            else
                                current_mode <= '1';  -- Switch to display mode
                                done_d <= '0';  -- Ensure done_d is reset
                            end if;
                        end if;
                    end if;
                end if;
            else  -- Display Phase
                ram_we <= "0";
                if memory_cycles > 0 then
                    memory_cycles <= memory_cycles - 1;
                else
                    case phase_counter is
                        when 0 =>
                            -- Set address for next 8-bit read in the 32-bit sequence
                            ram_addr <= byte_counter2;
                            memory_cycles <= 10;
                            phase_counter <= 1;

                        when 1 =>
--                            debug_intermediate_vector  <= ram_data_out; 
                            -- Capture data from RAM to build the 32-bit intermediate_vector
                           
                            intermediate_vector := intermediate_vector(23 downto 0)  & ram_data_out;
                            input_vector <= intermediate_vector;  -- Assign intermediate value to display
                            phase_counter <= 0;  -- Move to display hold phase
                            byte_counter2 <= std_logic_vector(unsigned(byte_counter2) + 1);
                            memory_cycles <= 100;

                        when others =>
                            phase_counter <= 0;
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;