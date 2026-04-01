library ieee;
use ieee.std_logic_1164.all;

entity mux_8to1_32bit is
    port (
        sel_line  : in  std_logic_vector(2 downto 0);
        data_in_0 : in  std_logic_vector(31 downto 0);
        data_in_1 : in  std_logic_vector(31 downto 0);
        data_in_2 : in  std_logic_vector(31 downto 0);
        data_in_3 : in  std_logic_vector(31 downto 0);
        data_in_4 : in  std_logic_vector(31 downto 0);
        data_in_5 : in  std_logic_vector(31 downto 0);
        data_in_6 : in  std_logic_vector(31 downto 0);
        data_in_7 : in  std_logic_vector(31 downto 0);
        data_out  : out std_logic_vector(31 downto 0)
    );
end entity mux_8to1_32bit;

architecture structural of mux_8to1_32bit is
    component mux_2to1_32bit is
        port (
            data_in_0 : in  std_logic_vector(31 downto 0);
            data_in_1 : in  std_logic_vector(31 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal l1_out_0, l1_out_1, l1_out_2, l1_out_3 : std_logic_vector(31 downto 0);
    signal l2_out_0, l2_out_1                      : std_logic_vector(31 downto 0);

begin

    l1_mux0: mux_2to1_32bit port map (data_in_0 => data_in_0, data_in_1 => data_in_1, sel_line => sel_line(0), data_out => l1_out_0);
    l1_mux1: mux_2to1_32bit port map (data_in_0 => data_in_2, data_in_1 => data_in_3, sel_line => sel_line(0), data_out => l1_out_1);
    l1_mux2: mux_2to1_32bit port map (data_in_0 => data_in_4, data_in_1 => data_in_5, sel_line => sel_line(0), data_out => l1_out_2);
    l1_mux3: mux_2to1_32bit port map (data_in_0 => data_in_6, data_in_1 => data_in_7, sel_line => sel_line(0), data_out => l1_out_3);

    l2_mux0: mux_2to1_32bit port map (data_in_0 => l1_out_0, data_in_1 => l1_out_1, sel_line => sel_line(1), data_out => l2_out_0);
    l2_mux1: mux_2to1_32bit port map (data_in_0 => l1_out_2, data_in_1 => l1_out_3, sel_line => sel_line(1), data_out => l2_out_1);

    l3_mux0: mux_2to1_32bit port map (data_in_0 => l2_out_0, data_in_1 => l2_out_1, sel_line => sel_line(2), data_out => data_out);

end architecture structural;
