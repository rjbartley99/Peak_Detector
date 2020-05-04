library ieee;

use ieee.std_logic_1164.all;
use work.common_pack.all;

entity shift is
    port (
        shift_in : in std_logic_vector(7 downto 0); -- DATA IN
        en_shift : in std_logic; -- CHIP ENABLE
        clk : in std_logic; -- CLOCK
        shift_out : out BCD_ARRAY_TYPE(2 downto 0); -- SHIFTER OUTPUT
        load_shift : in std_logic
        );
end shift;

architecture shift_arch of shift is
    
--SIGNALS
signal s_register : BCD_ARRAY_TYPE (2 downto 0); -- REGISTER CONTENTS


begin

--PROCESS : SHIFT
shift : process (clk,en_shift,load_shift)
begin
    if rising_edge(clk) and en_shift='1' then -- FULLY SYNCHRONOUS AND ENABLED
       for i in 2 downto 1 loop 
          s_register(i) <= s_register(i-1); -- SHIFT ALL BITS UP 1
       end loop;
          s_register(0) <= shift_in(3 downto 0);  -- INSERT DATA BIT IN LSB
    elsif rising_edge(clk) and load_shift ='1' then
          shift_out <= s_register; -- WRITE REGISTER CONTENTS TO OUTPUT;
    else null;
    end if;
    
end process;
end shift_arch;


