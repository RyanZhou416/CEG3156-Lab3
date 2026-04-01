library ieee;
use ieee.std_logic_1164.all;

entity reg_1bit is
 port(
	GClock, GReset, data_in, load_enable: in std_logic;
	data_out : out std_logic);
end entity reg_1bit;

architecture structural of reg_1bit is
	component mydff is 
		port(
			data_in, clk, reset : in std_logic;
			data_out : out std_logic);
	end component;
	
	component mux_2to1_1bit is
        port (
            data_in_0    : in  std_logic;
            data_in_1    : in  std_logic;
            sel_line     : in  std_logic;
            data_out     : out std_logic
        );
    end component;
	 signal mux_to_dff : std_logic;
	 signal dff_to_out : std_logic;
begin
	mux: mux_2to1_1bit
		port map(
			data_in_0 => dff_to_out,
			data_in_1 => data_in,
			sel_line => load_enable,
			data_out => mux_to_dff);
	dff: mydff
		port map(
			data_in => mux_to_dff,
			clk => GClock,
			reset => GReset,
			data_out => dff_to_out);
	data_out <= dff_to_out;
end architecture structural;
			
			