library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_segment_decoder is
    Port (
        input : in  STD_LOGIC_VECTOR (3 downto 0);  -- 4-bit input vector
        ai, bi, ci, di, ei, fi, gi : out STD_LOGIC; -- Output signals for each segment
        t : in STD_LOGIC                               -- Control signal for display behavior
    );
end seven_segment_decoder;

architecture Behavioral of seven_segment_decoder is
begin
    process (input,t)
        variable A, B, C, D : STD_LOGIC;
        variable Seven_Segment : STD_LOGIC_VECTOR(6 downto 0);
    begin
        -- Check if t is 1; if so, set specific outputs as required
        if t = '1' then
            -- Set all segments except gi to 1
            ai <= '1';
            bi <= '1';
            ci <= '1';
            di <= '1';
            ei <= '1';
            fi <= '1';
            gi <= '0';  -- Keep gi as 0
        else
            -- Extract individual bits from the input vector
            A := input(0);
            B := input(1);
            C := input(2);
            D := input(3);
           
            -- Calculate outputs with inversion for each segment
            case input is
                when "0000" =>
                    Seven_Segment := "0000001";  -- 0
                when "0001" =>
                    Seven_Segment := "1001111";  -- 1
                when "0010" =>
                    Seven_Segment := "0010010";  -- 2
                when "0011" =>
                    Seven_Segment := "0000110";  -- 3
                when "0100" =>
                    Seven_Segment := "1001100";  -- 4
                when "0101" =>
                    Seven_Segment := "0100100";  -- 5
                when "0110" =>
                    Seven_Segment := "0100000";  -- 6
                when "0111" =>
                    Seven_Segment := "0001111";  -- 7
                when "1000" =>
                    Seven_Segment := "0000000";  -- 8
                when "1001" =>
                    Seven_Segment := "0000100";  -- 9
                when "1010" =>
                    Seven_Segment := "0001000";  -- A
                when "1011" =>
                    Seven_Segment := "1100000";  -- b
                when "1100" =>
                    Seven_Segment := "0110001";  -- C
                when "1101" =>
                    Seven_Segment := "1000010";  -- d
                when "1110" =>
                    Seven_Segment := "0110000";  -- E
                when "1111" =>
                    Seven_Segment := "0111000";  -- F
                when others =>
                    Seven_Segment := "1111111";  -- null (all off)
            end case;

            -- Assign the segments from Seven_Segment to ai, bi, ci, etc.
            ai <= Seven_Segment(6);
            bi <= Seven_Segment(5);
            ci <= Seven_Segment(4);
            di <= Seven_Segment(3);
            ei <= Seven_Segment(2);
            fi <= Seven_Segment(1);
            gi <= Seven_Segment(0);
        end if;
    end process;
end Behavioral;
