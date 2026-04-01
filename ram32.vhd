library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram32 is
    port (
        clock     : in  std_logic := '1';
        data      : in  std_logic_vector(31 downto 0);
        rdaddress : in  std_logic_vector(7 downto 0);
        wraddress : in  std_logic_vector(7 downto 0);
        wren      : in  std_logic := '0';
        q         : out std_logic_vector(31 downto 0)
    );
end entity ram32;

architecture behavioral of ram32 is
    type ram_array_t is array(0 to 7) of std_logic_vector(31 downto 0);
    signal memory : ram_array_t := (
        0 => x"00000055",
        1 => x"000000AA",
        others => x"00000000"
    );
begin

    process(clock)
    begin
        if rising_edge(clock) then
            if wren = '1' then
                memory(to_integer(unsigned(wraddress(2 downto 0)))) <= data;
            end if;
        end if;
    end process;

    q <= memory(to_integer(unsigned(rdaddress(2 downto 0))));

end architecture behavioral;
