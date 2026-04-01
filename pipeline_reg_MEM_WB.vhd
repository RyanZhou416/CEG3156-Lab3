library ieee;
use ieee.std_logic_1164.all;

entity pipeline_reg_MEM_WB is
    port (
        GClock           : in  std_logic;
        GReset           : in  std_logic;
        -- Data inputs (from MEM stage)
        i_mem_read_data  : in  std_logic_vector(7 downto 0);
        i_alu_result     : in  std_logic_vector(7 downto 0);
        i_write_reg      : in  std_logic_vector(2 downto 0);
        -- Control inputs (WB group)
        i_reg_write      : in  std_logic;
        i_mem_to_reg     : in  std_logic;
        -- Data outputs
        o_mem_read_data  : out std_logic_vector(7 downto 0);
        o_alu_result     : out std_logic_vector(7 downto 0);
        o_write_reg      : out std_logic_vector(2 downto 0);
        -- Control outputs (WB group)
        o_reg_write      : out std_logic;
        o_mem_to_reg     : out std_logic
    );
end entity pipeline_reg_MEM_WB;

architecture structural of pipeline_reg_MEM_WB is

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

    -- 8-bit data registers
    reg_mem_read_data : reg_8bit
        port map (
            data_in     => i_mem_read_data,
            load_enable => load,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => o_mem_read_data
        );

    reg_alu_result : reg_8bit
        port map (
            data_in     => i_alu_result,
            load_enable => load,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => o_alu_result
        );

    -- 3-bit write register number
    gen_write_reg : for i in 2 downto 0 generate
        reg_wr : reg_1bit
            port map (
                GClock      => GClock,
                GReset      => GReset,
                data_in     => i_write_reg(i),
                load_enable => load,
                data_out    => o_write_reg(i)
            );
    end generate gen_write_reg;

    -- WB control signals
    reg_reg_write : reg_1bit
        port map (
            GClock      => GClock,
            GReset      => GReset,
            data_in     => i_reg_write,
            load_enable => load,
            data_out    => o_reg_write
        );

    reg_mem_to_reg : reg_1bit
        port map (
            GClock      => GClock,
            GReset      => GReset,
            data_in     => i_mem_to_reg,
            load_enable => load,
            data_out    => o_mem_to_reg
        );

end architecture structural;
