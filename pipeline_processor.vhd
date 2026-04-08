library ieee;
use ieee.std_logic_1164.all;

entity pipeline_processor is
    port (
        GClock         : in  std_logic;
        GReset         : in  std_logic;
        ValueSelect    : in  std_logic_vector(2 downto 0);
        InstrSelect    : in  std_logic_vector(2 downto 0);
        MuxOut         : out std_logic_vector(7 downto 0);
        InstructionOut : out std_logic_vector(31 downto 0);
        BranchOut      : out std_logic;
        ZeroOut        : out std_logic;
        MemWriteOut    : out std_logic;
        RegWriteOut    : out std_logic;

        -- Debug: PC & instructions per pipeline stage
        o_pc           : out std_logic_vector(7 downto 0);
        o_if_instr     : out std_logic_vector(31 downto 0);
        o_id_instr     : out std_logic_vector(31 downto 0);
        o_ex_instr     : out std_logic_vector(31 downto 0);
        o_mem_instr    : out std_logic_vector(31 downto 0);
        o_wb_instr     : out std_logic_vector(31 downto 0);

        -- Debug: data values
        o_reg_data_1   : out std_logic_vector(7 downto 0);
        o_reg_data_2   : out std_logic_vector(7 downto 0);
        o_alu_result   : out std_logic_vector(7 downto 0);
        o_wb_data      : out std_logic_vector(7 downto 0);
        o_write_reg    : out std_logic_vector(2 downto 0);

        -- Debug: hazard & forwarding
        o_stall        : out std_logic;
        o_forward_a    : out std_logic_vector(1 downto 0);
        o_forward_b    : out std_logic_vector(1 downto 0);

        -- Debug: flush & branch
        o_branch_taken : out std_logic;
        o_if_id_flush  : out std_logic;
        o_id_ex_flush  : out std_logic
    );
end entity pipeline_processor;

architecture structural of pipeline_processor is

    component rom32 is
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            q       : out std_logic_vector(31 downto 0)
        );
    end component;

    component ram32 is
        port (
            clock     : in  std_logic;
            data      : in  std_logic_vector(31 downto 0);
            rdaddress : in  std_logic_vector(7 downto 0);
            wraddress : in  std_logic_vector(7 downto 0);
            wren      : in  std_logic;
            q         : out std_logic_vector(31 downto 0)
        );
    end component;

    component instruction_decoder is
        port (
            i_instruction : in  std_logic_vector(31 downto 0);
            o_opcode      : out std_logic_vector(5 downto 0);
            o_rs          : out std_logic_vector(2 downto 0);
            o_rt          : out std_logic_vector(2 downto 0);
            o_rd          : out std_logic_vector(2 downto 0);
            o_funct       : out std_logic_vector(5 downto 0);
            o_imm16       : out std_logic_vector(15 downto 0);
            o_jump_addr   : out std_logic_vector(7 downto 0)
        );
    end component;

    component control_unit is
        port (
            i_opcode     : in  std_logic_vector(5 downto 0);
            o_reg_dst    : out std_logic;
            o_alu_src    : out std_logic;
            o_mem_to_reg : out std_logic;
            o_reg_write  : out std_logic;
            o_mem_read   : out std_logic;
            o_mem_write  : out std_logic;
            o_branch     : out std_logic;
            o_jump       : out std_logic;
            o_alu_op     : out std_logic_vector(1 downto 0)
        );
    end component;

    component register_file is
        port (
            GClock     : in  std_logic;
            GReset     : in  std_logic;
            reg_write  : in  std_logic;
            read_reg1  : in  std_logic_vector(2 downto 0);
            read_reg2  : in  std_logic_vector(2 downto 0);
            write_reg  : in  std_logic_vector(2 downto 0);
            write_data : in  std_logic_vector(7 downto 0);
            read_data1 : out std_logic_vector(7 downto 0);
            read_data2 : out std_logic_vector(7 downto 0)
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

    component alu_module is
        port (
            i_alu_op   : in  std_logic_vector(1 downto 0);
            i_funct    : in  std_logic_vector(5 downto 0);
            i_a        : in  std_logic_vector(7 downto 0);
            i_b        : in  std_logic_vector(7 downto 0);
            o_result   : out std_logic_vector(7 downto 0);
            o_zero     : out std_logic;
            o_overflow : out std_logic
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

    component reg_8bit is
        port (
            data_in     : in  std_logic_vector(7 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    component reg_32bit is
        port (
            data_in     : in  std_logic_vector(31 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(31 downto 0)
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

    component mux_2to1_3bit is
        port (
            data_in_0 : in  std_logic_vector(2 downto 0);
            data_in_1 : in  std_logic_vector(2 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(2 downto 0)
        );
    end component;

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

    component mux_8to1_32bit is
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
    end component;

    component pipeline_reg_EX_MEM is
        port (
            GClock          : in  std_logic;
            GReset          : in  std_logic;
            i_branch_target : in  std_logic_vector(7 downto 0);
            i_alu_result    : in  std_logic_vector(7 downto 0);
            i_read_data_2   : in  std_logic_vector(7 downto 0);
            i_zero          : in  std_logic;
            i_write_reg     : in  std_logic_vector(2 downto 0);
            i_branch        : in  std_logic;
            i_mem_read      : in  std_logic;
            i_mem_write     : in  std_logic;
            i_reg_write     : in  std_logic;
            i_mem_to_reg    : in  std_logic;
            o_branch_target : out std_logic_vector(7 downto 0);
            o_alu_result    : out std_logic_vector(7 downto 0);
            o_read_data_2   : out std_logic_vector(7 downto 0);
            o_zero          : out std_logic;
            o_write_reg     : out std_logic_vector(2 downto 0);
            o_branch        : out std_logic;
            o_mem_read      : out std_logic;
            o_mem_write     : out std_logic;
            o_reg_write     : out std_logic;
            o_mem_to_reg    : out std_logic
        );
    end component;

    component pipeline_reg_MEM_WB is
        port (
            GClock           : in  std_logic;
            GReset           : in  std_logic;
            i_mem_read_data  : in  std_logic_vector(7 downto 0);
            i_alu_result     : in  std_logic_vector(7 downto 0);
            i_write_reg      : in  std_logic_vector(2 downto 0);
            i_reg_write      : in  std_logic;
            i_mem_to_reg     : in  std_logic;
            o_mem_read_data  : out std_logic_vector(7 downto 0);
            o_alu_result     : out std_logic_vector(7 downto 0);
            o_write_reg      : out std_logic_vector(2 downto 0);
            o_reg_write      : out std_logic;
            o_mem_to_reg     : out std_logic
        );
    end component;

    component forwarding_unit is
        port (
            i_id_ex_rs         : in  std_logic_vector(2 downto 0);
            i_id_ex_rt         : in  std_logic_vector(2 downto 0);
            i_ex_mem_reg_write : in  std_logic;
            i_ex_mem_rd        : in  std_logic_vector(2 downto 0);
            i_mem_wb_reg_write : in  std_logic;
            i_mem_wb_rd        : in  std_logic_vector(2 downto 0);
            o_forward_a        : out std_logic_vector(1 downto 0);
            o_forward_b        : out std_logic_vector(1 downto 0)
        );
    end component;

    component mux_3to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            data_in_2 : in  std_logic_vector(7 downto 0);
            sel       : in  std_logic_vector(1 downto 0);
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    component pipeline_reg_IF_ID is
        port (
            GClock        : in  std_logic;
            GReset        : in  std_logic;
            i_if_id_write : in  std_logic;
            i_flush       : in  std_logic;
            i_pc_plus_4   : in  std_logic_vector(7 downto 0);
            i_instruction : in  std_logic_vector(31 downto 0);
            o_pc_plus_4   : out std_logic_vector(7 downto 0);
            o_instruction : out std_logic_vector(31 downto 0)
        );
    end component;

    component pipeline_reg_ID_EX is
        port (
            GClock         : in  std_logic;
            GReset         : in  std_logic;
            i_clear        : in  std_logic;
            i_pc_plus_4    : in  std_logic_vector(7 downto 0);
            i_read_data_1  : in  std_logic_vector(7 downto 0);
            i_read_data_2  : in  std_logic_vector(7 downto 0);
            i_sign_ext_imm : in  std_logic_vector(7 downto 0);
            i_rs           : in  std_logic_vector(2 downto 0);
            i_rt           : in  std_logic_vector(2 downto 0);
            i_rd           : in  std_logic_vector(2 downto 0);
            i_funct        : in  std_logic_vector(5 downto 0);
            i_reg_dst      : in  std_logic;
            i_alu_op       : in  std_logic_vector(1 downto 0);
            i_alu_src      : in  std_logic;
            i_branch       : in  std_logic;
            i_mem_read     : in  std_logic;
            i_mem_write    : in  std_logic;
            i_reg_write    : in  std_logic;
            i_mem_to_reg   : in  std_logic;
            o_pc_plus_4    : out std_logic_vector(7 downto 0);
            o_read_data_1  : out std_logic_vector(7 downto 0);
            o_read_data_2  : out std_logic_vector(7 downto 0);
            o_sign_ext_imm : out std_logic_vector(7 downto 0);
            o_rs           : out std_logic_vector(2 downto 0);
            o_rt           : out std_logic_vector(2 downto 0);
            o_rd           : out std_logic_vector(2 downto 0);
            o_funct        : out std_logic_vector(5 downto 0);
            o_reg_dst      : out std_logic;
            o_alu_op       : out std_logic_vector(1 downto 0);
            o_alu_src      : out std_logic;
            o_branch       : out std_logic;
            o_mem_read     : out std_logic;
            o_mem_write    : out std_logic;
            o_reg_write    : out std_logic;
            o_mem_to_reg   : out std_logic
        );
    end component;

    component hazard_detection_unit is
        port (
            i_id_ex_mem_read : in  std_logic;
            i_id_ex_rt       : in  std_logic_vector(2 downto 0);
            i_if_id_rs       : in  std_logic_vector(2 downto 0);
            i_if_id_rt       : in  std_logic_vector(2 downto 0);
            o_pc_write       : out std_logic;
            o_if_id_write    : out std_logic;
            o_id_ex_clear    : out std_logic
        );
    end component;

    signal pc_out           : std_logic_vector(7 downto 0);
    signal pc_plus_4        : std_logic_vector(7 downto 0);
    signal pc_next          : std_logic_vector(7 downto 0);
    signal pc_branch_or_seq : std_logic_vector(7 downto 0);
    signal pc_load_en       : std_logic;
    signal if_instruction   : std_logic_vector(31 downto 0);

    signal ifid_pc_plus_4   : std_logic_vector(7 downto 0);
    signal ifid_instruction : std_logic_vector(31 downto 0);

    signal id_opcode        : std_logic_vector(5 downto 0);
    signal id_rs            : std_logic_vector(2 downto 0);
    signal id_rt            : std_logic_vector(2 downto 0);
    signal id_rd            : std_logic_vector(2 downto 0);
    signal id_funct         : std_logic_vector(5 downto 0);
    signal id_imm16         : std_logic_vector(15 downto 0);
    signal id_jump_addr     : std_logic_vector(7 downto 0);
    signal id_sign_ext_imm  : std_logic_vector(7 downto 0);
    signal id_read_data_1   : std_logic_vector(7 downto 0);
    signal id_read_data_2   : std_logic_vector(7 downto 0);
    signal id_jump_target   : std_logic_vector(7 downto 0);

    signal ctrl_reg_dst     : std_logic;
    signal ctrl_alu_src     : std_logic;
    signal ctrl_mem_to_reg  : std_logic;
    signal ctrl_reg_write   : std_logic;
    signal ctrl_mem_read    : std_logic;
    signal ctrl_mem_write   : std_logic;
    signal ctrl_branch      : std_logic;
    signal ctrl_jump        : std_logic;
    signal ctrl_alu_op      : std_logic_vector(1 downto 0);

    signal id_reg_dst_h     : std_logic;
    signal id_alu_src_h     : std_logic;
    signal id_mem_to_reg_h  : std_logic;
    signal id_reg_write_h   : std_logic;
    signal id_mem_read_h    : std_logic;
    signal id_mem_write_h   : std_logic;
    signal id_branch_h      : std_logic;
    signal id_alu_op_h      : std_logic_vector(1 downto 0);

    signal haz_pc_write     : std_logic;
    signal haz_ifid_write   : std_logic;
    signal haz_mux          : std_logic;

    signal idex_pc_plus_4    : std_logic_vector(7 downto 0);
    signal idex_read_data_1  : std_logic_vector(7 downto 0);
    signal idex_read_data_2  : std_logic_vector(7 downto 0);
    signal idex_sign_ext_imm : std_logic_vector(7 downto 0);
    signal idex_rs           : std_logic_vector(2 downto 0);
    signal idex_rt           : std_logic_vector(2 downto 0);
    signal idex_rd           : std_logic_vector(2 downto 0);
    signal idex_funct        : std_logic_vector(5 downto 0);
    signal idex_reg_dst      : std_logic;
    signal idex_alu_op       : std_logic_vector(1 downto 0);
    signal idex_alu_src      : std_logic;
    signal idex_branch       : std_logic;
    signal idex_mem_read     : std_logic;
    signal idex_mem_write    : std_logic;
    signal idex_reg_write    : std_logic;
    signal idex_mem_to_reg   : std_logic;

    signal forward_a         : std_logic_vector(1 downto 0);
    signal forward_b         : std_logic_vector(1 downto 0);
    signal ex_alu_input_a    : std_logic_vector(7 downto 0);
    signal ex_fwd_b_out      : std_logic_vector(7 downto 0);
    signal ex_alu_input_b    : std_logic_vector(7 downto 0);
    signal ex_alu_result     : std_logic_vector(7 downto 0);
    signal ex_alu_zero       : std_logic;
    signal ex_alu_overflow   : std_logic;
    signal ex_write_reg      : std_logic_vector(2 downto 0);
    signal ex_branch_offset  : std_logic_vector(7 downto 0);
    signal ex_branch_target  : std_logic_vector(7 downto 0);

    signal exmem_branch_in     : std_logic;
    signal exmem_mem_read_in   : std_logic;
    signal exmem_mem_write_in  : std_logic;
    signal exmem_reg_write_in  : std_logic;
    signal exmem_mem_to_reg_in : std_logic;

    signal exmem_branch_target : std_logic_vector(7 downto 0);
    signal exmem_alu_result    : std_logic_vector(7 downto 0);
    signal exmem_read_data_2   : std_logic_vector(7 downto 0);
    signal exmem_zero          : std_logic;
    signal exmem_write_reg     : std_logic_vector(2 downto 0);
    signal exmem_branch        : std_logic;
    signal exmem_mem_read      : std_logic;
    signal exmem_mem_write     : std_logic;
    signal exmem_reg_write     : std_logic;
    signal exmem_mem_to_reg    : std_logic;

    signal pc_src              : std_logic;
    signal mem_read_data_32    : std_logic_vector(31 downto 0);
    signal mem_read_data       : std_logic_vector(7 downto 0);
    signal mem_write_data_32   : std_logic_vector(31 downto 0);

    signal memwb_mem_read_data : std_logic_vector(7 downto 0);
    signal memwb_alu_result    : std_logic_vector(7 downto 0);
    signal memwb_write_reg     : std_logic_vector(2 downto 0);
    signal memwb_reg_write     : std_logic;
    signal memwb_mem_to_reg    : std_logic;

    signal wb_write_data       : std_logic_vector(7 downto 0);

    signal if_id_flush         : std_logic;
    signal id_ex_flush         : std_logic;

    signal inst_ex_in          : std_logic_vector(31 downto 0);
    signal inst_ex             : std_logic_vector(31 downto 0);
    signal inst_mem_in         : std_logic_vector(31 downto 0);
    signal inst_mem            : std_logic_vector(31 downto 0);
    signal inst_wb             : std_logic_vector(31 downto 0);

    signal ctrl_byte           : std_logic_vector(7 downto 0);

    signal id_pc_in            : std_logic_vector(7 downto 0);
    signal id_pc               : std_logic_vector(7 downto 0);
    signal id_pc_load          : std_logic;

begin

    pc_src      <= exmem_branch and exmem_zero;
    if_id_flush <= pc_src or ctrl_jump;
    id_ex_flush <= pc_src or haz_mux;
    pc_load_en  <= haz_pc_write or pc_src or ctrl_jump;

    exmem_branch_in     <= idex_branch     and (not pc_src);
    exmem_mem_read_in   <= idex_mem_read   and (not pc_src);
    exmem_mem_write_in  <= idex_mem_write  and (not pc_src);
    exmem_reg_write_in  <= idex_reg_write  and (not pc_src);
    exmem_mem_to_reg_in <= idex_mem_to_reg and (not pc_src);

    id_reg_dst_h    <= ctrl_reg_dst    and (not haz_mux);
    id_alu_src_h    <= ctrl_alu_src    and (not haz_mux);
    id_mem_to_reg_h <= ctrl_mem_to_reg and (not haz_mux);
    id_reg_write_h  <= ctrl_reg_write  and (not haz_mux);
    id_mem_read_h   <= ctrl_mem_read   and (not haz_mux);
    id_mem_write_h  <= ctrl_mem_write  and (not haz_mux);
    id_branch_h     <= ctrl_branch     and (not haz_mux);
    id_alu_op_h(1)  <= ctrl_alu_op(1)  and (not haz_mux);
    id_alu_op_h(0)  <= ctrl_alu_op(0)  and (not haz_mux);

    pc_reg: reg_8bit
        port map (
            data_in     => pc_next,
            load_enable => pc_load_en,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => pc_out
        );

    adder_pc_plus_4: full_adder_8bit
        port map (
            term_a    => pc_out,
            term_b    => "00000100",
            carry_in  => '0',
            sum_out   => pc_plus_4,
            carry_out => open
        );

    instr_mem: rom32
        port map (
            address => pc_out,
            clock   => GClock,
            q       => if_instruction
        );

    pc_branch_mux: mux_2to1_8bit
        port map (
            data_in_0 => pc_plus_4,
            data_in_1 => exmem_branch_target,
            sel_line  => pc_src,
            data_out  => pc_branch_or_seq
        );

    pc_jump_mux: mux_2to1_8bit
        port map (
            data_in_0 => pc_branch_or_seq,
            data_in_1 => id_jump_target,
            sel_line  => ctrl_jump,
            data_out  => pc_next
        );

    id_pc_in   <= (others => '0') when if_id_flush = '1' else pc_out;
    id_pc_load <= if_id_flush or haz_ifid_write;

    id_pc_reg: reg_8bit
        port map (
            data_in     => id_pc_in,
            load_enable => id_pc_load,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => id_pc
        );

    ifid_reg: pipeline_reg_IF_ID
        port map (
            GClock        => GClock,
            GReset        => GReset,
            i_if_id_write => haz_ifid_write,
            i_flush       => if_id_flush,
            i_pc_plus_4   => pc_plus_4,
            i_instruction => if_instruction,
            o_pc_plus_4   => ifid_pc_plus_4,
            o_instruction => ifid_instruction
        );

    decoder: instruction_decoder
        port map (
            i_instruction => ifid_instruction,
            o_opcode      => id_opcode,
            o_rs          => id_rs,
            o_rt          => id_rt,
            o_rd          => id_rd,
            o_funct       => id_funct,
            o_imm16       => id_imm16,
            o_jump_addr   => id_jump_addr
        );

    ctrl: control_unit
        port map (
            i_opcode     => id_opcode,
            o_reg_dst    => ctrl_reg_dst,
            o_alu_src    => ctrl_alu_src,
            o_mem_to_reg => ctrl_mem_to_reg,
            o_reg_write  => ctrl_reg_write,
            o_mem_read   => ctrl_mem_read,
            o_mem_write  => ctrl_mem_write,
            o_branch     => ctrl_branch,
            o_jump       => ctrl_jump,
            o_alu_op     => ctrl_alu_op
        );

    reg_file: register_file
        port map (
            GClock     => GClock,
            GReset     => GReset,
            reg_write  => memwb_reg_write,
            read_reg1  => id_rs,
            read_reg2  => id_rt,
            write_reg  => memwb_write_reg,
            write_data => wb_write_data,
            read_data1 => id_read_data_1,
            read_data2 => id_read_data_2
        );

    sign_ext: sign_extend
        port map (
            i_imm16 => id_imm16,
            o_imm8  => id_sign_ext_imm
        );

    sll_jump: shift_left_2
        port map (
            i_input  => id_jump_addr,
            o_output => id_jump_target
        );

    hazard_det: hazard_detection_unit
        port map (
            i_id_ex_mem_read => idex_mem_read,
            i_id_ex_rt       => idex_rt,
            i_if_id_rs       => id_rs,
            i_if_id_rt       => id_rt,
            o_pc_write       => haz_pc_write,
            o_if_id_write    => haz_ifid_write,
            o_id_ex_clear    => haz_mux
        );

    idex_reg: pipeline_reg_ID_EX
        port map (
            GClock         => GClock,
            GReset         => GReset,
            i_clear        => id_ex_flush,
            i_pc_plus_4    => ifid_pc_plus_4,
            i_read_data_1  => id_read_data_1,
            i_read_data_2  => id_read_data_2,
            i_sign_ext_imm => id_sign_ext_imm,
            i_rs           => id_rs,
            i_rt           => id_rt,
            i_rd           => id_rd,
            i_funct        => id_funct,
            i_reg_dst      => id_reg_dst_h,
            i_alu_op       => id_alu_op_h,
            i_alu_src      => id_alu_src_h,
            i_branch       => id_branch_h,
            i_mem_read     => id_mem_read_h,
            i_mem_write    => id_mem_write_h,
            i_reg_write    => id_reg_write_h,
            i_mem_to_reg   => id_mem_to_reg_h,
            o_pc_plus_4    => idex_pc_plus_4,
            o_read_data_1  => idex_read_data_1,
            o_read_data_2  => idex_read_data_2,
            o_sign_ext_imm => idex_sign_ext_imm,
            o_rs           => idex_rs,
            o_rt           => idex_rt,
            o_rd           => idex_rd,
            o_funct        => idex_funct,
            o_reg_dst      => idex_reg_dst,
            o_alu_op       => idex_alu_op,
            o_alu_src      => idex_alu_src,
            o_branch       => idex_branch,
            o_mem_read     => idex_mem_read,
            o_mem_write    => idex_mem_write,
            o_reg_write    => idex_reg_write,
            o_mem_to_reg   => idex_mem_to_reg
        );

    fwd_unit: forwarding_unit
        port map (
            i_id_ex_rs         => idex_rs,
            i_id_ex_rt         => idex_rt,
            i_ex_mem_reg_write => exmem_reg_write,
            i_ex_mem_rd        => exmem_write_reg,
            i_mem_wb_reg_write => memwb_reg_write,
            i_mem_wb_rd        => memwb_write_reg,
            o_forward_a        => forward_a,
            o_forward_b        => forward_b
        );

    fwd_mux_a: mux_3to1_8bit
        port map (
            data_in_0 => idex_read_data_1,
            data_in_1 => exmem_alu_result,
            data_in_2 => wb_write_data,
            sel       => forward_a,
            data_out  => ex_alu_input_a
        );

    fwd_mux_b: mux_3to1_8bit
        port map (
            data_in_0 => idex_read_data_2,
            data_in_1 => exmem_alu_result,
            data_in_2 => wb_write_data,
            sel       => forward_b,
            data_out  => ex_fwd_b_out
        );

    alu_src_mux: mux_2to1_8bit
        port map (
            data_in_0 => ex_fwd_b_out,
            data_in_1 => idex_sign_ext_imm,
            sel_line  => idex_alu_src,
            data_out  => ex_alu_input_b
        );

    alu: alu_module
        port map (
            i_alu_op   => idex_alu_op,
            i_funct    => idex_funct,
            i_a        => ex_alu_input_a,
            i_b        => ex_alu_input_b,
            o_result   => ex_alu_result,
            o_zero     => ex_alu_zero,
            o_overflow => ex_alu_overflow
        );

    reg_dst_mux: mux_2to1_3bit
        port map (
            data_in_0 => idex_rt,
            data_in_1 => idex_rd,
            sel_line  => idex_reg_dst,
            data_out  => ex_write_reg
        );

    sll_branch: shift_left_2
        port map (
            i_input  => idex_sign_ext_imm,
            o_output => ex_branch_offset
        );

    adder_branch: full_adder_8bit
        port map (
            term_a    => idex_pc_plus_4,
            term_b    => ex_branch_offset,
            carry_in  => '0',
            sum_out   => ex_branch_target,
            carry_out => open
        );

    exmem_reg: pipeline_reg_EX_MEM
        port map (
            GClock          => GClock,
            GReset          => GReset,
            i_branch_target => ex_branch_target,
            i_alu_result    => ex_alu_result,
            i_read_data_2   => ex_fwd_b_out,
            i_zero          => ex_alu_zero,
            i_write_reg     => ex_write_reg,
            i_branch        => exmem_branch_in,
            i_mem_read      => exmem_mem_read_in,
            i_mem_write     => exmem_mem_write_in,
            i_reg_write     => exmem_reg_write_in,
            i_mem_to_reg    => exmem_mem_to_reg_in,
            o_branch_target => exmem_branch_target,
            o_alu_result    => exmem_alu_result,
            o_read_data_2   => exmem_read_data_2,
            o_zero          => exmem_zero,
            o_write_reg     => exmem_write_reg,
            o_branch        => exmem_branch,
            o_mem_read      => exmem_mem_read,
            o_mem_write     => exmem_mem_write,
            o_reg_write     => exmem_reg_write,
            o_mem_to_reg    => exmem_mem_to_reg
        );

    mem_write_data_32 <= x"000000" & exmem_read_data_2;

    data_mem: ram32
        port map (
            clock     => GClock,
            data      => mem_write_data_32,
            rdaddress => exmem_alu_result,
            wraddress => exmem_alu_result,
            wren      => exmem_mem_write,
            q         => mem_read_data_32
        );

    mem_read_data <= mem_read_data_32(7 downto 0);

    memwb_reg: pipeline_reg_MEM_WB
        port map (
            GClock          => GClock,
            GReset          => GReset,
            i_mem_read_data => mem_read_data,
            i_alu_result    => exmem_alu_result,
            i_write_reg     => exmem_write_reg,
            i_reg_write     => exmem_reg_write,
            i_mem_to_reg    => exmem_mem_to_reg,
            o_mem_read_data => memwb_mem_read_data,
            o_alu_result    => memwb_alu_result,
            o_write_reg     => memwb_write_reg,
            o_reg_write     => memwb_reg_write,
            o_mem_to_reg    => memwb_mem_to_reg
        );

    wb_mux: mux_2to1_8bit
        port map (
            data_in_0 => memwb_alu_result,
            data_in_1 => memwb_mem_read_data,
            sel_line  => memwb_mem_to_reg,
            data_out  => wb_write_data
        );

    inst_ex_in  <= x"00000000" when id_ex_flush = '1' else ifid_instruction;
    inst_mem_in <= x"00000000" when pc_src = '1' else inst_ex;

    inst_ex_reg: reg_32bit
        port map (
            data_in     => inst_ex_in,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => inst_ex
        );

    inst_mem_reg: reg_32bit
        port map (
            data_in     => inst_mem_in,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => inst_mem
        );

    inst_wb_reg: reg_32bit
        port map (
            data_in     => inst_mem,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => inst_wb
        );

    instr_select_mux: mux_8to1_32bit
        port map (
            sel_line  => InstrSelect,
            data_in_0 => if_instruction,
            data_in_1 => ifid_instruction,
            data_in_2 => inst_ex,
            data_in_3 => inst_mem,
            data_in_4 => inst_wb,
            data_in_5 => x"00000000",
            data_in_6 => x"00000000",
            data_in_7 => x"00000000",
            data_out  => InstructionOut
        );

    ctrl_byte(7) <= '0';
    ctrl_byte(6) <= ctrl_reg_dst;
    ctrl_byte(5) <= ctrl_jump;
    ctrl_byte(4) <= ctrl_mem_read;
    ctrl_byte(3) <= ctrl_mem_to_reg;
    ctrl_byte(2) <= ctrl_alu_op(1);
    ctrl_byte(1) <= ctrl_alu_op(0);
    ctrl_byte(0) <= ctrl_alu_src;

    value_select_mux: mux_8to1_8bit
        port map (
            sel_line  => ValueSelect,
            data_in_0 => id_pc,
            data_in_1 => exmem_alu_result,
            data_in_2 => id_read_data_1,
            data_in_3 => id_read_data_2,
            data_in_4 => wb_write_data,
            data_in_5 => ctrl_byte,
            data_in_6 => ctrl_byte,
            data_in_7 => ctrl_byte,
            data_out  => MuxOut
        );

    BranchOut   <= exmem_branch;
    ZeroOut     <= exmem_zero;
    MemWriteOut <= exmem_mem_write;
    RegWriteOut <= memwb_reg_write;

    o_pc           <= pc_out;
    o_if_instr     <= if_instruction;
    o_id_instr     <= ifid_instruction;
    o_ex_instr     <= inst_ex;
    o_mem_instr    <= inst_mem;
    o_wb_instr     <= inst_wb;
    o_reg_data_1   <= id_read_data_1;
    o_reg_data_2   <= id_read_data_2;
    o_alu_result   <= exmem_alu_result;
    o_wb_data      <= wb_write_data;
    o_write_reg    <= memwb_write_reg;
    o_stall        <= haz_mux;
    o_forward_a    <= forward_a;
    o_forward_b    <= forward_b;
    o_branch_taken <= pc_src;
    o_if_id_flush  <= if_id_flush;
    o_id_ex_flush  <= id_ex_flush;

end architecture structural;
