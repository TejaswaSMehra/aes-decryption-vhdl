library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity final is
    Port (
        inputi   : in  STD_LOGIC_VECTOR (15 downto 0);  -- 4-digit input vector
        clk_ini  : in  STD_LOGIC;
        reseti   : in  STD_LOGIC;
        t        : in  STD_LOGIC_VECTOR (3 downto 0);   -- Control for display visibility
        anodesi  : out STD_LOGIC_VECTOR (3 downto 0);
        aii, bii, cii, dii, eii, fii, gii : out STD_LOGIC
    );
end final;

architecture Behavioral of final is

    component seven_segment_decoder
        Port (
            input : in  STD_LOGIC_VECTOR (3 downto 0);  -- 4-bit input vector
            ai, bi, ci, di, ei, fi, gi : out STD_LOGIC;
            t : in STD_LOGIC                 -- Control signal to disable display if '1'
        );
    end component;

    component Timing_block is
        Port (
            clk_in     : in  STD_LOGIC;                 -- 100 MHz input clock
            reset      : in  STD_LOGIC;                 -- Reset signal
            mux_select : out STD_LOGIC_VECTOR (1 downto 0); -- Signal for the mux
            anodes     : out STD_LOGIC_VECTOR (3 downto 0)  -- Anodes signal for display
        );
    end component;

    -- Signals for internal use
    signal mux_selecter : STD_LOGIC_VECTOR (1 downto 0); 
    signal digiter      : STD_LOGIC_VECTOR (3 downto 0);
    signal temp         : STD_LOGIC;  -- Signal to control visibility based on t

begin

    -- Instantiate Timing_block component
    timers : Timing_block 
        port map (
            clk_in     => clk_ini,
            reset      => reseti,
            mux_select => mux_selecter,
            anodes     => anodesi
        );

    -- Process to select the appropriate digit based on mux_selecter
    digit_selecter : process(mux_selecter, inputi, t)
    begin
        case mux_selecter is
            when "11" => 
                digiter <= inputi(3 downto 0);    -- Activate digit 0
                temp <= t(0);                     -- Set temp based on t(0)
                
            when "10" => 
                digiter <= inputi(7 downto 4);    -- Activate digit 1
                temp <= t(1);                     -- Set temp based on t(1)
                
            when "01" => 
                digiter <= inputi(11 downto 8);   -- Activate digit 2
                temp <= t(2);                     -- Set temp based on t(2)
                
            when "00" => 
                digiter <= inputi(15 downto 12);  -- Activate digit 3
                temp <= t(3);                     -- Set temp based on t(3)
                
            when others => 
                digiter <= "0000";               -- Default (all off)
                temp <= '0';                     -- Set temp to default value
        end case;
    end process;

    -- Instantiate seven_segment_decoder component
    segmenters : seven_segment_decoder 
        port map (
            input => digiter,
            ai    => aii,
            bi    => bii,
            ci    => cii,
            di    => dii,
            ei    => eii,
            fi    => fii,
            gi    => gii,
            t     => temp
        );

end Behavioral;
