-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the decode unit

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

-- =================
--      Entity
-- =================

entity template_tb is
end template_tb;

-- =================
--   Architecture
-- =================

architecture arch_template_tb of template_tb is
    -- Internal Objects
    -- COMPONENTS (dut)
    component template
    port(clk : IN std_logic);
    end component;
    -- INPUT SIGNAL DECLARATIONS
    -- Clock and Reset signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk    : std_logic   := '0';  -- Clock signal
    signal reset_n : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;


    begin
    -- Clock and reset signals
    reset_n <= '0', '1' after 50 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;

    -- DUT
    dut: template PORT MAP(
      );

    -- Stimulus process
    StimulusProcess: process
    begin
      report "Running testbench for template"
      wait until reset_n='1';
      wait_cycles(100);
      -- TESTING OPERATIONS
      if (true) then report "Test: Passed" severity NOTE;
        else report "Test: Failed" severity FAILURE;
      end if;

      running <= false;
      report "Testbench complete"
    end process;

end arch_template_tb;
