library ieee;
use ieee.std_logic_1164.all;

entity register_file is
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
end entity register_file;

architecture structural of register_file is

    component reg_8bit is
        port (
            data_in     : in  std_logic_vector(7 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    component decoder_3to8 is
        port (
            i_sel : in  std_logic_vector(2 downto 0);
            o_out : out std_logic_vector(7 downto 0)
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

    signal dec_out : std_logic_vector(7 downto 0);
    signal we      : std_logic_vector(7 downto 0);

    type reg_array_t is array(0 to 7) of std_logic_vector(7 downto 0);
    signal reg_out : reg_array_t;

begin

    reg_out(0) <= (others => '0');

    write_decoder: decoder_3to8
        port map (i_sel => write_reg, o_out => dec_out);

    we(0) <= '0';
    gen_we: for i in 1 to 7 generate
        we(i) <= dec_out(i) and reg_write;
    end generate gen_we;

    gen_regs: for i in 1 to 7 generate
        reg_i: reg_8bit
            port map (
                data_in     => write_data,
                load_enable => we(i),
                GClock      => GClock,
                GReset      => GReset,
                data_out    => reg_out(i)
            );
    end generate gen_regs;

    read_mux1: mux_8to1_8bit
        port map (
            sel_line  => read_reg1,
            data_in_0 => reg_out(0),
            data_in_1 => reg_out(1),
            data_in_2 => reg_out(2),
            data_in_3 => reg_out(3),
            data_in_4 => reg_out(4),
            data_in_5 => reg_out(5),
            data_in_6 => reg_out(6),
            data_in_7 => reg_out(7),
            data_out  => read_data1
        );

    read_mux2: mux_8to1_8bit
        port map (
            sel_line  => read_reg2,
            data_in_0 => reg_out(0),
            data_in_1 => reg_out(1),
            data_in_2 => reg_out(2),
            data_in_3 => reg_out(3),
            data_in_4 => reg_out(4),
            data_in_5 => reg_out(5),
            data_in_6 => reg_out(6),
            data_in_7 => reg_out(7),
            data_out  => read_data2
        );

end architecture structural;
