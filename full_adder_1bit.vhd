Library ieee;
use ieee.std_logic_1164.all;

entity full_adder_1bit is 
	port(A,B,Cin : in std_logic;
		  Cout,S : out std_logic);
end entity full_adder_1bit;

architecture gate_logic of full_adder_1bit is
	signal axorb: std_logic;
begin
	axorb <= a xor b;
	s <= axorb xor Cin;
	Cout <= (a and b) or (Cin and axorb);
end architecture gate_logic;