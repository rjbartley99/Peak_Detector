----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.03.2020 11:39:07
-- Design Name: 
-- Module Name: shifter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity pipoShifter is
Port (clk : in STD_LOGIC;
         reset : in STD_LOGIC;
         data : in STD_LOGIC_VECTOR(7 downto 0);
         dout : out CHAR_ARRAY_TYPE(0 to 3));
end pipoShifter;


architecture Behavioural of pipoShifter is 
 
 
signal shift_reg : CHAR_ARRAY_TYPE(0 to 3); 
signal shift_in : CHAR_ARRAY_TYPE; 
signal enable : std_logic; 
begin 
process (clk) 
begin  
if rising_edge(clk) and enable='1' then   
shift_reg <= shift_in & shift_reg(0 to 2);  
end if;  

end process; 

end;
