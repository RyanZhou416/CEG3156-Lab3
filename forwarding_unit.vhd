library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
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
end entity forwarding_unit;

architecture gate_logic of forwarding_unit is

    signal eq_exmem_rd_rs_2 : std_logic;
    signal eq_exmem_rd_rs_1 : std_logic;
    signal eq_exmem_rd_rs_0 : std_logic;
    signal eq_exmem_rd_rs   : std_logic;

    signal eq_exmem_rd_rt_2 : std_logic;
    signal eq_exmem_rd_rt_1 : std_logic;
    signal eq_exmem_rd_rt_0 : std_logic;
    signal eq_exmem_rd_rt   : std_logic;

    signal eq_memwb_rd_rs_2 : std_logic;
    signal eq_memwb_rd_rs_1 : std_logic;
    signal eq_memwb_rd_rs_0 : std_logic;
    signal eq_memwb_rd_rs   : std_logic;

    signal eq_memwb_rd_rt_2 : std_logic;
    signal eq_memwb_rd_rt_1 : std_logic;
    signal eq_memwb_rd_rt_0 : std_logic;
    signal eq_memwb_rd_rt   : std_logic;

    signal exmem_rd_nz : std_logic;
    signal memwb_rd_nz : std_logic;

    signal ex_hazard_a  : std_logic;
    signal ex_hazard_b  : std_logic;
    signal mem_hazard_a : std_logic;
    signal mem_hazard_b : std_logic;

begin

    eq_exmem_rd_rs_2 <= i_ex_mem_rd(2) xnor i_id_ex_rs(2);
    eq_exmem_rd_rs_1 <= i_ex_mem_rd(1) xnor i_id_ex_rs(1);
    eq_exmem_rd_rs_0 <= i_ex_mem_rd(0) xnor i_id_ex_rs(0);
    eq_exmem_rd_rs   <= eq_exmem_rd_rs_2 and eq_exmem_rd_rs_1 and eq_exmem_rd_rs_0;

    eq_exmem_rd_rt_2 <= i_ex_mem_rd(2) xnor i_id_ex_rt(2);
    eq_exmem_rd_rt_1 <= i_ex_mem_rd(1) xnor i_id_ex_rt(1);
    eq_exmem_rd_rt_0 <= i_ex_mem_rd(0) xnor i_id_ex_rt(0);
    eq_exmem_rd_rt   <= eq_exmem_rd_rt_2 and eq_exmem_rd_rt_1 and eq_exmem_rd_rt_0;

    eq_memwb_rd_rs_2 <= i_mem_wb_rd(2) xnor i_id_ex_rs(2);
    eq_memwb_rd_rs_1 <= i_mem_wb_rd(1) xnor i_id_ex_rs(1);
    eq_memwb_rd_rs_0 <= i_mem_wb_rd(0) xnor i_id_ex_rs(0);
    eq_memwb_rd_rs   <= eq_memwb_rd_rs_2 and eq_memwb_rd_rs_1 and eq_memwb_rd_rs_0;

    eq_memwb_rd_rt_2 <= i_mem_wb_rd(2) xnor i_id_ex_rt(2);
    eq_memwb_rd_rt_1 <= i_mem_wb_rd(1) xnor i_id_ex_rt(1);
    eq_memwb_rd_rt_0 <= i_mem_wb_rd(0) xnor i_id_ex_rt(0);
    eq_memwb_rd_rt   <= eq_memwb_rd_rt_2 and eq_memwb_rd_rt_1 and eq_memwb_rd_rt_0;

    exmem_rd_nz <= i_ex_mem_rd(2) or i_ex_mem_rd(1) or i_ex_mem_rd(0);
    memwb_rd_nz <= i_mem_wb_rd(2) or i_mem_wb_rd(1) or i_mem_wb_rd(0);

    ex_hazard_a <= i_ex_mem_reg_write and exmem_rd_nz and eq_exmem_rd_rs;
    ex_hazard_b <= i_ex_mem_reg_write and exmem_rd_nz and eq_exmem_rd_rt;

    mem_hazard_a <= i_mem_wb_reg_write and memwb_rd_nz
                    and (not ex_hazard_a) and eq_memwb_rd_rs;
    mem_hazard_b <= i_mem_wb_reg_write and memwb_rd_nz
                    and (not ex_hazard_b) and eq_memwb_rd_rt;

    o_forward_a(1) <= ex_hazard_a;
    o_forward_a(0) <= mem_hazard_a;

    o_forward_b(1) <= ex_hazard_b;
    o_forward_b(0) <= mem_hazard_b;

end architecture gate_logic;
