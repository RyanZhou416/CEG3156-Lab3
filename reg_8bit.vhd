library ieee;
use ieee.std_logic_1164.all;

entity reg_8bit is
	port(
		data_in : in std_logic_vector(7 downto 0);
		load_enable : in std_logic;
		GClock : in std_logic;
		GReset : in std_logic;
		data_out : out std_logic_vector(7 downto 0)
	);
end entity reg_8bit;

architecture structural of reg_8bit is

component reg_1bit is  
    port (  
        GClock      : in  std_logic;  
        GReset      : in  std_logic;  
        data_in     : in  std_logic;  
        load_enable : in  std_logic;  
        data_out    : out std_logic  
    );  
end component;


begin

gen_reg : for i in 7 downto 0 generate  
    reg_bit : reg_1bit  
        port map (  
            GClock      => GClock,  
            GReset      => GReset,  
            data_in     => data_in(i),  
            load_enable => load_enable,  
            data_out    => data_out(i)  
        );  
end generate gen_reg;


end architecture structural;