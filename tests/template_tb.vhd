-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Template for VHDL components

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
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal reset_n : std_logic  := '0';  -- Reset signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;


    begin
    -- Clock, reset and enable signals
    reset_n <= '0', '1' after 10 ns;
    enable  <= '0', '1' after 50 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;
    -- DUT
    dut: work.template(arch_template) PORT MAP(
      );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset_n='1';
      wait_cycles(10);
      report "TEMPLATE: Running testbench";
      -- TESTING OPERATIONS
      if (true) then report "Test: Passed" severity NOTE;
        else report "Test: Failed" severity FAILURE;
      end if;

      running <= false;
      report "TEMPLATE: Testbench complete";
    end process;

end arch_template_tb;
