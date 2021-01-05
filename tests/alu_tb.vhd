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
use IEEE.numeric_std.all;

library work;
use work.constant_codes.all;

-- =================
--      Entity
-- =================

entity alu_tb is
end alu_tb;

-- =================
--   Architecture
-- =================

architecture arch_alu_tb of alu_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
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
    reset <= '0', '1' after 10 ns;
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
          I_reset        => reset,
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
      variable cmp : boolean := false;
    begin
      wait until reset='1';
      wait until enable='1';
      wait_cycles(10);
      report "ALU: Running testbench";
      -- TESTING OPERATIONS

      -- Default output
      if (O_dataResult=X"FEFE") then report "Test Default output: Passed" severity NOTE;
    else report "Test Default output: Failed" severity FAILURE;
      end if;


      -- ADD OPERATION
      -- =============
      -- Test 1: ADD - unsigned no carry/overflow
      I_aluop <= OPCODE_ADD & "0"; -- add opcode + unsigned flag
      I_dataA <= X"0001";
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0002" and O_shouldBranch='0';
      if (cmp) then report "Test ADD - Unsigned no Carry: Passed" severity NOTE;
        else report "Test ADD - Unsigned no Carry: Failed" severity FAILURE;
      end if;

      -- Test 2: ADD - signed no carry/overflow
      I_aluop <= OPCODE_ADD & "1"; -- add opcode + unsigned flag
      I_dataA <= X"FFFF"; -- -1 with two's complement
      I_dataB <= X"0002"; --  1
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and O_shouldBranch='0';
      if (cmp) then report "Test ADD - Signed no Carry: Passed" severity NOTE;
        else report "Test ADD - Signed no Carry: Failed" severity FAILURE;
      end if;

      -- Test 3: ADD - unsigned carry/overflow
      -- TO ADD LATER ON

      -- SUB OPERATION
      -- =============
      -- Test 1: SUB - unsigned no carry/overflow
      I_aluop <= OPCODE_SUB & "0"; -- sub opcode + unsigned flag
      I_dataA <= X"0001";
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0000" and O_shouldBranch='0';
      if (cmp) then report "Test SUB - Unsigned no Carry: Passed" severity NOTE;
        else report "Test SUB - Unsigned no Carry: Failed" severity FAILURE;
      end if;

      -- Test 2: SUB - signed no carry/overflow
      I_aluop <= OPCODE_SUB & "1"; -- sub opcode + unsigned flag
      I_dataA <= X"FFFF"; -- -1 with two's complement
      I_dataB <= X"0002"; --  1
      wait_cycles(3);
      cmp := O_dataResult=X"FFFD" and O_shouldBranch='0';
      if (cmp) then report "Test SUB - Signed no Carry: Passed" severity NOTE;
        else report "Test SUB - Signed no Carry: Failed" severity FAILURE;
      end if;

      -- Test 3: ADD - unsigned carry/overflow
      -- TO ADD LATER ON


      -- OR OPERATION
      -- ============
      I_aluop <= OPCODE_OR & "0"; -- or opcode + unused flag
      I_dataA <= X"FFFF";
      I_dataB <= X"000F";
      wait_cycles(3);
      cmp := O_dataResult=X"FFFF" and O_shouldBranch='0';
      if (cmp) then report "Test OR: Passed" severity NOTE;
        else report "Test OR: Failed" severity FAILURE;
      end if;

      -- XOR OPERATION
      -- =============
      I_aluop <= OPCODE_XOR & "0"; -- xor opcode + unused flag
      I_dataA <= X"FFFF";
      I_dataB <= X"000F";
      wait_cycles(3);
      cmp := O_dataResult=X"FFF0" and O_shouldBranch='0';
      if (cmp) then report "Test XOR: Passed" severity NOTE;
        else report "Test XOR: Failed" severity FAILURE;
      end if;

      -- AND OPERATION
      -- =============
      I_aluop <= OPCODE_AND & "0"; -- and opcode + unused flag
      I_dataA <= X"FFFF";
      I_dataB <= X"000F";
      wait_cycles(3);
      cmp := O_dataResult=X"000F" and O_shouldBranch='0';
      if (cmp) then report "Test AND: Passed" severity NOTE;
        else report "Test AND: Failed" severity FAILURE;
      end if;

      -- NOT OPERATION
      -- =============
      I_aluop <= OPCODE_NOT & "0"; -- not opcode + unused flag
      I_dataA <= X"FFFF";
      wait_cycles(3);
      cmp := O_dataResult=X"0000" and O_shouldBranch='0';
      if (cmp) then report "Test NOT: Passed" severity NOTE;
        else report "Test NOT: Failed" severity FAILURE;
      end if;


      -- LOAD OPERATION
      -- ==============
      -- Test 1: High-half
      I_aluop <= OPCODE_LOAD & "0"; -- load opcode + high flag
      I_dataImm <= X"FFFF";
      wait_cycles(3);
      cmp := O_dataResult=X"FF00" and O_shouldBranch='0';
      if (cmp) then report "Test LOAD - High: Passed" severity NOTE;
        else report "Test LOAD - High: Failed" severity FAILURE;
      end if;


      -- Test 2: Low-half
      I_aluop <= OPCODE_LOAD & "1"; -- load opcode + low flag
      I_dataImm <= X"FFFF";
      wait_cycles(3);
      cmp := O_dataResult=X"00FF" and O_shouldBranch='0';
      if (cmp) then report "Test LOAD - Low: Passed" severity NOTE;
        else report "Test LOAD - Low: Failed" severity FAILURE;
      end if;


      -- CMP OPERATION
      -- =============
      -- EQ
      -- ==
      -- Test 1: Equality - equal
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unused flag
      I_dataA <= X"FFFF";
      I_dataB <= X"FFFF";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_EQ)='1'          and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test CMP - EQ - equal: Passed" severity NOTE;
        else report "Test CMP - EQ - equal: Failed" severity FAILURE;
      end if;

      -- Test 2: Equality - not equal
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unused flag
      I_dataA <= X"FFF0";
      I_dataB <= X"FFF1";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_EQ)='0'          and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test CMP - EQ - not equal: Passed" severity NOTE;
        else report "Test CMP - EQ - not equal: Failed" severity FAILURE;
      end if;

      -- AZ
      -- ==
      -- Test 1: Compare A and B to 0 - equal
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unused flag
      I_dataA <= X"0000";
      I_dataB <= X"0000";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AZ)='1'          and
             O_dataResult(CMP_BIT_BZ)='1'          and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test AZ BZ - equal: Passed" severity NOTE;
        else report "Test AZ BZ - equal: Failed" severity FAILURE;
      end if;

      -- Test 2: Compare A and B to 0 - not equal
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unused flag
      I_dataA <= X"0001";
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AZ)='0'          and
             O_dataResult(CMP_BIT_BZ)='0'          and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test AZ BZ - not equal: Passed" severity NOTE;
        else report "Test AZ BZ - not equal: Failed" severity FAILURE;
      end if;

      -- AGB
      -- ===
      -- Test 1: A > B (and not A < B) - unsigned
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unsigned
      I_dataA <= X"0001";
      I_dataB <= X"0000";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AGB)='1'         and
             O_dataResult(CMP_BIT_ALB)='0'         and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test A>B (and B<A) - unsigned: Passed" severity NOTE;
        else report "Test A>B (and B<A) - unsigned: Failed" severity FAILURE;
      end if;

      -- Test 2: A < B (and not A > B) - unsigned
      I_aluop <= OPCODE_CMP & "0"; -- compare opcode + unsigned
      I_dataA <= X"0000";
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AGB)='0'         and
             O_dataResult(CMP_BIT_ALB)='1'         and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test A<B (and B>A) - unsigned: Passed" severity NOTE;
        else report "Test A<B (and B>A) - unsigned: Failed" severity FAILURE;
      end if;

      -- Test 3: A > B (and not A < B) - signed
      I_aluop <= OPCODE_CMP & "1"; -- compare opcode + signed
      I_dataA <= X"FFFE"; -- -2
      I_dataB <= X"FFFD"; -- -3
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AGB)='1'         and
             O_dataResult(CMP_BIT_ALB)='0'         and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test A>B (and B<A) - signed: Passed" severity NOTE;
        else report "Test A>B (and B<A) - signed: Failed" severity FAILURE;
      end if;

      -- Test 4: A < B (and not A > B) - signed
      I_aluop <= OPCODE_CMP & "1"; -- compare opcode + signed
      I_dataA <= X"FFFE"; -- -2
      I_dataB <= X"0001"; -- 1
      wait_cycles(3);
      cmp := O_dataResult(CMP_BIT_AGB)='0'         and
             O_dataResult(CMP_BIT_ALB)='1'         and
             O_dataResult(15)='0'                  and
             O_dataResult(9 downto 0)="0000000000" and
             O_shouldBranch='0';
      if (cmp) then report "Test A<B (and B>A) - signed: Passed" severity NOTE;
        else report "Test A<B (and B>A) - signed: Failed" severity FAILURE;
      end if;

      -- SHL OPERATION
      -- =============
      -- Test: Shift Left
      I_aluop <= OPCODE_SHL & "0"; -- shift left opcode + unused flag
      for i in 0 to 15 loop
          I_dataA <= X"0001";
          I_dataB <= X"000" & std_logic_vector(to_unsigned(i,4)); -- Last 4 bits correspond to the number of bits to shift
          wait_cycles(3);
          cmp := O_dataResult = std_logic_vector(shift_left(unsigned(I_dataA), i)) and
                 O_shouldBranch='0';
          if (cmp) then report "Test SHL " & integer'image(i) & ": Passed" severity NOTE;
        else report "Test SHL -" & integer'image(i) & ": Failed" severity FAILURE;
          end if;
      end loop;

      -- JUMPEQ OPERATION
      -- ================
      -- Test 1: Branch target always set
      I_aluop <= OPCODE_JUMPEQ & "0"; -- jumpeq opcode + register or immediate
      I_dataB <= X"0001";
      wait_cycles(3);
      if (O_dataResult=X"0001") then report "Test JUMP - destination set: Passed" severity NOTE;
        else report "Test JUMP - destination set: Failed" severity FAILURE;
      end if;

      -- Test 2: Equality (CJF_EQ)
      I_aluop <= OPCODE_JUMPEQ & "0"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "00";
      -- CJF_EQ = 000
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_EQ) <= '1';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_EQ: Passed" severity NOTE;
        else report "Test JUMP - CJF_EQ: Failed" severity FAILURE;
      end if;

      -- Test 3: A=0 (CJF_AZ)
      I_aluop <= OPCODE_JUMPEQ & "0"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "01";
      -- CJF_AZ = 001
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_AZ) <= '1';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_AZ: Passed" severity NOTE;
        else report "Test JUMP - CJF_AZ: Failed" severity FAILURE;
      end if;

      -- Test 4: B=0 (CJF_BZ)
      I_aluop <= OPCODE_JUMPEQ & "0"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "10";
      -- CJF_AZ = 001
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_BZ) <= '1';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_AZ: Passed" severity NOTE;
        else report "Test JUMP - CJF_AZ: Failed" severity FAILURE;
      end if;

      -- Test 5: A!=0 (CJF_ANZ)
      I_aluop <= OPCODE_JUMPEQ & "0"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "11";
      -- CJF_ANZ = 011
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_AZ) <= '0';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_ANZ: Passed" severity NOTE;
        else report "Test JUMP - CJF_ANZ: Failed" severity FAILURE;
      end if;

      -- Test 6: B!=0 (CJF_BNZ)
      I_aluop <= OPCODE_JUMPEQ & "1"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "00";
      -- CJF_BNZ = 100
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_BZ) <= '0';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_BNZ: Passed" severity NOTE;
        else report "Test JUMP - CJF_BNZ: Failed" severity FAILURE;
      end if;

      -- Test 7: A>B (CJF_AGB)
      I_aluop <= OPCODE_JUMPEQ & "1"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "01";
      -- CJF_AGB = 101
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_AGB) <= '1';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_AGB: Passed" severity NOTE;
        else report "Test JUMP - CJF_AGB: Failed" severity FAILURE;
      end if;

      -- Test 8: A<B (CJF_ALB)
      I_aluop <= OPCODE_JUMPEQ & "1"; -- jumpeq opcode + first part of the CJF
      I_dataImm(1 downto 0) <= "10";
      -- CJF_ALB = 110
      I_dataA <= X"0000";
      I_dataA(CMP_BIT_ALB) <= '1';
      I_dataB <= X"0001";
      wait_cycles(3);
      cmp := O_dataResult=X"0001" and
             O_shouldBranch='1';
      if (cmp) then report "Test JUMP - CJF_ALB: Passed" severity NOTE;
        else report "Test JUMP - CJF_ALB: Failed" severity FAILURE;
      end if;

      running <= false;
      report "ALU: Testbench complete";
    end process;

end arch_alu_tb;
