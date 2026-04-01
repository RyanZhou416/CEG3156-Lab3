library ieee;
use ieee.std_logic_1164.all;

entity fetch_unit is
    port (
        GClock         : in  std_logic;
        GReset         : in  std_logic;
        i_branch       : in  std_logic;
        i_zero         : in  std_logic;
        i_jump         : in  std_logic;
        i_imm16        : in  std_logic_vector(15 downto 0);
        i_jump_addr    : in  std_logic_vector(7 downto 0);
        o_pc           : out std_logic_vector(7 downto 0);
        o_sign_ext_imm : out std_logic_vector(7 downto 0)
    );
end entity fetch_unit;

architecture structural of fetch_unit is

    component reg_8bit is
        port (
            data_in     : in  std_logic_vector(7 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    component full_adder_8bit is
        port (
            term_a    : in  std_logic_vector(7 downto 0);
            term_b    : in  std_logic_vector(7 downto 0);
            carry_in  : in  std_logic;
            sum_out   : out std_logic_vector(7 downto 0);
            carry_out : out std_logic
        );
    end component;

    component sign_extend is
        port (
            i_imm16 : in  std_logic_vector(15 downto 0);
            o_imm8  : out std_logic_vector(7 downto 0)
        );
    end component;

    component shift_left_2 is
        port (
            i_input  : in  std_logic_vector(7 downto 0);
            o_output : out std_logic_vector(7 downto 0)
        );
    end component;

    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal pc_out        : std_logic_vector(7 downto 0);
    signal pc_plus_4     : std_logic_vector(7 downto 0);
    signal imm8          : std_logic_vector(7 downto 0);
    signal branch_offset : std_logic_vector(7 downto 0);
    signal branch_target : std_logic_vector(7 downto 0);
    signal jump_target   : std_logic_vector(7 downto 0);
    signal branch_mux_out: std_logic_vector(7 downto 0);
    signal pc_next       : std_logic_vector(7 downto 0);
    signal pc_src        : std_logic;

begin

    pc_reg: reg_8bit
        port map (
            data_in     => pc_next,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => pc_out
        );

    o_pc <= pc_out;

    adder_pc_plus_4: full_adder_8bit
        port map (
            term_a    => pc_out,
            term_b    => "00000100",
            carry_in  => '0',
            sum_out   => pc_plus_4,
            carry_out => open
        );

    sign_ext: sign_extend
        port map (
            i_imm16 => i_imm16,
            o_imm8  => imm8
        );

    o_sign_ext_imm <= imm8;

    sll_branch: shift_left_2
        port map (
            i_input  => imm8,
            o_output => branch_offset
        );

    adder_branch: full_adder_8bit
        port map (
            term_a    => pc_plus_4,
            term_b    => branch_offset,
            carry_in  => '0',
            sum_out   => branch_target,
            carry_out => open
        );

    pc_src <= i_branch and i_zero;

    branch_mux: mux_2to1_8bit
        port map (
            data_in_0 => pc_plus_4,
            data_in_1 => branch_target,
            sel_line  => pc_src,
            data_out  => branch_mux_out
        );

    sll_jump: shift_left_2
        port map (
            i_input  => i_jump_addr,
            o_output => jump_target
        );

    jump_mux: mux_2to1_8bit
        port map (
            data_in_0 => branch_mux_out,
            data_in_1 => jump_target,
            sel_line  => i_jump,
            data_out  => pc_next
        );

end architecture structural;
