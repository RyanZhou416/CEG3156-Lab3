library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port (
        -- From ID/EX pipeline register
        i_id_ex_mem_read : in  std_logic;
        i_id_ex_rt       : in  std_logic_vector(2 downto 0);
        -- From IF/ID pipeline register (current instruction being decoded)
        i_if_id_rs       : in  std_logic_vector(2 downto 0);
        i_if_id_rt       : in  std_logic_vector(2 downto 0);
        -- Stall outputs: active-low (0 = hold)
        o_pc_write       : out std_logic;
        o_if_id_write    : out std_logic;
        -- Bubble output: active-high (1 = zero ID/EX control signals)
        o_id_ex_clear    : out std_logic
    );
end entity hazard_detection_unit;

architecture structural of hazard_detection_unit is

    -- XNOR-based 3-bit equality comparators
    signal xnor_rs  : std_logic_vector(2 downto 0);
    signal xnor_rt  : std_logic_vector(2 downto 0);
    signal match_rs : std_logic;  -- id_ex_rt = if_id_rs
    signal match_rt : std_logic;  -- id_ex_rt = if_id_rt
    signal hazard   : std_logic;

begin

    -- Bit-wise XNOR: output '1' when bits are equal
    xnor_rs(0) <= i_id_ex_rt(0) xnor i_if_id_rs(0);
    xnor_rs(1) <= i_id_ex_rt(1) xnor i_if_id_rs(1);
    xnor_rs(2) <= i_id_ex_rt(2) xnor i_if_id_rs(2);
    match_rs   <= xnor_rs(0) and xnor_rs(1) and xnor_rs(2);

    xnor_rt(0) <= i_id_ex_rt(0) xnor i_if_id_rt(0);
    xnor_rt(1) <= i_id_ex_rt(1) xnor i_if_id_rt(1);
    xnor_rt(2) <= i_id_ex_rt(2) xnor i_if_id_rt(2);
    match_rt   <= xnor_rt(0) and xnor_rt(1) and xnor_rt(2);

    -- Load-use hazard:
    -- if (ID/EX.MemRead = '1') and
    --    (ID/EX.rt = IF/ID.rs OR ID/EX.rt = IF/ID.rt)
    hazard <= i_id_ex_mem_read and (match_rs or match_rt);

    o_pc_write    <= not hazard;  -- '0' freezes PC
    o_if_id_write <= not hazard;  -- '0' freezes IF/ID register
    o_id_ex_clear <= hazard;      -- '1' inserts NOP bubble into ID/EX

end architecture structural;