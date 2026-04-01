Library ieee;
use ieee.std_logic_1164.all;

entity mydff is
	port(data_in, clk, reset : in std_logic;
		  data_out : out std_logic);
end entity mydff;

architecture behavior of mydff is
begin
	process(clk, reset)
	begin
		if reset = '1' then
			data_out <= '0';
		elsif rising_edge(clk) then
			data_out <= data_in;
		end if;
	end process;
end architecture behavior;
	