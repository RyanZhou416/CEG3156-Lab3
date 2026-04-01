library ieee;
use ieee.std_logic_1164.all;

entity instruction_decoder is
    port (
        i_instruction : in  std_logic_vector(31 downto 0);
        o_opcode      : out std_logic_vector(5 downto 0);
        o_rs          : out std_logic_vector(2 downto 0);
        o_rt          : out std_logic_vector(2 downto 0);
        o_rd          : out std_logic_vector(2 downto 0);
        o_funct       : out std_logic_vector(5 downto 0);
        o_imm16       : out std_logic_vector(15 downto 0);
        o_jump_addr   : out std_logic_vector(7 downto 0)
    );
end entity instruction_decoder;

architecture dataflow of instruction_decoder is
begin
    o_opcode    <= i_instruction(31 downto 26);
    o_rs        <= i_instruction(23 downto 21);
    o_rt        <= i_instruction(18 downto 16);
    o_rd        <= i_instruction(13 downto 11);
    o_funct     <= i_instruction(5 downto 0);
    o_imm16     <= i_instruction(15 downto 0);
    o_jump_addr <= i_instruction(7 downto 0);
end architecture dataflow;
