LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY debouncer IS
	PORT(
		i_raw			: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_clean			: OUT	STD_LOGIC);
END debouncer;

ARCHITECTURE fsm OF debouncer IS
	SIGNAL int_currentState, int_nextState : std_logic_vector (1 downto 0);

BEGIN

	int_nextState <= "00" when i_raw = '0' else
					 "01" when int_currentState = "00" else
					 "10";

	process(i_clock) begin
		if i_clock'event and i_clock = '1' then
			int_currentState <= int_nextState;
		end if;
	end process;

	o_clean <= '1' when int_currentState = "10" else 
			   '0';

END fsm;
