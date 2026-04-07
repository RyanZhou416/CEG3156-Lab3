library ieee;
use ieee.std_logic_1164.all;

-- Pipelined fetch unit.
-- Key differences from the single-cycle version:
--   i_pc_write     : '0' freezes the PC during a load-use stall
--   i_pc_src       : comes from EX/MEM stage (Branch AND Zero), not computed here
--   i_branch_target: 8-bit target already computed in EX stage, stored in EX/MEM
-- The sign_extend + shift + branch-adder chain is removed from this unit;
-- that work is now done in the EX stage datapath.

entity fetch_unit is
    port (
        GClock          : in  std_logic;
        GReset          : in  std_logic;
        -- Stall control from Hazard Detection Unit
        i_pc_write      : in  std_logic;
        -- Branch control from EX/MEM pipeline register
        i_pc_src        : in  std_logic;                      -- EX/MEM.Branch AND EX/MEM.Zero
        i_branch_target : in  std_logic_vector(7 downto 0);  -- precomputed branch target
        -- Jump control from ID stage
        i_jump          : in  std_logic;
        i_jump_addr     : in  std_logic_vector(7 downto 0);  -- jump target (from instruction)
        -- Outputs
        o_pc            : out std_logic_vector(7 downto 0);
        o_pc_plus_4     : out std_logic_vector(7 downto 0)
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

    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    component shift_left_2 is
        port (
            i_input  : in  std_logic_vector(7 downto 0);
            o_output : out std_logic_vector(7 downto 0)
        );
    end component;

    signal pc_out         : std_logic_vector(7 downto 0);
    signal pc_plus_4      : std_logic_vector(7 downto 0);
    signal branch_mux_out : std_logic_vector(7 downto 0);
    signal jump_target    : std_logic_vector(7 downto 0);
    signal pc_next        : std_logic_vector(7 downto 0);

begin

    -- PC register: load_enable controlled by hazard detection unit
    pc_reg : reg_8bit
        port map (
            data_in     => pc_next,
            load_enable => i_pc_write,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => pc_out
        );

    o_pc <= pc_out;

    -- PC + 4
    adder_pc : full_adder_8bit
        port map (
            term_a    => pc_out,
            term_b    => "00000100",
            carry_in  => '0',
            sum_out   => pc_plus_4,
            carry_out => open
        );

    o_pc_plus_4 <= pc_plus_4;

    -- Branch MUX: select sequential or branch target
    -- i_branch_target comes pre-computed from EX/MEM pipeline register
    branch_mux : mux_2to1_8bit
        port map (
            data_in_0 => pc_plus_4,
            data_in_1 => i_branch_target,
            sel_line  => i_pc_src,
            data_out  => branch_mux_out
        );

    -- Jump target: shift jump address field left 2
    sll_jump : shift_left_2
        port map (
            i_input  => i_jump_addr,
            o_output => jump_target
        );

    -- Jump MUX: select branch/sequential or jump target
    jump_mux : mux_2to1_8bit
        port map (
            data_in_0 => branch_mux_out,
            data_in_1 => jump_target,
            sel_line  => i_jump,
            data_out  => pc_next
        );

end architecture structural;