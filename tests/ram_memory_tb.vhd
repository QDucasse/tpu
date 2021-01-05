-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the ram entity.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

-- =================
--      Entity
-- =================

entity ram_memory_tb is
end ram_memory_tb;

-- =================
--   Architecture
-- =================

architecture arch_ram_memory_tb of ram_memory_tb is
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal reset_n : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;

    -- Constants
    constant MEM_SIZE   : natural := 8;
    constant INSTR_SIZE : natural := 16;

    -- Signals for entity
    signal I_we    : STD_LOGIC;
    signal I_addr  : STD_LOGIC_VECTOR (MEM_SIZE-1 downto 0);
    signal I_data  : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);
    signal O_data  : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);


    begin
    -- Clock, reset and enable signals
    reset_n <= '0', '1' after 10 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;

    -- DUT
    dut: entity work.ram_memory(arch_ram_memory)
        generic map (
          MEM_SIZE   => MEM_SIZE,
          INSTR_SIZE => INSTR_SIZE
        )
        port map (
          I_clk   => clk,
          I_reset => reset_n,
          I_we    => I_we,
          I_addr  => I_addr,
          I_data  => I_data,
          O_data  => O_data
        );


    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset_n='1';
      wait_cycles(1);
      report "RAM: Running testbench";

      -- TESTING OPERATIONS

      -- Test 1: Write/Read to RAM
      I_we <= '1'; -- Enable writing
      I_addr <= "00000010"; -- 8 bit address (memory size 32)
      I_data <= X"FEED";     -- 16-bits data
      wait_cycles(2);
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(2);
      if (O_data=X"FEED") then report "Test Write/Read 1: Passed" severity NOTE;
        else report "Test Write/Read 1: Failed" severity FAILURE;
      end if;

      -- Test 2: Write/Read to RAM
      I_we <= '1'; -- Enable writing
      I_addr <= "00000100";  -- 8 bit address (memory size 255)
      I_data <= X"CAFE";     -- 16-bits data
      wait_cycles(2);
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(2);
      if (O_data=X"CAFE") then report "Test Write/Read 2: Passed" severity NOTE;
        else report "Test Write/Read 2: Failed" severity FAILURE;
      end if;

      running <= false;
      report "RAM: Testbench complete";
    end process;

end arch_ram_memory_tb;
