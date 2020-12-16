-- =================
--    Libraries
-- =================

library ieee;
use IEEE.std_logic_1164.all;

-- =================
--      Entity
-- =================

entity reg16_8_tb is
end reg16_8_tb;

-- =================
--   Architecture
-- =================

architecture behavior of reg16_8_tb is

    -- Component Declaration for the Unit Under Test (UUT)

    component reg16_8
    port(
         I_clk   : IN  std_logic;
         I_en    : IN  std_logic;
         I_dataD : IN  std_logic_vector(15 downto 0);
         O_dataA : OUT std_logic_vector(15 downto 0);
         O_dataB : OUT std_logic_vector(15 downto 0);
         I_selA  : IN  std_logic_vector(2 downto 0);
         I_selB  : IN  std_logic_vector(2 downto 0);
         I_selD  : IN  std_logic_vector(2 downto 0);
         I_we    : IN  std_logic
         );
    end component;

   -- Input Signals Declarations
   signal I_clk   : std_logic := '0';
   signal I_en    : std_logic := '0';
   signal I_dataD : std_logic_vector(15 downto 0) := (others => '0');
   signal I_selA  : std_logic_vector(2 downto 0) := (others => '0');
   signal I_selB  : std_logic_vector(2 downto 0) := (others => '0');
   signal I_selD  : std_logic_vector(2 downto 0) := (others => '0');
   signal I_we    : std_logic := '0';

  --Output Signals Declaration
   signal O_dataA : std_logic_vector(15 downto 0);
   signal O_dataB : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant I_clk_period : time := 10 ns;


   -- Instantiate the Design Under Test (DUT)
   begin
   dut: reg16_8 PORT MAP (
          I_clk   => I_clk,
          I_en    => I_en,
          I_dataD => I_dataD,
          O_dataA => O_dataA,
          O_dataB => O_dataB,
          I_selA  => I_selA,
          I_selB  => I_selB,
          I_selD  => I_selD,
          I_we    => I_we
        );

   -- Clock Process
   ClockProcess : process
   begin
    I_clk <= '0';
    wait for I_clk_period/2;
    I_clk <= '1';
    wait for I_clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;
      wait for I_clk_period*10;
      I_en <= '1';

      -- Test Write 1: Write 0xfab5 to R0
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "000";    -- Destination: R0
      I_dataD <= X"FAB5"; -- Data to write: 0xfab5
      I_we <= '1';        -- Write data on output
      wait for I_clk_period;
      I_selA <= "000";    -- Read R0 -> Write to O_dataA
      if (O_dataA=X"FAB5") then report "Test Write: Passed" severity NOTE;
        else report "Test Write 3 : Failed" severity FAILURE;
      end if;
      wait for I_clk_period;


      -- Test Write 2: Write 0x2222 to R2
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"2222"; -- Data to write: 0x2222
      I_we <= '1';        -- Write data on output
      wait for I_clk_period;
      I_selA <= "010";    -- Read R0 -> Write to O_dataA
      if (O_dataA=X"2222") then report "Test Write: Passed" severity NOTE;
        else report "Test Write 3 : Failed" severity FAILURE;
      end if;
      wait for I_clk_period;


      -- Test Write 3: Write 0x3333 to R2
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"3333"; -- Data to write: 0x2222
      I_we <= '1';        -- Writ data on output
      wait for I_clk_period;
      I_selA <= "010";    -- Read R2 -> Write to O_dataA
      I_selB <= "000";
      if (O_dataA=X"3333") then report "Test Write: Passed" severity NOTE;
        else report "Test Write 3 : Failed" severity FAILURE;
      end if;
      wait for I_clk_period;

      -- Test No Write: Prepare data for write but no write since no we
      I_selA <= "000";    -- Read R0
      I_selB <= "001";    -- Read R1
      I_selD <= "010";    -- Destination: R2
      I_dataD <= X"3333"; -- Data to write: 0x2222
      I_we <= '0';        -- DO NOT write the data on output
      wait for I_clk_period;
      I_selA <= "010";    -- Read R2 -> Write to O_dataA
      if (O_dataA=X"FEED") then report "Test No Write: Failed" severity FAILURE;
        else report "Test No Write: Passed" severity NOTE;
      end if;
      wait for I_clk_period;


      -- Test Combined Read: Write 0x4444 to R4 and read it on both inputs
      I_selA <= "000";
      I_selB <= "001";
      I_selD <= "100";
      I_dataD <= X"4444";
      I_we <= '1';
      wait for I_clk_period;

      -- Wait for several cycles
      I_we <= '0';
      wait for I_clk_period;

      -- No operations
      wait for I_clk_period;

      I_selA <= "100";
      I_selB <= "100";
      wait for I_clk_period;
      if (O_dataA=X"4444" and O_dataB=X"4444") then report "Test No Write: Passed" severity NOTE;
        else report "Test No Write: Failed" severity FAILURE;
      end if;
      wait for I_clk_period;
      wait;

   end process;

end;
