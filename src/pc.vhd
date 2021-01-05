-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Program Counter unit, it can either:
--        - Increment the program counter
--        - Change the value of the program counter
--        - Do nothing (halt)
--        - Set the program counter to the reset vector (0x0000)

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constant_codes.all;

-- =================
--      Entity
-- =================

entity pc is
    generic (PC_SIZE    : natural := 16); -- Size of the PC register
    port (I_clk       : in  STD_LOGIC; -- Clock
          I_reset     : in  STD_LOGIC; -- Reset
          I_PC        : in  STD_LOGIC_VECTOR (PC_SIZE-1 downto 0); -- Incoming Program Counter to assign
          I_PC_OPCode : in  STD_LOGIC_VECTOR (1 downto 0);         -- Type of operation that needs to be performed
          O_PC        : out STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)  -- Output Program Counter
          );
end pc;


-- =================
--   Architecture
-- =================

architecture arch_pc of pc is
  -- Internal Objects
  -- Internal vector to keep the current PC to work on
  signal current_pc: std_logic_vector(PC_SIZE-1 downto 0) := X"0000";

begin
  -- Processes
  ProcessOperation: process (I_clk, I_reset)
  begin
    -- Reset routine
    if I_reset='0' then
      current_pc <= X"0000";
    end if;
    -- Process operation on PC
    if rising_edge(I_clk) then
      case I_PC_OPCode is
        when PCU_OP_NOP =>    -- NOP | Nothing to do, keep PC the same / halt
        when PCU_OP_INC =>    -- INC | Increment the PC
          current_pc <= std_logic_vector(unsigned(current_pc) + 1);
        when PCU_OP_ASSIGN => -- ASSIGN | Set the PC from an external input
          current_pc <= I_PC; -- Input PC to assign
        when PCU_OP_RESET =>  -- RESET | Set the PC to X"0000"
          current_pc <= X"0000";
        when others =>
      end case;
    end if;
  end process;

  -- Propagate the internal PC to the output
  O_PC <= current_pc;

end arch_pc;
