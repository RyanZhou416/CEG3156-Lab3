library ieee;
use ieee.std_logic_1164.all;

entity sign_extend is
    port (
        i_imm16 : in  std_logic_vector(15 downto 0);
        o_imm8  : out std_logic_vector(7 downto 0)
    );
end entity sign_extend;

architecture dataflow of sign_extend is
begin
    o_imm8 <= i_imm16(7 downto 0);
end architecture dataflow;
