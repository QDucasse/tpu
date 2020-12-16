-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity reg16_8 is
    port (I_clk  : in STD_LOGIC;                          -- Clock signal
          I_en   : in STD_LOGIC;                          -- Enable
          I_dataD: in STD_LOGIC_VECTOR (15 downto 0);     -- Input Data
          O_dataA: out STD_LOGIC_VECTOR (15 downto 0);    -- Output A
          O_dataB: out STD_LOGIC_VECTOR (15 downto 0);    -- Output B
          I_selA : in STD_LOGIC_VECTOR (2 downto 0);      -- Input source A
          I_selB : in STD_LOGIC_VECTOR (2 downto 0);      -- Input source B
          I_selD : in STD_LOGIC_VECTOR (2 downto 0);      -- Input destination
          I_we   : in STD_LOGIC);                         -- Write Enable (write the destination value or not)
end reg16_8;

-- =================
--   Architecture
-- =================

architecture arch_reg16_8 of reg16_8 is
    -- Internal Objects
    type store_t is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0); -- Array of 8 SLVs containing 16 bits each
    signal regs: store_t := (others => X"0000");                     -- Affectation of the array and initialization at 0
begin
    -- Processes
    TransferData: process(I_clk) -- I_clk added to the sensitivity list of the process
    begin
        if rising_edge(I_clk) and I_en='1' then                       -- If new cycle and enable
            O_dataA <= regs(to_integer(unsigned(I_selA)));            -- Propagate the input to the output (A)
            O_dataB <= regs(to_integer(unsigned(I_selB)));            -- Propagate the input to the output (B)
            if (I_we = '1') then                                      -- If write-enable propagate the data
                regs(to_integer(unsigned(I_selD))) <= I_dataD;        -- Write dataD to the selD register
            end if;
        end if;
    end process;
end arch_reg16_8;
