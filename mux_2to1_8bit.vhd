library ieee;
use ieee.std_logic_1164.all;

entity mux_2to1_8bit is
    port (
        data_in_0    : in  std_logic_vector(7 downto 0);
        data_in_1    : in  std_logic_vector(7 downto 0);
        sel_line     : in  std_logic;
        data_out     : out std_logic_vector(7 downto 0)
    );
end entity mux_2to1_8bit;

architecture structural of mux_2to1_8bit is
    component mux_2to1_1bit is
        port (
            data_in_0    : in  std_logic;
            data_in_1    : in  std_logic;
            sel_line     : in  std_logic;
            data_out     : out std_logic
        );
    end component;
    
begin
    gen_mux: for i in 7 downto 0 generate
        mux_bit: mux_2to1_1bit
            port map (
                data_in_0 => data_in_0(i),
                data_in_1 => data_in_1(i),
                sel_line  => sel_line,
                data_out  => data_out(i)
            );
    end generate gen_mux;
    
end architecture structural;
