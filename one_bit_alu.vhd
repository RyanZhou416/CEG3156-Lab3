library ieee;
use ieee.std_logic_1164.all;

entity one_bit_alu is
    port (
        i_a        : in  std_logic;
        i_b        : in  std_logic;
        i_less     : in  std_logic;
        i_a_invert : in  std_logic;
        i_b_invert : in  std_logic;
        i_op       : in  std_logic_vector(1 downto 0);
        i_cin      : in  std_logic;
        o_result   : out std_logic;
        o_cout     : out std_logic;
        o_set      : out std_logic
    );
end entity one_bit_alu;

architecture structural of one_bit_alu is

    component full_adder_1bit is
        port (
            A, B, Cin : in  std_logic;
            Cout, S   : out std_logic
        );
    end component;

    component mux_2to1_1bit is
        port (
            data_in_0 : in  std_logic;
            data_in_1 : in  std_logic;
            sel_line  : in  std_logic;
            data_out  : out std_logic
        );
    end component;

    signal a_val       : std_logic;
    signal b_val       : std_logic;
    signal and_result  : std_logic;
    signal or_result   : std_logic;
    signal add_result  : std_logic;
    signal mux_lo_out  : std_logic;
    signal mux_hi_out  : std_logic;

begin

    a_val <= i_a xor i_a_invert;
    b_val <= i_b xor i_b_invert;

    and_result <= a_val and b_val;
    or_result  <= a_val or b_val;

    adder: full_adder_1bit
        port map (
            A    => a_val,
            B    => b_val,
            Cin  => i_cin,
            Cout => o_cout,
            S    => add_result
        );

    o_set <= add_result;

    mux_lo: mux_2to1_1bit
        port map (
            data_in_0 => and_result,
            data_in_1 => or_result,
            sel_line  => i_op(0),
            data_out  => mux_lo_out
        );

    mux_hi: mux_2to1_1bit
        port map (
            data_in_0 => add_result,
            data_in_1 => i_less,
            sel_line  => i_op(0),
            data_out  => mux_hi_out
        );

    mux_out: mux_2to1_1bit
        port map (
            data_in_0 => mux_lo_out,
            data_in_1 => mux_hi_out,
            sel_line  => i_op(1),
            data_out  => o_result
        );

end architecture structural;
