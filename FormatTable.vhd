----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.05.2020 00:09:09
-- Design Name: 
-- Module Name: FormatTable - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity formatmux is
    Port ( 
        clk : in std_logic;
        countIn : in std_logic_vector(5 downto 0);
        formatout: out std_logic_vector(7 downto 0)
        );
end formatmux;

architecture Behavioral of formatmux is
signal q1 : std_logic_vector(7 downto 0); 
begin

format_look : process (countIn)
begin
    CASE countIn is
       
          WHEN "000100" =>
       q1 <= "01011100";--\
           
          WHEN "000101" => 
       q1 <= "01101110";--n
         
          WHEN "000110" =>
       q1 <= "01011100";--\
           
          WHEN "000111" => 
       q1 <= "01110010";--r
          
          WHEN "001000" => 
       q1 <= "00111101";--=    
          
          WHEN "001001" => 
       q1 <= "00111101";--= 
          
          WHEN others =>
         q1 <= "00100000";
       
       end case;
end process format_look;

  PROCESS(clk)
    begin
     if rising_edge(clk)then 
       formatout <= q1;
     else 
       null;
     end if;
   end PROCESS;

end Behavioral;

