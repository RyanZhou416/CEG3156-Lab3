library ieee;
use ieee.std_logic_1164.all;

entity mux_2to1_1bit is
    port (
        data_in_0    : in  std_logic;
        data_in_1    : in  std_logic;
        sel_line     : in  std_logic;
        data_out     : out std_logic
    );
end entity mux_2to1_1bit;

architecture gate_logic of mux_2to1_1bit is
begin
    data_out <= (data_in_1 and sel_line) or (data_in_0 and (not sel_line));
    
end architecture gate_logic;
