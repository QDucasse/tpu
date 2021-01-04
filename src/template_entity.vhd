-- Template for VHDL components

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity template is
    port (I_clk  : in STD_LOGIC;                       -- Clock signal
          I_en   : in STD_LOGIC;                       -- Enable
          I_data : in STD_LOGIC_VECTOR (15 downto 0);  -- 16-bit Input data
          O_data : out STD_LOGIC_VECTOR (15 downto 0)  -- 16-bit output data
          );
end template;

-- =================
--   Architecture
-- =================

architecture arch_template of template is
    -- Internal Objects
    -- None
begin
    -- Processes
    Process1: process(I_clk) -- I_clk added to the sensitivity list of the process
    begin
        if rising_edge(I_clk) and I_en='1' then  -- If new cycle and enable
            Output_data <= Input_data;
        end if;
    end process;
end arch_template;
