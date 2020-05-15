----------------------------------------------------------------------------------
--
-- Engineer: Will Myers
-- 
-- Create Date: 05.4.2020 
-- Design Name: Format Look up table
-- Module Name: formatmux - Behavioral
-- Project Name: Peak Dectector -- Command Processor
-- Description: An ASCII look up table which uses the processors main counter component as an address.
-- This allows the table to be used to output different sequencs of symbols in the PuTTy comsole for formatting.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
--combinational process which outputs a specified character in ascii code dependent on the adrees which is connected 
--to the main counter
format_look : process (countIn)
begin
    CASE countIn is
       
          WHEN "000000" =>
       q1 <= "00100000";--SPACE
       
          WHEN "000001" => 
       q1 <= "00111101";--=    
          
          WHEN "000010" => 
       q1 <= "00111101";--= 
       
          WHEN "000011" =>
       q1 <= "00100000";--SPACE
       
          WHEN "000100" =>
       q1 <= "01011100";--\
           
          WHEN "000101" => 
       q1 <= "01110010";--r 
          
          WHEN "000110" =>
       q1 <= "01011100";--\
           
          WHEN "000111" => 
        q1 <= "01101110";--n
          
          WHEN others =>
         q1 <= "00100000";--SPACE
       
       end case;
end process format_look;

--sequential process to have the output opf the multiplexer clock driven to prevent glitching.
  PROCESS(clk)
    begin
     if rising_edge(clk)then 
       formatout <= q1;
     else 
       null;
     end if;
   end PROCESS;

end Behavioral;

