library ieee;
use ieee.std_logic_1164.all;

entity output_mux is
    port (
        i_value_select : in  std_logic_vector(2 downto 0);
        i_pc           : in  std_logic_vector(7 downto 0);
        i_alu_result   : in  std_logic_vector(7 downto 0);
        i_read_data1   : in  std_logic_vector(7 downto 0);
        i_read_data2   : in  std_logic_vector(7 downto 0);
        i_write_data   : in  std_logic_vector(7 downto 0);
        i_reg_dst      : in  std_logic;
        i_jump         : in  std_logic;
        i_mem_read     : in  std_logic;
        i_mem_to_reg   : in  std_logic;
        i_alu_op       : in  std_logic_vector(1 downto 0);
        i_alu_src      : in  std_logic;
        o_mux_out      : out std_logic_vector(7 downto 0)
    );
end entity output_mux;

architecture structural of output_mux is

    component mux_8to1_8bit is
        port (
            sel_line  : in  std_logic_vector(2 downto 0);
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            data_in_2 : in  std_logic_vector(7 downto 0);
            data_in_3 : in  std_logic_vector(7 downto 0);
            data_in_4 : in  std_logic_vector(7 downto 0);
            data_in_5 : in  std_logic_vector(7 downto 0);
            data_in_6 : in  std_logic_vector(7 downto 0);
            data_in_7 : in  std_logic_vector(7 downto 0);
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal ctrl_byte : std_logic_vector(7 downto 0);

begin

    ctrl_byte(7) <= '0';
    ctrl_byte(6) <= i_reg_dst;
    ctrl_byte(5) <= i_jump;
    ctrl_byte(4) <= i_mem_read;
    ctrl_byte(3) <= i_mem_to_reg;
    ctrl_byte(2) <= i_alu_op(1);
    ctrl_byte(1) <= i_alu_op(0);
    ctrl_byte(0) <= i_alu_src;

    mux_inst: mux_8to1_8bit
        port map (
            sel_line  => i_value_select,
            data_in_0 => i_pc,
            data_in_1 => i_alu_result,
            data_in_2 => i_read_data1,
            data_in_3 => i_read_data2,
            data_in_4 => i_write_data,
            data_in_5 => ctrl_byte,
            data_in_6 => ctrl_byte,
            data_in_7 => ctrl_byte,
            data_out  => o_mux_out
        );

end architecture structural;
