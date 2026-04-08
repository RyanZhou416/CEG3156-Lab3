library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port (
        i_id_ex_mem_read : in  std_logic;
        i_id_ex_rt       : in  std_logic_vector(2 downto 0);
        i_if_id_rs       : in  std_logic_vector(2 downto 0);
        i_if_id_rt       : in  std_logic_vector(2 downto 0);
        o_pc_write       : out std_logic;
        o_if_id_write    : out std_logic;
        o_id_ex_clear    : out std_logic
    );
end entity hazard_detection_unit;

architecture structural of hazard_detection_unit is

    signal xnor_rs  : std_logic_vector(2 downto 0);
    signal xnor_rt  : std_logic_vector(2 downto 0);
    signal match_rs : std_logic;
    signal match_rt : std_logic;
    signal hazard   : std_logic;

begin

    xnor_rs(0) <= i_id_ex_rt(0) xnor i_if_id_rs(0);
    xnor_rs(1) <= i_id_ex_rt(1) xnor i_if_id_rs(1);
    xnor_rs(2) <= i_id_ex_rt(2) xnor i_if_id_rs(2);
    match_rs   <= xnor_rs(0) and xnor_rs(1) and xnor_rs(2);

    xnor_rt(0) <= i_id_ex_rt(0) xnor i_if_id_rt(0);
    xnor_rt(1) <= i_id_ex_rt(1) xnor i_if_id_rt(1);
    xnor_rt(2) <= i_id_ex_rt(2) xnor i_if_id_rt(2);
    match_rt   <= xnor_rt(0) and xnor_rt(1) and xnor_rt(2);

    hazard <= i_id_ex_mem_read and (match_rs or match_rt);

    o_pc_write    <= not hazard;
    o_if_id_write <= not hazard;
    o_id_ex_clear <= hazard;

end architecture structural;