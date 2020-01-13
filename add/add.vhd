LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;

ENTITY add IS
	GENERIC(
		bw				: INTEGER RANGE 4 TO 32 := 16			-- bit width of the input and output
	);	
	PORT(
		clk				  : IN	STD_LOGIC;							  -- global clock
		reset_n			: IN	STD_LOGIC;							  -- global reset
		enable			: IN	STD_LOGIC;							  -- unit enable
		input_a			: IN	signed(bw - 1 DOWNTO 0);	-- summand when add is true or minuend when add is false (subtraction)
		input_b			: IN	signed(bw - 1 DOWNTO 0);	-- summand when add is true or subtrahend when add is false (subtraction)
		done			  : OUT	STD_LOGIC;
		result			: OUT	signed(bw - 1 DOWNTO 0);	-- result of the mathematical operation
		saturated		: OUT	STD_LOGIC							    -- output saturation is active
	);
END ENTITY RTL_Add_Sub_2;

ARCHITECTURE arc OF RTL_Add_Sub_2 IS
	
	CONSTANT upper_limit_signed		: SIGNED(bw - 1 DOWNTO 0)	:= NOT SHIFT_LEFT(to_signed(1,bw),bw-1);	-- "0111"
	CONSTANT lower_limit_signed		: SIGNED(bw - 1 DOWNTO 0)	:= SHIFT_LEFT(to_signed(1,bw),bw-1);		-- "1000"
	
BEGIN

	process_add : PROCESS(clk, reset_n)
		VARIABLE result_signed		: SIGNED(bw DOWNTO 0) := (OTHERS => '0');
	BEGIN
		IF (reset_n = '0') THEN
			done <= '0';
			-- SIGNALS
			result <= (OTHERS => '0');
			saturated <= '0';
			-- VARIABLES
			result_signed := (OTHERS => '0');
		ELSIF rising_edge(clk) THEN
			done <= '0';
			IF (enable = '1') THEN
				done <= '1';
				IF (add = true) THEN
					result_signed := resize((input_a), bw + 1) + resize((input_b), bw + 1); 
				ELSE
					result_signed := resize((input_a), bw + 1) - resize((input_b), bw + 1);
				END IF;
					IF ((result_signed(bw) = '0') AND (result_signed(bw-1) = '1')) THEN
						result <= (upper_limit_signed);
						saturated <= '1';
					ELSIF ((result_signed(bw) = '1') AND (result_signed(bw-1) = '0')) THEN
						result <= (lower_limit_signed);
						saturated <= '1';
					ELSE
						result <= (result_signed(bw - 1 DOWNTO 0));
						saturated <= '0';
					END IF;		
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE arc;

