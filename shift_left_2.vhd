library ieee;
use ieee.std_logic_1164.all;

entity shift_left_2 is
    port (
        i_input  : in  std_logic_vector(7 downto 0);
        o_output : out std_logic_vector(7 downto 0)
    );
end entity shift_left_2;

architecture dataflow of shift_left_2 is
begin
    o_output <= i_input(5 downto 0) & "00";
end architecture dataflow;
