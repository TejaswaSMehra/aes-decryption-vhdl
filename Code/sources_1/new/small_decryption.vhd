library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity AES_decryptor2 is
    Port (
        clk             : in std_logic;
        reset           : in std_logic := '0';
        start           : in std_logic;
        decrypted_data0 : out std_logic_vector(31 downto 0);
        decrypted_data1 : out std_logic_vector(31 downto 0);
        decrypted_data2 : out std_logic_vector(31 downto 0);
        decrypted_data3 : out std_logic_vector(31 downto 0);
        done            : out std_logic;
        round_port      : out integer;
        byte_counter_port    : out integer;
        phase_counter_port    : out integer;
        cipher_text_dout_port   : out std_logic_vector(7 downto 0);
        ram_address : out std_logic_vector(3 downto 0);
        state0_output : out std_logic_vector(31 downto 0)
    );
end AES_decryptor2;

architecture Behavioral of AES_decryptor2 is

    type state_type is (
        IDLE, LOAD_CIPHERTEXT, LOAD_KEY, 
        ADD_ROUND_KEY,
        INVERSE_SUB_BYTES,
        INVERSE_SHIFT_ROWS,
        INVERSE_MIX_COLUMNS,
        DONE_PARTIALLY,
        DONE_FULLY
    );
    signal state : state_type := IDLE;

    signal memory_cycles      : integer := 0;
    signal round              : integer := 9;
    signal byte_counter       : integer range 0 to 15 := 0;

    -- Signals for memory and data
    signal key_rom_addr       : std_logic_vector(7 downto 0) := (others => '0');
    signal key_rom_dout       : std_logic_vector(7 downto 0) := (others => '0');
    signal ciphertext_addr    : std_logic_vector(3 downto 0) := (others => '0');
    signal ciphertext_dout    : std_logic_vector(7 downto 0) := (others => '0');
    signal inv_sbox_in        : std_logic_vector(7 downto 0) := (others => '0');
    signal inv_sbox_out       : std_logic_vector(7 downto 0) := (others => '0');
    signal ram_addr           : std_logic_vector(3 downto 0) := (others => '0');
    signal ram_data_in        : std_logic_vector(7 downto 0);
    signal ram_data_out       : std_logic_vector(7 downto 0) := (others => '0');
    signal ram_wea            : std_logic_vector(0 downto 0) := (others => '0');              -- Write enable for RAM  
    
    -- Internal signals for component outputs
    signal inverse_subbytes_out : std_logic_vector(7 downto 0) := (others => '0');
    signal inverse_shiftrows_out: std_logic_vector(31 downto 0) := (others => '0');
    signal inverse_mixcolumns_out : std_logic_vector(31 downto 0) := (others => '0');
    signal xor_result : std_logic_vector(7 downto 0) := (others => '0');  -- Result of XOR operation
    signal xor_input : std_logic_vector(7 downto 0) := (others => '0');  -- Result of XOR operation
    signal selected_key_byte : std_logic_vector(7 downto 0) := (others => '0');  -- Byte fetched from round keys
    signal phase_counter : integer range 0 to 2 := 0; -- 0: Read, 1: Process, 2: Write
    signal phase_counter2 : integer range 0 to 2 := 0; -- 0: Read, 1: Process, 2: Write
    signal row_counter : integer range 0 to 3 := 0;
    signal column_counter : integer range 0 to 3 := 0;

    -- Internal state vectors (broken into 32 bits each)
    signal state0, state1, state2, output_data : std_logic_vector(31 downto 0) := (others => '0');
    signal s : std_logic_vector(1 downto 0) := (others => '0');
    -- Component declarations
    component blk_mem_gen_1
        Port (
            clka       : in std_logic;
            rsta       : in std_logic;
            ena        : in std_logic;
            addra      : in std_logic_vector(3 downto 0);
            douta      : out std_logic_vector(7 downto 0);
            rsta_busy  : out std_logic
        );
    end component;

    component blk_mem_gen_2
        Port (
            clka       : in std_logic;
            rsta       : in std_logic;
            ena        : in std_logic;
            addra      : in std_logic_vector(7 downto 0);
            douta      : out std_logic_vector(7 downto 0);
            rsta_busy  : out std_logic
        );
    end component;
    
    component Intermediate_RAM
        Port (
            clka    : in std_logic;
            rsta    : in std_logic;
            ena     : in std_logic;
            wea     : in std_logic_vector(0 downto 0);  -- Write enable
            addra   : in std_logic_vector(3 downto 0);  -- 4-bit address for 16 depth
            dina    : in std_logic_vector(7 downto 0);  -- 8-bit data input
            douta   : out std_logic_vector(7 downto 0)  -- 8-bit data output
        );
    end component;

    component dist_mem_gen_0
        Port ( a : in std_logic_vector(7 downto 0); spo : out std_logic_vector(7 downto 0) );
    end component; 
    component xor_gate_8bit
        Port (
        a      : in std_logic_vector(7 downto 0);        -- 8-bit input A
        b      : in std_logic_vector(7 downto 0);        -- 8-bit input B
        result : out std_logic_vector(7 downto 0)        -- 8-bit XOR result
        );
    end component;
    component InverseSubBytes
        Port ( input_byte : in std_logic_vector(7 downto 0); output_byte : out std_logic_vector(7 downto 0) );
    end component;
    component InverseShiftRows
        Port ( state : in std_logic_vector(31 downto 0); s : in std_logic_vector(1 downto 0); result : out std_logic_vector(31 downto 0) );
    end component;
    component InvMixColumns
        Port ( input_column : in std_logic_vector(31 downto 0); output_column : out std_logic_vector(31 downto 0) );
    end component;
    
begin

    ciphertext_mem : blk_mem_gen_1 port map (clka => clk, rsta => reset, ena => '1', addra => ciphertext_addr, douta => ciphertext_dout, rsta_busy => open);
    key_ROM : blk_mem_gen_2 port map (clka => clk, rsta => reset, ena => '1', addra => key_rom_addr, douta => key_rom_dout, rsta_busy => open);
    inv_sbox : dist_mem_gen_0 port map ( a => inv_sbox_in, spo => inv_sbox_out );
    intermediate_RAM_port : Intermediate_RAM port map ( clka => clk, rsta => reset, ena => '1', wea => ram_wea, addra => ram_addr, dina => ram_data_in, douta => ram_data_out );
    xor_inst : xor_gate_8bit port map ( a => xor_input,  b => selected_key_byte, result => xor_result );
    
    InverseSubBytes_inst : InverseSubBytes
        port map ( input_byte => inv_sbox_in, output_byte => inverse_subbytes_out );

    InverseShiftRows_inst : InverseShiftRows
        port map ( state => state1, s => s, result => inverse_shiftrows_out );

    InvMixColumns_inst : InvMixColumns
        port map ( input_column => state2, output_column => inverse_mixcolumns_out );
    
    round_port <= round;
    byte_counter_port <= byte_counter;
    phase_counter_port <= phase_counter;
    cipher_text_dout_port <= ram_data_out; 
    ram_address <= ram_addr;
    
    -- Single process FSM with memory cycle delay handling
    process(clk)
    -- Declare the variable at the beginning of the process
    variable state0_var : std_logic_vector(31 downto 0) := (others => '0');

    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                memory_cycles <= 0;
                done <= '0';
                round <= 9;
            elsif memory_cycles > 0 then
                memory_cycles <= memory_cycles - 1;
            else

                case state is
                   when IDLE =>
                    if start = '1' then
                        memory_cycles <= 4;
                        state <= LOAD_CIPHERTEXT;
                        byte_counter <= 0;  -- Initialize byte counter for loading
                        ciphertext_addr <= std_logic_vector(to_unsigned(byte_counter, 4));  -- Set initial ciphertext address
                    end if;
                
                    when LOAD_CIPHERTEXT =>
                        case phase_counter is
                            -- Phase 0: Set the address to read from ciphertext memory
                            when 0 =>
                                ram_wea <= "0";
                                ciphertext_addr <= std_logic_vector(to_unsigned(byte_counter, 4));  -- Set ciphertext address based on byte_counter
                                memory_cycles <= 2;  -- Delay for memory read
                                phase_counter <= 1;  -- Move to next phase
                    
                            -- Phase 1: Capture the data from ciphertext memory
                            when 1 =>
                                ram_data_in <= ciphertext_dout;  -- Capture data from ciphertext output to RAM input
                                memory_cycles <= 2;  -- Delay to ensure data stability
                                ram_wea <= "1";  -- Enable write to RAM
                                ram_addr <= std_logic_vector(to_unsigned(byte_counter, 4));  -- Set RAM address based on byte_counter
                                memory_cycles <= 4;  -- Wait for write to complete
                                phase_counter <= 2;  -- Move to increment phase
                    
                            -- Phase 3: Increment byte_counter or finalize loading
                            when 2 =>
                                ram_wea <= "0";  -- Disable RAM write after completion
                                if byte_counter < 15 then
                                    byte_counter <= byte_counter + 1;  -- Increment to load the next byte
                                    phase_counter <= 0;  -- Reset phase counter for the next byte
                                    memory_cycles <= 2;  -- Small delay before next byte
                                else
                                    byte_counter <= 0;  -- Reset byte_counter after all bytes are loaded
                                    phase_counter <= 0;  -- Reset phase counter
                                    memory_cycles <= 2;  -- Delay before state transition
                                    state <= INVERSE_MIX_COLUMNS;  -- Transition to the next state
                                end if;
                    
                        end case;


                   
                    when ADD_ROUND_KEY =>
                       case phase_counter is
                            -- Phase 1: Read from RAM and round key
                            when 0 =>
                                ram_addr <= std_logic_vector(to_unsigned(byte_counter, 4));               -- Set RAM address
                                key_rom_addr <= std_logic_vector(to_unsigned((9-round) * 16 + byte_counter, 8)); -- Set key address for round key byte
                                memory_cycles <= 2;                                                -- Wait 2 cycles for read
                                phase_counter <= 1;                                                       -- Move to process phase
                                ram_wea <= "0";
                            -- Phase 2: Perform XOR operation
                            when 1 =>
                                xor_input <= ram_data_out;                                                -- Load RAM data for XOR
                                selected_key_byte <= key_rom_dout;                                        -- Load round key byte for XOR
                                memory_cycles <= 2;                                                       -- Wait 2 cycles for XOR gate processing
                                phase_counter <= 2;                                                       -- Move to write phase
                    
                            -- Phase 3: Write XOR result back to RAM
                            when 2 =>
                                ram_data_in <= xor_result;                                                -- Set XOR result as RAM input
                                ram_wea <= "1";                                                           -- Enable write to RAM
                                memory_cycles <= 4;                                                       -- Wait 4 cycles for write
                                phase_counter <= 0;                                                       -- Reset phase counter for next byte
                    
                                if byte_counter < 15 then
                                    byte_counter <= byte_counter + 1;                                     -- Increment to next byte
                                else
                                    byte_counter <= 0;    
                                    if round = 0 then                                      -- Disable write after last byte
                                        round <= round + 1;
                                        state <= INVERSE_SHIFT_ROWS;
                                     elsif round = 9 then
                                        state <= DONE_PARTIALLY;
                                        done <= '1';
                                        round <= 0;
                                     else                                   -- Disable write after last byte
                                        round <= round + 1;
                                        state <= INVERSE_MIX_COLUMNS;
                                     end if;             
                                end if;
                        end case;

                    -- Other steps for InverseShiftRows, InverseMixColumns, STORE_INTERMEDIATE, etc.
                    when INVERSE_SUB_BYTES =>
                        case phase_counter is
                            -- Phase 1: Read from RAM
                            when 0 =>
                                ram_addr <= std_logic_vector(to_unsigned(byte_counter, 4));  -- Set RAM address for read
                                memory_cycles <= 2;                                          -- Wait 2 cycles for read
                                phase_counter <= 1;
                                ram_wea <= "0";                                          -- Move to process phase
                    
                            -- Phase 2: Process with Inverse S-box
                            when 1 =>
                                inv_sbox_in <= ram_data_out;                                 -- Data from RAM goes to S-box input
                                memory_cycles <= 2;                                          -- Wait 2 cycles for S-box processing
                                phase_counter <= 2;                                          -- Move to write phase
                    
                            -- Phase 3: Write back to RAM
                            when 2 =>
                                ram_data_in <= inv_sbox_out;                                 -- S-box output to RAM input
                                ram_wea <= "1";                                              -- Enable write to RAM
                                memory_cycles <= 4;                                          -- Wait 4 cycles for write
                                phase_counter <= 0;                                          -- Reset phase counter for next byte
                    
                                if byte_counter < 15 then
                                    byte_counter <= byte_counter + 1;                        -- Increment byte counter
                                else
                                    byte_counter <= 0;                                        -- Disable write after last byte
                                    state <= ADD_ROUND_KEY;   
                                    phase_counter <= 0;                          -- Move to next state
                                end if;
                        end case;
                        
                        
                    when INVERSE_SHIFT_ROWS =>
                        case phase_counter is
                            -- Phase 1: Read each byte of the row from RAM
                            when 0 =>
                                ram_addr <= std_logic_vector(to_unsigned(row_counter * 4 + byte_counter, 4));  -- Set RAM address for current byte
                                memory_cycles <= 2;                                                            -- Wait 2 cycles for read
                                phase_counter <= 1;                                                            -- Move to process phase
                                ram_wea <= "0";
                            -- Phase 2: Build the 32-bit `state0` one byte at a time
                            when 1 =>
                                case byte_counter is
                                   when 3 => state0_var(7 downto 0) := ram_data_out;
                                   when 2 => state0_var(15 downto 8) := ram_data_out;
                                   when 1 => state0_var(23 downto 16) := ram_data_out;
                                   when 0 => state0_var(31 downto 24) := ram_data_out;
                                   when others => null;
                                end case;
                                
                                case row_counter is
                                    when 0 =>
                                        s <= "00";  -- No shift for the first row
                                    when 1 =>
                                        s <= "01";  -- Shift by 1 byte for the second row
                                    when 2 =>
                                        s <= "10";  -- Shift by 2 bytes for the third row
                                    when 3 =>
                                        s <= "11";  -- Shift by 3 bytes for the fourth row
                                    when others =>
                                        s <= "00";  -- Default to no shift in case of an error
                                end case;

                                             
                                if byte_counter < 3 then
                                    byte_counter <= byte_counter + 1;               -- Continue to next byte within the row
                                    phase_counter <= 0; 
                                else
                                    byte_counter <= 0;                              -- Reset byte counter after completing row
                                    memory_cycles <= 2;                             -- Delay for processing
                                    phase_counter <= 2;                             -- Move to write phase
                                    state1 <= state0_var ;
                                end if;
                    
                            -- Phase 3: Write each byte of the shifted row back to RAM
                            when 2 =>
                                case byte_counter is
                                    when 3 =>
                                        ram_data_in <= inverse_shiftrows_out(7 downto 0);   -- Write LSB byte of result
                                    when 2 =>
                                        ram_data_in <= inverse_shiftrows_out(15 downto 8);  -- Write second byte of result
                                    when 1 =>
                                        ram_data_in <= inverse_shiftrows_out(23 downto 16); -- Write third byte of result
                                    when 0 =>
                                        ram_data_in <= inverse_shiftrows_out(31 downto 24); -- Write MSB byte of result
                                    when others =>
                                        null;
                                end case;
                    
                                ram_addr <= std_logic_vector(to_unsigned(row_counter * 4 + byte_counter, 4));  -- Set RAM address
                                ram_wea <= "1";                                                              -- Enable write to RAM
                                memory_cycles <= 4;
                                
                                if byte_counter < 3 then
                                    byte_counter <= byte_counter + 1;             -- Move to next byte within the row
                                else
                                    byte_counter <= 0;                            -- Reset byte counter after completing row
                                    if row_counter < 3 then
                                        row_counter <= row_counter + 1;           -- Move to next row
                                        phase_counter <= 0;                       -- Reset to start phase for next row
                                    else
                                        row_counter <= 0;                         -- Reset row counter after all rows are processed
                                        phase_counter <= 0;
                                        state <= INVERSE_SUB_BYTES;             -- Move to the next state
                                    end if;
                                end if;
                        end case;

                    when INVERSE_MIX_COLUMNS =>
                        case phase_counter is
                            -- Phase 1: Read each byte of the column from RAM
                            when 0 =>
                                ram_addr <= std_logic_vector(to_unsigned(column_counter + byte_counter * 4, 4));  -- Set RAM address for current byte in the column
                                memory_cycles <= 4;                                                               -- Wait 2 cycles for read
                                phase_counter <= 1;                                                               -- Move to process phase
                                ram_wea <= "0";
                            -- Phase 2: Build the 32-bit `state0` one byte at a time
                            when 1 =>
                                state0_output <= state0_var ;
                                case byte_counter is
                                   when 3 => state0_var(7 downto 0) := ram_data_out;
                                   when 2 => state0_var(15 downto 8) := ram_data_out;
                                   when 1 => state0_var(23 downto 16) := ram_data_out;
                                   when 0 => state0_var(31 downto 24) := ram_data_out;
                                   when others => null;
                                 
                                end case;
                    
                                if byte_counter < 3 then
                                    byte_counter <= byte_counter + 1;               -- Continue to next byte within the column
                                    phase_counter <= 0;                             -- Return to read phase for the next byte
                                else
                                    byte_counter <= 0;                              -- Reset byte counter after completing column
                                    memory_cycles <= 2;                             -- Delay for processing
                                    state2 <= state0_var;
                                    phase_counter <= 2;                             -- Move to write phase
                                    
                                end if;
                    
                            -- Phase 3: Write each byte of the transformed column back to RAM
                            when 2 =>
                                case byte_counter is
                                    when 3 =>
                                        ram_data_in <= inverse_mixcolumns_out(7 downto 0);    -- Write LSB byte of result
                                    when 2 =>
                                        ram_data_in <= inverse_mixcolumns_out(15 downto 8);   -- Write second byte of result
                                    when 1 =>
                                        ram_data_in <= inverse_mixcolumns_out(23 downto 16);  -- Write third byte of result
                                    when 0 =>
                                        ram_data_in <= inverse_mixcolumns_out(31 downto 24);  -- Write MSB byte of result
                                    when others =>
                                        null;
                                end case;
                    
                                ram_addr <= std_logic_vector(to_unsigned(column_counter + byte_counter * 4, 4));  -- Set RAM address
                                ram_wea <= "1";                                                                   -- Enable write to RAM
                                memory_cycles <= 4;                                                   -- Disable write after completing byte
                    
                                if byte_counter < 3 then
                                    byte_counter <= byte_counter + 1;           -- Move to next byte within the column
                                else
                                    byte_counter <= 0;                          -- Reset byte counter after completing column
                                    if column_counter < 3 then
                                        column_counter <= column_counter + 1;   -- Move to next column
                                        phase_counter <= 0;                     -- Reset to start phase for next column
                                    else
                                        column_counter <= 0;                    -- Reset column counter after all columns are processed
                                        phase_counter <= 0;
                                        state <= INVERSE_SHIFT_ROWS;
                                    end if;
                                end if;
                        end case;
                        
                    when DONE_PARTIALLY =>
                        case phase_counter2 is
                            -- Phase 0: Set the address to read each row from RAM
                            when 0 =>
                                ram_addr <= std_logic_vector(to_unsigned(row_counter * 4 + byte_counter, 4));  -- Set address for current byte
                                memory_cycles <= 2;  -- Wait for the read operation
                                phase_counter2 <= 1;  -- Move to data capture phase
                                ram_wea <= "0";  
                    
                            -- Phase 1: Wait for data to stabilize, then collect the 32-bit word for each output data register
                            when 1 =>
                                case byte_counter is
                                    when 3 =>
                                        output_data(7 downto 0) <= ram_data_out;  -- Set LSB byte of output data
                                    when 2 =>
                                        output_data(15 downto 8) <= ram_data_out; -- Set second byte of output data
                                    when 1 =>
                                        output_data(23 downto 16) <= ram_data_out; -- Set third byte of output data
                                    when 0 =>
                                        output_data(31 downto 24) <= ram_data_out; -- Set MSB byte of output data
                                    when others =>
                                        null;
                                end case;
                    
                                -- Increment byte_counter for each byte in a row
                                if byte_counter < 3 then
                                    byte_counter <= byte_counter + 1;  -- Move to next byte in the row
                                    phase_counter2 <= 0;  -- Return to address phase for the next byte
                                else
                                    byte_counter <= 0;  -- Reset byte counter after completing row
                                    phase_counter2 <= 2; -- Move to new phase for updating decrypted_data
                                end if;
                    
                            -- Phase 3: Update `decrypted_data` with `output_data` after ensuring `output_data` is fully updated
                            when 2 =>
                                -- Transfer completed word to the corresponding output register
                                case row_counter is
                                    when 0 =>
                                        decrypted_data0 <= output_data;
                                    when 1 =>
                                        decrypted_data1 <= output_data;
                                    when 2 =>
                                        decrypted_data2 <= output_data;
                                    when 3 =>
                                        decrypted_data3 <= output_data;
                                    when others =>
                                        null;
                                end case;
                    
                                if row_counter < 3 then
                                    row_counter <= row_counter + 1;  -- Move to the next row
                                    phase_counter2 <= 0;  -- Reset phase for the next row
                                    memory_cycles <= 2;  -- Small delay before moving to the next row
                                else
                                    row_counter <= 0;  -- Reset row counter after all rows are processed
                                    memory_cycles <= 2;  -- Delay before signaling completion
                                    done <= '1';  -- Signal the end of decryption
                                    state <= DONE_FULLY;  -- Move to DONE_FULLY state
                                end if;
                        end case;

                        
                    when DONE_FULLY =>
                        done <= '1';        
                     
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
