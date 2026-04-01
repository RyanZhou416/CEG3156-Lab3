library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom32 is
    port (
        address : in  std_logic_vector(7 downto 0);
        clock   : in  std_logic := '1';
        q       : out std_logic_vector(31 downto 0)
    );
end entity rom32;

architecture behavioral of rom32 is
    type rom_array_t is array(0 to 63) of std_logic_vector(31 downto 0);
    constant ROM_DATA : rom_array_t := (
        16#00# => x"8C020000",
        16#04# => x"8C030001",
        16#08# => x"00430822",
        16#0C# => x"00232025",
        16#10# => x"AC040003",
        16#14# => x"00430820",
        16#18# => x"AC010004",
        16#1C# => x"8C020003",
        16#20# => x"8C030004",
        16#24# => x"0800000B",
        16#28# => x"1021FFF5",
        16#2C# => x"1022FFFE",
        16#30# => x"1021FFF7",
        others => x"00000000"
    );
begin
    q <= ROM_DATA(to_integer(unsigned(address(5 downto 0))));
end architecture behavioral;
