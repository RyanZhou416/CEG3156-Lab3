library ieee;
use ieee.std_logic_1164.all;

entity alu_control is
    port (
        i_alu_op   : in  std_logic_vector(1 downto 0);
        i_funct    : in  std_logic_vector(5 downto 0);
        o_alu_ctrl : out std_logic_vector(3 downto 0)
    );
end entity alu_control;

architecture gate_logic of alu_control is
begin
    o_alu_ctrl(3) <= '0';
    o_alu_ctrl(2) <= i_alu_op(0) or (i_alu_op(1) and i_funct(1));
    o_alu_ctrl(1) <= not (i_alu_op(1) and i_funct(2));
    o_alu_ctrl(0) <= i_alu_op(1) and (i_funct(0) or i_funct(3));
end architecture gate_logic;
