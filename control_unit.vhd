library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        i_opcode     : in  std_logic_vector(5 downto 0);
        o_reg_dst    : out std_logic;
        o_alu_src    : out std_logic;
        o_mem_to_reg : out std_logic;
        o_reg_write  : out std_logic;
        o_mem_read   : out std_logic;
        o_mem_write  : out std_logic;
        o_branch     : out std_logic;
        o_jump       : out std_logic;
        o_alu_op     : out std_logic_vector(1 downto 0)
    );
end entity control_unit;

architecture gate_logic of control_unit is
    signal r_type : std_logic;
    signal i_lw   : std_logic;
    signal i_sw   : std_logic;
    signal i_beq  : std_logic;
    signal i_j    : std_logic;
begin

    r_type <= not i_opcode(5) and not i_opcode(4) and not i_opcode(3)
              and not i_opcode(2) and not i_opcode(1) and not i_opcode(0);

    i_lw   <= i_opcode(5) and not i_opcode(4) and not i_opcode(3)
              and not i_opcode(2) and i_opcode(1) and i_opcode(0);

    i_sw   <= i_opcode(5) and not i_opcode(4) and i_opcode(3)
              and not i_opcode(2) and i_opcode(1) and i_opcode(0);

    i_beq  <= not i_opcode(5) and not i_opcode(4) and not i_opcode(3)
              and i_opcode(2) and not i_opcode(1) and not i_opcode(0);

    i_j    <= not i_opcode(5) and not i_opcode(4) and not i_opcode(3)
              and not i_opcode(2) and i_opcode(1) and not i_opcode(0);

    o_reg_dst    <= r_type;
    o_alu_src    <= i_lw or i_sw;
    o_mem_to_reg <= i_lw;
    o_reg_write  <= r_type or i_lw;
    o_mem_read   <= i_lw;
    o_mem_write  <= i_sw;
    o_branch     <= i_beq;
    o_jump       <= i_j;
    o_alu_op(1)  <= r_type;
    o_alu_op(0)  <= i_beq;

end architecture gate_logic;
