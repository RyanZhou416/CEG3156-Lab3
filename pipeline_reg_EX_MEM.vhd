library ieee;
use ieee.std_logic_1164.all;

entity pipeline_reg_EX_MEM is
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
end entity pipeline_reg_EX_MEM;

architecture structural of pipeline_reg_EX_MEM is

    component reg_8bit is
        port (
            data_in     : in  std_logic_vector(7 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    component reg_1bit is
        port (
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_in     : in  std_logic;
            load_enable : in  std_logic;
            data_out    : out std_logic
        );
    end component;

    signal load : std_logic;

begin

    load <= '1';

    reg_branch_target : reg_8bit
        port map (data_in => i_branch_target, load_enable => load, GClock => GClock, GReset => GReset, data_out => o_branch_target);

    reg_alu_result : reg_8bit
        port map (data_in => i_alu_result, load_enable => load, GClock => GClock, GReset => GReset, data_out => o_alu_result);

    reg_read_data_2 : reg_8bit
        port map (data_in => i_read_data_2, load_enable => load, GClock => GClock, GReset => GReset, data_out => o_read_data_2);

    reg_zero : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_zero, load_enable => load, data_out => o_zero);

    gen_write_reg : for i in 2 downto 0 generate
        reg_wr : reg_1bit
            port map (GClock => GClock, GReset => GReset, data_in => i_write_reg(i), load_enable => load, data_out => o_write_reg(i));
    end generate gen_write_reg;

    reg_branch : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_branch, load_enable => load, data_out => o_branch);

    reg_mem_read : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_mem_read, load_enable => load, data_out => o_mem_read);

    reg_mem_write : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_mem_write, load_enable => load, data_out => o_mem_write);

    reg_reg_write : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_reg_write, load_enable => load, data_out => o_reg_write);

    reg_mem_to_reg : reg_1bit
        port map (GClock => GClock, GReset => GReset, data_in => i_mem_to_reg, load_enable => load, data_out => o_mem_to_reg);

end architecture structural;
