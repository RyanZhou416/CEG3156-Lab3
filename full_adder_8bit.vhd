library ieee;
use ieee.std_logic_1164.all;

entity full_adder_8bit is
    port (
        term_a      : in  std_logic_vector(7 downto 0);
        term_b      : in  std_logic_vector(7 downto 0);
        carry_in    : in  std_logic;
        sum_out     : out std_logic_vector(7 downto 0);
        carry_out   : out std_logic
    );
end entity full_adder_8bit;

architecture structural of full_adder_8bit is
    component full_adder_1bit is
        port(
            A, B, Cin : in  std_logic;
            Cout, S   : out std_logic
        );
    end component;
    
    signal carry_chain : std_logic_vector(8 downto 0);
    
begin
    carry_chain(0) <= carry_in;
    
    gen_adder: for i in 0 to 7 generate
        adder_bit: full_adder_1bit
            port map (
                A    => term_a(i),
                B    => term_b(i),
                Cin  => carry_chain(i),
                Cout => carry_chain(i + 1),
                S    => sum_out(i)
            );
    end generate gen_adder;
    
    carry_out <= carry_chain(8);
    
end architecture structural;
