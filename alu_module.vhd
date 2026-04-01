library ieee;
use ieee.std_logic_1164.all;

entity alu_module is
    port (
        i_alu_op   : in  std_logic_vector(1 downto 0);
        i_funct    : in  std_logic_vector(5 downto 0);
        i_a        : in  std_logic_vector(7 downto 0);
        i_b        : in  std_logic_vector(7 downto 0);
        o_result   : out std_logic_vector(7 downto 0);
        o_zero     : out std_logic;
        o_overflow : out std_logic
    );
end entity alu_module;

architecture structural of alu_module is

    component alu_control is
        port (
            i_alu_op   : in  std_logic_vector(1 downto 0);
            i_funct    : in  std_logic_vector(5 downto 0);
            o_alu_ctrl : out std_logic_vector(3 downto 0)
        );
    end component;

    component alu_8bit is
        port (
            i_a        : in  std_logic_vector(7 downto 0);
            i_b        : in  std_logic_vector(7 downto 0);
            i_control  : in  std_logic_vector(3 downto 0);
            o_result   : out std_logic_vector(7 downto 0);
            o_zero     : out std_logic;
            o_overflow : out std_logic
        );
    end component;

    signal alu_ctrl_int : std_logic_vector(3 downto 0);

begin

    alu_ctrl: alu_control
        port map (
            i_alu_op   => i_alu_op,
            i_funct    => i_funct,
            o_alu_ctrl => alu_ctrl_int
        );

    alu: alu_8bit
        port map (
            i_a        => i_a,
            i_b        => i_b,
            i_control  => alu_ctrl_int,
            o_result   => o_result,
            o_zero     => o_zero,
            o_overflow => o_overflow
        );

end architecture structural;
