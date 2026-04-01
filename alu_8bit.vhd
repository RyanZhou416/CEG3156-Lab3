library ieee;
use ieee.std_logic_1164.all;

entity alu_8bit is
    port (
        i_a        : in  std_logic_vector(7 downto 0);
        i_b        : in  std_logic_vector(7 downto 0);
        i_control  : in  std_logic_vector(3 downto 0);
        o_result   : out std_logic_vector(7 downto 0);
        o_zero     : out std_logic;
        o_overflow : out std_logic
    );
end entity alu_8bit;

architecture structural of alu_8bit is

    component one_bit_alu is
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
    end component;

    signal carry_chain  : std_logic_vector(8 downto 0);
    signal result_int   : std_logic_vector(7 downto 0);
    signal set_out      : std_logic_vector(7 downto 0);
    signal overflow_int : std_logic;
    signal slt_result   : std_logic;

begin

    carry_chain(0) <= i_control(2);

    overflow_int <= carry_chain(7) xor carry_chain(8);
    slt_result   <= set_out(7) xor overflow_int;
    o_overflow   <= overflow_int;

    alu_bit0: one_bit_alu
        port map (
            i_a        => i_a(0),
            i_b        => i_b(0),
            i_less     => slt_result,
            i_a_invert => i_control(3),
            i_b_invert => i_control(2),
            i_op       => i_control(1 downto 0),
            i_cin      => carry_chain(0),
            o_result   => result_int(0),
            o_cout     => carry_chain(1),
            o_set      => set_out(0)
        );

    gen_alu: for i in 1 to 7 generate
        alu_bit: one_bit_alu
            port map (
                i_a        => i_a(i),
                i_b        => i_b(i),
                i_less     => '0',
                i_a_invert => i_control(3),
                i_b_invert => i_control(2),
                i_op       => i_control(1 downto 0),
                i_cin      => carry_chain(i),
                o_result   => result_int(i),
                o_cout     => carry_chain(i + 1),
                o_set      => set_out(i)
            );
    end generate gen_alu;

    o_result <= result_int;
    o_zero   <= not (result_int(0) or result_int(1) or result_int(2) or result_int(3)
                  or result_int(4) or result_int(5) or result_int(6) or result_int(7));

end architecture structural;
