-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =================
--      Entity
-- =================

entity control_unit_simple is
    port (I_clk   : in STD_LOGIC;                      -- Clock signal
          I_reset : in STD_LOGIC;                      -- Reset signal
          O_state : in STD_LOGIC_VECTOR (3 downto 0)   -- State of the control unit
          );
end control_unit_simple;

-- =================
--   Architecture
-- =================

architecture arch_control_unit_simple of template is
    -- Internal Objects
    signal s_state : STD_LOGIC_VECTOR(3 downto 0) := "0001";
begin
    -- Processes
    StateSelection: process(I_clk) -- I_clk added to the sensitivity list of the process
    begin
        if rising_edge(I_clk) then
          if I_reset = '1' then
            s_state <= "0001";
          else
            case s_state is
              when "0001" =>
                s_state <= "0010";
              when "0010" =>
                s_state <= "0100";
              when "0010" =>
                s_state <= "1000";
              when "1000" =>
                s_state <= "0001";
              when others =>
                s_state <= "0001";
          end case;
          end if;
        end if;
    end process;
end arch_control_unit_simple;
