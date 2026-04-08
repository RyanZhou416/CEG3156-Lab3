library ieee;
use ieee.std_logic_1164.all;

entity pipeline_reg_ID_EX is
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
        i_alu_src      : in  std_logic;
        i_alu_op       : in  std_logic_vector(1 downto 0);
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
        o_alu_src      : out std_logic;
        o_alu_op       : out std_logic_vector(1 downto 0);
        o_branch       : out std_logic;
        o_mem_read     : out std_logic;
        o_mem_write    : out std_logic;
        o_reg_write    : out std_logic;
        o_mem_to_reg   : out std_logic
    );
end entity pipeline_reg_ID_EX;

architecture structural of pipeline_reg_ID_EX is

    component reg_1bit is
        port (
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_in     : in  std_logic;
            load_enable : in  std_logic;
            data_out    : out std_logic
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

    signal load : std_logic;

    signal eff_reg_dst    : std_logic;
    signal eff_alu_src    : std_logic;
    signal eff_alu_op     : std_logic_vector(1 downto 0);
    signal eff_branch     : std_logic;
    signal eff_mem_read   : std_logic;
    signal eff_mem_write  : std_logic;
    signal eff_reg_write  : std_logic;
    signal eff_mem_to_reg : std_logic;

begin

    load <= '1';

    eff_reg_dst    <= i_reg_dst    and not i_clear;
    eff_alu_src    <= i_alu_src    and not i_clear;
    eff_alu_op(1)  <= i_alu_op(1)  and not i_clear;
    eff_alu_op(0)  <= i_alu_op(0)  and not i_clear;
    eff_branch     <= i_branch     and not i_clear;
    eff_mem_read   <= i_mem_read   and not i_clear;
    eff_mem_write  <= i_mem_write  and not i_clear;
    eff_reg_write  <= i_reg_write  and not i_clear;
    eff_mem_to_reg <= i_mem_to_reg and not i_clear;

    reg_pc : reg_8bit
        port map (data_in => i_pc_plus_4, load_enable => load,
                  GClock => GClock, GReset => GReset, data_out => o_pc_plus_4);

    reg_rd1 : reg_8bit
        port map (data_in => i_read_data_1, load_enable => load,
                  GClock => GClock, GReset => GReset, data_out => o_read_data_1);

    reg_rd2 : reg_8bit
        port map (data_in => i_read_data_2, load_enable => load,
                  GClock => GClock, GReset => GReset, data_out => o_read_data_2);

    reg_imm : reg_8bit
        port map (data_in => i_sign_ext_imm, load_enable => load,
                  GClock => GClock, GReset => GReset, data_out => o_sign_ext_imm);

    gen_rs : for i in 2 downto 0 generate
        r : reg_1bit port map (GClock => GClock, GReset => GReset,
                               data_in => i_rs(i), load_enable => load,
                               data_out => o_rs(i));
    end generate gen_rs;

    gen_rt : for i in 2 downto 0 generate
        r : reg_1bit port map (GClock => GClock, GReset => GReset,
                               data_in => i_rt(i), load_enable => load,
                               data_out => o_rt(i));
    end generate gen_rt;

    gen_rd : for i in 2 downto 0 generate
        r : reg_1bit port map (GClock => GClock, GReset => GReset,
                               data_in => i_rd(i), load_enable => load,
                               data_out => o_rd(i));
    end generate gen_rd;

    gen_funct : for i in 5 downto 0 generate
        r : reg_1bit port map (GClock => GClock, GReset => GReset,
                               data_in => i_funct(i), load_enable => load,
                               data_out => o_funct(i));
    end generate gen_funct;

    reg_reg_dst : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_reg_dst, load_enable => load,
                  data_out => o_reg_dst);

    reg_alu_src : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_alu_src, load_enable => load,
                  data_out => o_alu_src);

    gen_alu_op : for i in 1 downto 0 generate
        r : reg_1bit port map (GClock => GClock, GReset => GReset,
                               data_in => eff_alu_op(i), load_enable => load,
                               data_out => o_alu_op(i));
    end generate gen_alu_op;

    reg_branch : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_branch, load_enable => load,
                  data_out => o_branch);

    reg_mem_read : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_mem_read, load_enable => load,
                  data_out => o_mem_read);

    reg_mem_write : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_mem_write, load_enable => load,
                  data_out => o_mem_write);

    reg_reg_write : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_reg_write, load_enable => load,
                  data_out => o_reg_write);

    reg_mem_to_reg : reg_1bit
        port map (GClock => GClock, GReset => GReset,
                  data_in => eff_mem_to_reg, load_enable => load,
                  data_out => o_mem_to_reg);

end architecture structural;