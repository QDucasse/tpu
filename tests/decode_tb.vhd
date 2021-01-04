-- Template for VHDL components

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

entity decode_tb is
end decode_tb;

-- =================
--   Architecture
-- =================

architecture arch_decode_tb of decode_tb is
    -- Internal Objects
    -- Clock and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;

     -- Entity signals
     signal I_dataInst : STD_LOGIC_VECTOR (15 downto 0);
     signal O_selA     : STD_LOGIC_VECTOR (2 downto 0);
     signal O_selB     : STD_LOGIC_VECTOR (2 downto 0);
     signal O_selD     : STD_LOGIC_VECTOR (2 downto 0);
     signal O_dataImm  : STD_LOGIC_VECTOR (15 downto 0);
     signal O_aluop    : STD_LOGIC_VECTOR (4 downto 0);
     signal O_regDwe   : STD_LOGIC;


begin
    -- Clock and enable signals
    enable  <= '0', '1' after 50 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;
    -- DUT
    dut: entity work.decode(arch_decode)
      port map (
        I_clk      => clk,
        I_en       => enable,
        I_dataInst => I_dataInst,
        O_selA     => O_selA,
        O_selB     => O_selB,
        O_selD     => O_selD,
        O_dataImm  => O_dataImm,
        O_aluop    => O_aluop,
        O_regDwe   => O_regDwe
      );


    -- Stimulus process
    StimulusProcess: process
      variable res1 : boolean;
      variable res2 : boolean;
      variable res3 : boolean;
      variable res4 : boolean;
      variable res5 : boolean;
      variable res6 : boolean;
    begin
      report "Running testbench for template";
      wait until enable='1';
      wait_cycles(1);

      -- TESTING OPERATIONS

      -- Test 1: RRR Instruction type
      -- OpCode Register (destination) Register (src1) Register (src2)
      I_dataInst <= "0001" & "010" & "0" & "110" & "111" & "00";
      -- op=SUB (0001), rd=R2 (010), flag=unused (0), ra=R6 (110), rb=R7 (111), unused last 2 bits
      wait_cycles(2);
      res1 := ((O_aluop = OPCODE_SUB & '0') and
               (O_selD = "010")    and
               (O_selA = "110")    and
               (O_selB = "111")    and
               (O_regDwe = '1'));
      if res1 then report "Test RRR: Passed" severity NOTE;
        else report "Test RRR: Failed" severity FAILURE;
      end if;


      -- Test 2: RRs Instruction type
      -- OpCode Register (src1) Register (src2)
      I_dataInst <= "0111" & "000" & "0" & "110" & "111" & "00";
      -- op=WRITE (0111), rd=unused (000), flag=unused (0), ra=R6 (110), rb=R7 (111), unused last 2 bits
      wait_cycles(2);
      res2 := ((O_aluop = OPCODE_WRITE & '0') and
               (O_selA = "110") and
               (O_selB = "111") and
               (O_regDwe = '0'));
      if res2 then report "Test RRs: Passed" severity NOTE;
        else report "Test RRs: Failed" severity FAILURE;
      end if;

      -- Test 3: RRd Instruction type
      -- Opcode Register (destination) Register (src1)
      I_dataInst <= "0110" & "010" & "0" & "110" & "000" & "00";
      -- op=READ (0110), rd=R2 (010), flag=unused (0), ra=R6 (110), rb=unused (000), unused last 2 bits
      wait_cycles(2);
      res3 := ((O_aluop = OPCODE_READ & '0') and
               (O_selD = "010") and
               (O_selA = "110") and
               (O_regDwe = '1'));
      if res3 then report "Test RRd: Passed" severity NOTE;
        else report "Test RRd: Failed" severity FAILURE;
      end if;

      -- Test 4: R Instruction type
      -- OpCode Register (destination)
      I_dataInst <= "1100" & "010" & "1" & "110" & "000" & "00";
      -- op=JUMP (1100), rd=R2 (010), flag=Register (1), ra=unused (000), rb=unused (000), unused last 2 bits
      wait_cycles(2);
      res4 := ((O_aluop = OPCODE_JUMP & '1') and
               (O_selD = "010") and
               (O_regDwe = '0'));
      if res4 then report "Test: Passed" severity NOTE;
        else report "Test: Failed" severity FAILURE;
      end if;

      -- Test 5: RImm Instruction type
      I_dataInst <= "1000" & "010" & "1" & "11111111";
      -- op=LOAD (1000), rd=R2 (010), flag=High (1), immediate="11111111"
      wait_cycles(2);
      res5 := ((O_aluop = OPCODE_LOAD & '1') and
               (O_selD = "010") and
               (O_dataImm = "11111111" & "11111111") and
               (O_regDwe = '1'));
      if res5 then report "Test RImm: Passed" severity NOTE;
        else report "Test RImm: Failed" severity FAILURE;
      end if;

      -- Test 6: Imm Instruction type
      I_dataInst <= "1100" & "000" & "0" & "11111111";
      -- op=JUMP (1100), rd=unused (000), flag=Immediate (0), immediate="11111111"
      wait_cycles(2);
      res6 := ((O_aluop = OPCODE_JUMP & '0') and
               (O_dataImm = "11111111" & "11111111") and
               (O_regDwe = '0'));
      if res6 then report "Test Imm: Passed" severity NOTE;
        else report "Test Imm: Failed" severity FAILURE;
      end if;

      running <= false;
      report "Testbench complete";
    end process;

end arch_decode_tb;
