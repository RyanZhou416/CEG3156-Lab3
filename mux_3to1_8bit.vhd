library ieee;
use ieee.std_logic_1164.all;

entity mux_3to1_8bit is
    port (
        data_in_0  : in  std_logic_vector(7 downto 0);  -- sel "00": register file
        data_in_1  : in  std_logic_vector(7 downto 0);  -- sel "10": EX/MEM forward
        data_in_2  : in  std_logic_vector(7 downto 0);  -- sel "01": MEM/WB forward
        sel        : in  std_logic_vector(1 downto 0);
        data_out   : out std_logic_vector(7 downto 0)
    );
end entity mux_3to1_8bit;

-- Built from two 2-to-1 MUXes:
--   Level 1: sel(0) selects between data_in_0 and data_in_2
--   Level 2: sel(1) selects between level1_out and data_in_1
-- Priority: sel(1) has higher priority (EX/MEM over MEM/WB)

architecture structural of mux_3to1_8bit is

    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal level1_out : std_logic_vector(7 downto 0);

begin

    mux_level1 : mux_2to1_8bit
        port map (
            data_in_0 => data_in_0,
            data_in_1 => data_in_2,
            sel_line  => sel(0),
            data_out  => level1_out
        );

    mux_level2 : mux_2to1_8bit
        port map (
            data_in_0 => level1_out,
            data_in_1 => data_in_1,
            sel_line  => sel(1),
            data_out  => data_out
        );

end architecture structural;
