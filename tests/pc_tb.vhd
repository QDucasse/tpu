-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Program Counter Benchmark

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.constant_codes.all;

-- =================
--      Entity
-- =================

entity pc_tb is
end pc_tb;

-- =================
--   Architecture
-- =================

architecture arch_pc_tb of pc_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;

     -- Entity Constants
     constant PC_SIZE : natural := 16;

     -- Entity Signals
     signal I_PC        : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
     signal I_PC_OPCode : STD_LOGIC_VECTOR (1 downto 0);
     signal O_PC        : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);


begin
    -- Clock, reset and enable signals
    reset <= '0', '1' after 10 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;
    -- DUT
    dut: entity work.pc(arch_pc)
        generic map (
          PC_SIZE => PC_SIZE
        )
        port map (
          I_clk       => clk,
          I_reset     => reset,
          I_PC        => I_PC,
          I_PC_OPCode => I_PC_OPCode,
          O_PC        => O_PC
        );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset='1';
      wait_cycles(10);
      report "PC: Running testbench";
      -- TESTING OPERATIONS

      -- Test 1: ASSIGN | Assign PC
      I_PC_OPCode <= PCU_OP_ASSIGN;
      I_PC <= X"FEED";
      wait_cycles(2);
      if (O_PC=X"FEED") then report "Test ASSIGN: Passed" severity NOTE;
        else report "Test ASSIGN: Failed" severity FAILURE;
      end if;

      -- Test 2: NOP | Do nothing
      I_PC_OPCode <= PCU_OP_NOP;
      wait_cycles(2);
      if (O_PC=X"FEED") then report "Test NOP: Passed" severity NOTE;
        else report "Test NOP: Failed" severity FAILURE;
      end if;

      -- Test 3: INC | Increment the PC
      I_PC_OPCode <= PCU_OP_INC;
      wait_cycles(2);
      if (O_PC=X"FEEE") then report "Test INC: Passed" severity NOTE;
        else report "Test INC: Failed" severity FAILURE;
      end if;

      -- Test 4: RESET | Reset the PC
      I_PC_OPCode <= PCU_OP_RESET;
      wait_cycles(2);
      if (O_PC=X"0000") then report "Test RESET: Passed" severity NOTE;
        else report "Test RESET: Failed" severity FAILURE;
      end if;

      running <= false;
      report "PC: Testbench complete";
    end process;

end arch_pc_tb;
