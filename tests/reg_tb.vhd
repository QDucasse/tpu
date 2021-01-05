-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the register entity

-- =================
--    Libraries
-- =================

library ieee;
use IEEE.std_logic_1164.all;

-- =================
--      Entity
-- =================

entity reg_tb is
end reg_tb;

-- =================
--   Architecture
-- =================

architecture arch_reg_tb of reg_tb is

    -- Clock and Reset signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;

    -- Constants for the entity
    constant REG_WIDTH : natural := 16;
    constant SIZE      : natural := 3;

    -- Signal definitions for the entity
    signal I_dataD : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_selD  : STD_LOGIC_VECTOR (SIZE-1 downto 0);
    signal I_selA  : STD_LOGIC_VECTOR (SIZE-1 downto 0);
    signal O_dataA : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_selB  : STD_LOGIC_VECTOR (SIZE-1 downto 0);
    signal O_dataB : STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
    signal I_we    : STD_LOGIC;

begin
   -- Clock, reset and enable signals
   reset <= '0', '1' after 10 ns;
   enable  <= '0', '1' after 50 ns;
   clk <= not(clk) after HALF_PERIOD when running else clk;

   -- Design Under Test (DUT)
   dut: entity work.reg(arch_reg)
        generic map (
          REG_WIDTH => REG_WIDTH,
          SIZE      => SIZE
        )
        port map (
          I_clk   => clk,
          I_reset => reset,
          I_en    => enable,

          I_dataD => I_dataD,
          I_selD  => I_selD,
          I_selA  => I_selA,
          O_dataA => O_dataA,
          I_selB  => I_selB,
          O_dataB => O_dataB,
          I_we    => I_we
        );


   -- Stimulus process
   StimulusProcess: process
   begin
      wait until reset = '1';
      wait until enable  = '1';
      wait_cycles(1);
      report "REGISTER: Running testbench";

      -- Test Write 1: Write 0xfab5 to R0
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "000";    -- Destination: R0
      I_dataD <= X"FAB5"; -- Data to write: 0xfab5
      I_we <= '1';        -- Write data on output
      wait_cycles(1);
      I_selA <= "000";    -- Read R0 -> Write to O_dataA
      wait_cycles(2);
      if (O_dataA=X"FAB5") then report "Test Write 1: Passed" severity NOTE;
        else report "Test Write 1: Failed" severity FAILURE;
      end if;

      -- Test Write 2: Write 0x2222 to R2
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"2222"; -- Data to write: 0x2222
      I_we <= '1';        -- Write data on output
      wait_cycles(1);
      I_selA <= "010";    -- Read R0 -> Write to O_dataA
      wait_cycles(2);
      if (O_dataA=X"2222") then report "Test Write 2: Passed" severity NOTE;
        else report "Test Write 2: Failed" severity FAILURE;
      end if;

      -- Test Write 3: Write 0x3333 to R2
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"3333"; -- Data to write: 0x3333
      I_we <= '1';        -- Write data on output
      wait_cycles(1);
      I_selA <= "010";    -- Read R2 -> Write to O_dataA
      I_selB <= "000";
      wait_cycles(2);
      if (O_dataA=X"3333") then report "Test Write 3: Passed" severity NOTE;
        else report "Test Write 3: Failed" severity FAILURE;
      end if;

      -- Test No Write: Prepare data for write but no write since no we
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"FEED"; -- Data to write: 0xFEED
      I_we <= '0';        -- DO NOT write the data on output
      wait_cycles(1);
      I_selA <= "010";    -- Read R2 -> Write to O_dataA
      wait_cycles(2);
      if (O_dataA=X"FEED") then report "Test No Write: Failed" severity FAILURE;
        else report "Test No Write: Passed" severity NOTE;
      end if;


      -- Test Combined Read: Write 0x4444 to R4 and read it on both inputs
      I_selA <= "000";
      I_selB <= "001";
      I_selD <= "100";
      I_dataD <= X"4444";
      I_we <= '1';
      wait_cycles(1);

      -- Wait for several cycles
      I_we <= '0';
      wait_cycles(1);

      -- No operations
      wait_cycles(1);

      I_selA <= "100";
      I_selB <= "100";
      wait_cycles(2);
      if (O_dataA=X"4444" and O_dataB=X"4444") then report "Test Combined Read: Passed" severity NOTE;
        else report "Test Combined Read: Failed" severity FAILURE;
      end if;

      running <= false;
      report "REGISTER: Testbench Complete";
   end process;

end arch_reg_tb;
