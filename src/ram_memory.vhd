-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Random Access Memory consisting of an array of 32 16-bits addresses
-- with writes and reads.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity ram_memory is
    generic(MEM_SIZE   : natural := 8;
            INSTR_SIZE : natural := 16);
    port (I_clk   : in STD_LOGIC; -- Clock signal
          I_reset : in STD_LOGIC; -- Reset signal
          I_we    : in STD_LOGIC; -- Write Enable
          I_addr  : in STD_LOGIC_VECTOR (MEM_SIZE-1 downto 0);    -- Address in the RAM
          I_data  : in STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);  -- Data to write to address in memory
          O_data  : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0)  -- Read address from memory
          );
end ram_memory;

-- =================
--   Architecture
-- =================

architecture arch_ram_memory of ram_memory is
    -- Internal Objects
    type memory_file is array (0 to 2**MEM_SIZE-1) of STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);  -- 128 16-bit addresses
    signal memory_bank: memory_file := (others => X"0000"); -- Affectation of the array and initialization at 0

begin
  -- Processes
  TransferData: process(I_clk) -- I_clk added to the sensitivity list of the process
  begin
      if I_reset='0' then
        memory_bank <= (others => X"0000");
      end if;
      if rising_edge(I_clk) then  -- If new cycle
        if (I_we = '1') then      -- If write-enable propagate the data
          -- Write the input to RAM address
          memory_bank(to_integer(unsigned(I_addr))) <= I_data;
        else
          -- Read from the address to the output
          O_data <= memory_bank(to_integer(unsigned(I_addr)));
        end if;
    end if;
  end process;
end arch_ram_memory;
