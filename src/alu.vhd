-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Arithmetic Logic Unit that performs the logic operations.
-- Here it means performing the actual operations behind the OPCODES.


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

entity alu is
    generic(REG_WIDTH : natural := 16;
            OP_SIZE   : natural := 4);
    port (I_clk        : in STD_LOGIC; -- Clock signal
          I_en         : in STD_LOGIC; -- Enable
          I_reset      : in STD_LOGIC; -- Reset

          I_dataA      : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- 16-bit Input data
          I_dataB      : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- 16-bit Input data
          I_dataDwe    : in STD_LOGIC;                                -- Write Enable
          I_aluop      : in STD_LOGIC_VECTOR (OP_SIZE downto 0);      -- ALU Operation Code
          I_PC         : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- Program Counter
          I_dataImm    : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- Immediate value passed
          O_dataResult : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- 16-bit result of the operation
          O_dataWriteReg : out STD_LOGIC; -- Pass over the write enable
          O_shouldBranch : out STD_LOGIC  -- Notify a need for branching
          );
end alu;

-- =================
--   Architecture
-- =================

architecture arch_alu of alu is
    -- Internal Objects
    -- Internal register for operation result (16 bits + 2 bits for carry/overflow)
    signal s_result : STD_LOGIC_VECTOR(REG_WIDTH+1 downto 0) := (others => '0');
    -- Internal bit to signal the need for branching
    signal s_shouldBranch : STD_LOGIC := '0';
    -- Comparators to bring locally static choices
    signal cmp_op     : std_logic_vector(3 downto 0);
    signal cmp_shl    : std_logic_vector(3 downto 0);
    signal cmp_jumpeq : std_logic_vector(2 downto 0);
begin
    -- Processes
    PerformOperation: process(I_clk, I_en, I_reset) -- I_clk and I_en added to the sensitivity list of the process
    begin
        -- Reset routine
        if I_reset='0' then
          s_result <= (others => '0');
          s_shouldBranch <= '0';
        end if;

        -- Operations routine
        if rising_edge(I_clk) and I_en='1' then  -- If new cycle and enable
            O_dataWriteReg <= I_dataDwe;         -- Propagate write enable
            cmp_op <= I_aluop(4 downto 1);
            case cmp_op is
                -- ADD operation
                -- =============
                when OPCODE_ADD =>
                  if I_aluop(0) = '0' then -- Unsigned variation
                    s_result(REG_WIDTH downto 0) <= std_logic_vector(unsigned('0' & I_dataA) + unsigned('0' & I_dataB));
                  else                     -- Signed variation
                    s_result(REG_WIDTH downto 0) <= std_logic_vector(signed(I_dataA(15) & I_dataA) + signed(I_dataB(15) & I_dataB));
                  end if;
                  s_shouldBranch <= '0';   -- Operation does not need branching

                -- OR operation
                -- ============
                when OPCODE_OR =>
                  s_result(REG_WIDTH-1 downto 0) <= I_dataA or I_dataB;
                  s_shouldBranch <= '0';  -- Operation does not need branching

                -- XOR operation
                -- =============
                when OPCODE_XOR =>
        					s_result(REG_WIDTH-1 downto 0) <= I_dataA xor I_dataB;
        					s_shouldBranch <= '0';  -- Operation does not need branching

                -- AND operation
                -- =============
        				when OPCODE_AND =>
        					s_result(REG_WIDTH-1 downto 0) <= I_dataA and I_dataB;
        					s_shouldBranch <= '0';  -- Operation does not need branching

                -- NOT operation
                -- =============
        				when OPCODE_NOT =>
        					s_result(REG_WIDTH-1 downto 0) <= not I_dataA;
        					s_shouldBranch <= '0';  -- Operation does not need branching


                -- LOAD operation
                -- ==============
                when OPCODE_LOAD =>
                  if I_aluop(0) = '0' then -- High half variation of the register
                    s_result(REG_WIDTH-1 downto 0) <= I_dataImm(7 downto 0) & X"00";
                  else -- Low half variation of the register
                    s_result(REG_WIDTH-1 downto 0) <= X"00" & I_dataImm(7 downto 0);
                  end if;
                  s_shouldBranch <= '0';


                -- CMP operation
                -- =============
                when OPCODE_CMP =>
                  -- Compare A and B (EQUALITY)
                  if I_dataA = I_dataB then
                    s_result(CMP_BIT_EQ) <= '1';
                  else
                    s_result(CMP_BIT_EQ) <= '0';
                  end if;

                  -- Compare A to 0
                  if I_dataA = X"0000" then
                    s_result(CMP_BIT_AZ) <= '1';
                  else
                    s_result(CMP_BIT_AZ) <= '0';
                  end if;

                  -- Compare B to 0
                  if I_dataB = X"0000" then
                    s_result(CMP_BIT_AZ) <= '1';
                  else
                    s_result(CMP_BIT_AZ) <= '0';
                  end if;

                  -- Compare A and B (GREATER THAN)
                  if I_aluop(0) = '0' then -- Unsigned version
                    -- Unsigned A > B ?
                    if unsigned(I_dataA) > unsigned(I_dataB) then
                      s_result(CMP_BIT_AGB) <= '1';
                    else
                      s_result(CMP_BIT_AGB) <= '0';
                    end if;
                    -- Unsigned A < B ?
                    if unsigned(I_dataA) < unsigned(I_dataB) then
                      s_result(CMP_BIT_ALB) <= '1';
                    else
                      s_result(CMP_BIT_ALB) <= '0';
                    end if;
                  else -- Signed version
                    -- Signed A > B ?
                    if signed(I_dataA) > signed(I_dataB) then
                      s_result(CMP_BIT_AGB) <= '1';
                    else
                      s_result(CMP_BIT_AGB) <= '0';
                    end if;
                    -- Signed A <  B ?
                    if signed(I_dataA) < signed(I_dataB) then
                      s_result(CMP_BIT_AGB) <= '1';
                    else
                      s_result(CMP_BIT_AGB) <= '0';
                    end if;
                  end if;
                  -- Zero unused bits and shouldBranch
                  s_result(15) <= '0';
                  s_result(9 downto 0) <= "0000000000";
                  s_shouldBranch <= '0';

                  -- SHL operation
                  -- =============
                  when OPCODE_SHL =>
                      cmp_shl <= I_dataB(3 downto 0);
                      case cmp_shl is
                        when "0001" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 1));
                        when "0010" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 2));
                        when "0011" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 3));
                        when "0100" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 4));
                        when "0101" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 5));
                        when "0110" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 6));
                        when "0111" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 7));
                        when "1000" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 8));
                        when "1001" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 9));
                        when "1010" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 10));
                        when "1011" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 11));
                        when "1100" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 12));
                        when "1101" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 13));
                        when "1110" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 14));
                        when "1111" =>
                          s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA), 15));
                        when others =>
                          s_result(REG_WIDTH-1 downto 0) <= I_dataA;
                      end case;
                      s_shouldBranch <= '0';

                -- JUMPEQ operation
                -- ================
                when OPCODE_JUMPEQ =>
                  -- Set the branch target regardless of the results
                  s_result(REG_WIDTH-1 downto 0) <= I_dataB;

                  -- The condition to jump is based on the flag and immediate value
                  cmp_jumpeq <= (I_aluop(0) & I_dataImm(1 downto 0));
                  case cmp_jumpeq is
                    when CJF_EQ => -- Equality
                      s_shouldBranch <= I_dataA(CMP_BIT_EQ);
                    when CJF_AZ => -- A = 0
                      s_shouldBranch <= I_dataA(CMP_BIT_AZ);
                    when CJF_BZ => -- A = 0
                      s_shouldBranch <= I_dataA(CMP_BIT_BZ);
                    when CJF_ANZ => -- A != 0
                      s_shouldBranch <= not I_dataA(CMP_BIT_AZ);
                    when CJF_BNZ => -- B != 0
                      s_shouldBranch <= not I_dataA(CMP_BIT_BZ);
                    when CJF_AGB => -- A > B
                      s_shouldBranch <= I_dataA(CMP_BIT_AGB);
                    when CJF_ALB => -- B < 0
                      s_shouldBranch <= I_dataA(CMP_BIT_ALB);
                    when others =>
                      s_shouldBranch <= '0';
                  end case;
                -- ...Other codes...
                when others =>
                  s_result <= "00" & X"FEFE"; -- Default Result Code
            end case;
        end if;
    end process;

    -- Propagate to outputs
    O_dataResult <= s_result(REG_WIDTH-1 downto 0);
    O_shouldBranch <= s_shouldBranch;

end arch_alu;
