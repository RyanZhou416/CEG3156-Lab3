library ieee;
use ieee.std_logic_1164.all;

entity mux_4to1_8bit is
    port (
        data_in_0    : in  std_logic_vector(7 downto 0);
        data_in_1    : in  std_logic_vector(7 downto 0);
        data_in_2    : in  std_logic_vector(7 downto 0);
        data_in_3    : in  std_logic_vector(7 downto 0);
        sel_line     : in  std_logic_vector(1 downto 0);
        data_out     : out std_logic_vector(7 downto 0)
    );
end entity mux_4to1_8bit;

architecture structural of mux_4to1_8bit is
    component mux_2to1_8bit is
        port (
            data_in_0    : in  std_logic_vector(7 downto 0);
            data_in_1    : in  std_logic_vector(7 downto 0);
            sel_line     : in  std_logic;
            data_out     : out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal mux_stage1_out_0 : std_logic_vector(7 downto 0);
    signal mux_stage1_out_1 : std_logic_vector(7 downto 0);
    
begin
    mux_stage1_0: mux_2to1_8bit
        port map (
            data_in_0 => data_in_0,
            data_in_1 => data_in_1,
            sel_line  => sel_line(0),
            data_out  => mux_stage1_out_0
        );
    
    mux_stage1_1: mux_2to1_8bit
        port map (
            data_in_0 => data_in_2,
            data_in_1 => data_in_3,
            sel_line  => sel_line(0),
            data_out  => mux_stage1_out_1
        );
    
    mux_stage2: mux_2to1_8bit
        port map (
            data_in_0 => mux_stage1_out_0,
            data_in_1 => mux_stage1_out_1,
            sel_line  => sel_line(1),
            data_out  => data_out
        );
    
end architecture structural;
