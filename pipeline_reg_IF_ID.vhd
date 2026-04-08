library ieee;
use ieee.std_logic_1164.all;

entity pipeline_reg_IF_ID is
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
end entity pipeline_reg_IF_ID;

architecture structural of pipeline_reg_IF_ID is

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

    signal eff_load        : std_logic;
    signal eff_instruction : std_logic_vector(31 downto 0);
    signal eff_pc_plus_4   : std_logic_vector(7 downto 0);

begin

    eff_load <= i_flush or i_if_id_write;

    gen_instr_flush : for i in 31 downto 0 generate
        eff_instruction(i) <= '0' when i_flush = '1' else i_instruction(i);
    end generate gen_instr_flush;

    gen_pc_flush : for i in 7 downto 0 generate
        eff_pc_plus_4(i) <= '0' when i_flush = '1' else i_pc_plus_4(i);
    end generate gen_pc_flush;

    reg_pc : reg_8bit
        port map (
            data_in     => eff_pc_plus_4,
            load_enable => eff_load,
            GClock      => GClock,
            GReset      => GReset,
            data_out    => o_pc_plus_4
        );

    gen_instr : for i in 31 downto 0 generate
        reg_instr_bit : reg_1bit
            port map (
                GClock      => GClock,
                GReset      => GReset,
                data_in     => eff_instruction(i),
                load_enable => eff_load,
                data_out    => o_instruction(i)
            );
    end generate gen_instr;

end architecture structural;