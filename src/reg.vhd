-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Register containing 8 16-bits arrays.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity reg is
    generic (REG_WIDTH : natural := 16;
             SIZE      : natural := 4); -- 2 to the power of SIZE
    port (I_clk  : in STD_LOGIC; -- Clock signal
          I_reset: in STD_LOGIC; -- Reset signal
          I_en   : in STD_LOGIC; -- Enable

          I_dataD: in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- Input Data
          I_selD : in STD_LOGIC_VECTOR (SIZE-1 downto 0);       -- Input - select destination
          I_selA : in STD_LOGIC_VECTOR (SIZE-1 downto 0);       -- Input - select source A
          O_dataA: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Output A
          I_selB : in STD_LOGIC_VECTOR (SIZE-1 downto 0);       -- Input - select source B
          O_dataB: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Output B
          I_we   : in STD_LOGIC);                               -- Write Enable (write the destination value or not)
end reg;

-- =================
--   Architecture
-- =================

architecture arch_reg of reg is
    -- Internal Objects
    type store_t is array (0 to 2**SIZE-1) of STD_LOGIC_VECTOR(REG_WIDTH-1 downto 0); -- Array of given number SLVs set to a given size
    signal reg_bank: store_t := (others => X"0000");                                  -- Affectation of the array and initialization at 0
begin
    -- Processes
    TransferData: process(I_clk) -- I_clk added to the sensitivity list of the process
    begin
        -- Reset initialization
        if I_reset='0' then
          reg_bank <= (others => X"0000");
        end if;
        -- Rising edge data transfer IA=>OA, IB=>OB and DATA=>RD if WE
        if rising_edge(I_clk) and I_en='1' then -- If new cycle and enable
            O_dataA <= reg_bank(to_integer(unsigned(I_selA)));     -- Propagate the input to the output (A)
            O_dataB <= reg_bank(to_integer(unsigned(I_selB)));     -- Propagate the input to the output (B)
            if (I_we = '1') then                                   -- If write-enable propagate the data
                reg_bank(to_integer(unsigned(I_selD))) <= I_dataD; -- Write dataD to the selD register
            end if;
        end if;
    end process;
end arch_reg;
