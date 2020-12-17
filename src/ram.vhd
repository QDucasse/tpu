-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity ram_16 is
    port (I_clk  : in STD_LOGIC;                       -- Clock signal
          I_we   : in STD_LOGIC;                       -- Enable
          I_addr : in STD_LOGIC_VECTOR (15 downto 0);  -- 16-bit Instruction
          I_data : in STD_LOGIC_VECTOR (15 downto 0);  -- Register A from instruction
          O_data : out STD_LOGIC_VECTOR (15 downto 0)  -- Register B from instruction
          );
end ram_16;

-- =================
--   Architecture
-- =================

architecture arch_ram16 of ram_16 is
    -- Internal Objects
    type store_t is array (0 to 31) of STD_LOGIC_VECTOR(15 downto 0);  -- 32 16-bit addresses
    signal ram: store_t := (others => X"0000");                     -- Affectation of the array and initialization at 0

begin
  -- Processes
  TransferData: process(I_clk) -- I_clk added to the sensitivity list of the process
  begin
      if rising_edge(I_clk) then      -- If new cycle and enable
          if (I_we = '1') then        -- If write-enable propagate the data
              ram(to_integer(unsigned(I_addr(5 downto 0)))) <= I_data; -- Propagate the input to RAM address
          else
              O_data <= ram(to_integer(unsigned(I_addr(5 downto 0)))); -- Write the contents of the address to the output
          end if;
      end if;
  end process;
end arch_ram16;
