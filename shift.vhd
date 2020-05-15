----------------------------------------------------------------------------------
--
-- Engineer: Oscar Fuller and Will Myers
-- 
-- Create Date: 28.03.2020
-- Design Name: Shift Register 
-- Module Name: shift - Behavioral
-- Project Name: Peak Dectector -- Command Processor
-- Description: 3x4 Shift Register which loads the current number from the input sequence into the LSB and 
-- shift the prvious numbers to the left once until it has been filled with the 3 numbers in BCD format. It then has 
--a synchronous ouput with a load which is set high when it is ready to be sent to numwords.
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.common_pack.all;

entity shift is
    port (
        shift_in : in std_logic_vector(3 downto 0); -- DATA IN
        en_shift : in std_logic; -- CHIP ENABLE
        clk : in std_logic; -- CLOCK
        shift_out : out BCD_ARRAY_TYPE(2 downto 0); -- SHIFTER OUTPUT
        load_shift : in std_logic; --LOAD REGISTER TO OUTPUT
        shift_reset : in std_logic --ASYNCHRONOUS RESET
        );
end shift;

architecture Behavioral of shift is
    
--SIGNALS
signal s_register : BCD_ARRAY_TYPE (2 downto 0); -- REGISTER CONTENTS

begin

--PROCESS : SHIFT
shift : process (clk,shift_reset)
begin
    if shift_reset='1' then--ASYNCHRONOUS RESET
    s_register <= ("0000","0000","0000");
    elsif rising_edge(clk) and en_shift='1' then -- FULLY SYNCHRONOUS AND ENABLED
       for i in 2 downto 1 loop 
          s_register(i) <= s_register(i-1); -- SHIFT ALL BITS UP 1
       end loop;
          s_register(0) <= shift_in;  -- INSERT DATA BIT IN LSB
    end if;
    
end process;
shiftour : process (clk,shift_reset)
begin
if shift_reset='1' then
 shift_out <= ("1111","1111","1111");--SET NUMWORDS TO INITILASED VALUE --> (f,f,f)
elsif rising_edge(clk) and load_shift ='1' then
          shift_out <= s_register; -- WRITE REGISTER CONTENTS TO OUTPUT SYNCHRONOUSLY;
end if;
end process;
end Behavioral;


