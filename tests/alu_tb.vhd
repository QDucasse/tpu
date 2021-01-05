-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench file for the ALU

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

    -- Entity constants
    constant REG_WIDTH : natural := 16;
    constant OP_SIZE   : natural := 4;

    -- Entity Signals
    signal I_dataA        : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_dataB        : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_dataDwe      : STD_LOGIC;
    signal I_aluop        : STD_LOGIC_VECTOR (OP_SIZE downto 0);
    signal I_PC           : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_dataImm      : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal O_dataResult   : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal O_dataWriteReg : STD_LOGIC;
    signal O_shouldBranch : STD_LOGIC;

    begin
    -- Clock, reset and enable signals
    reset_n <= '0', '1' after 10 ns;
    enable  <= '0', '1' after 50 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;
    -- DUT
    dut: entity work.alu(arch_alu)
        generic map (
          REG_WIDTH => REG_WIDTH,
          OP_SIZE   => OP_SIZE
        )
        port map (
          I_clk          => clk,
          I_en           => enable,
          I_reset        => reset_n,
          I_dataA        => I_dataA,
          I_dataB        => I_dataB,
          I_dataDwe      => I_dataDwe,
          I_aluop        => I_aluop,
          I_PC           => I_PC,
          I_dataImm      => I_dataImm,
          O_dataResult   => O_dataResult,
          O_dataWriteReg => O_dataWriteReg,
          O_shouldBranch => O_shouldBranch
        );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset_n='1';
      wait_cycles(10);
      report "ALU: Running testbench";
      -- TESTING OPERATIONS

      -- ADD OPERATION
      -- =============
      -- Test 1: ADD no carry/overflow
      -- Test 2: ADD with carry/overflow
      -- Test 3: ADD signed/unsigned
      if (true) then report "Test: Passed" severity NOTE;
        else report "Test: Failed" severity FAILURE;
      end if;

      if (true) then report "Test: Passed" severity NOTE;
        else report "Test: Failed" severity FAILURE;
      end if;

      -- OR OPERATION
      -- ============

      -- XOR OPERATION
      -- =============

      -- AND OPERATION
      -- =============

      -- NOT OPERATION
      -- =============

      -- LOAD OPERATION
      -- ==============
      -- Test High-half variation
      -- Test Low-half variation

      -- CMP OPERATION
      -- =============
      -- Equality
      -- A to 0
      -- B to 0

      -- Greater than - unsigned
      -- Less than - unsigned

      -- Greater than - signed
      -- less than - signed

      -- SHL OPERATION
      -- =============

      -- JUMPEQ OPERATION
      -- ================

      -- OTHER OPERATIONS
      -- ================


      running <= false;
      report "ALU: Testbench complete";
    end process;

end arch_template_tb;
