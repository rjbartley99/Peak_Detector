----------------------------------------------------------------------------------
--
-- Engineer: Oscar Fuller and Will Myers
-- 
-- Create Date: 06.05.2020 00:09:09
-- Design Name: Byte Look up table
-- Module Name: bytemux - Behavioral
-- Project Name: Peak Dectector -- Command Processor
-- Description: An ASCII look up table which uses either the upper or lower 4 bits of the byte line (depending
-- on which digit is being outputted) as the address. The hexadecimal number sent from byte is then outputted in
-- the apropriate ascii code.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity bytemux is
    Port ( 
        clk : in std_logic;
        data : in std_logic_vector(3 downto 0);
        loadDATA : in std_logic;
        q: out std_logic_vector(7 downto 0)
        );
end bytemux;

architecture mux of bytemux is
signal q1 : std_logic_vector(7 downto 0); 

begin

ascii_look : process (data)
begin
    CASE data is
          WHEN "0000" => 
       q1 <= "00110000";--0
          
          WHEN "0001" =>
       q1 <= "00110001";--1
           
          WHEN "0010" => 
       q1<= "00110010";--2
         
          WHEN "0011" =>
       q1 <= "00110011";--3
         
          WHEN "0100" =>
       q1 <= "00110100";--4
           
          WHEN "0101" => 
       q1 <= "00110101";--5
         
          WHEN "0110" =>
       q1 <= "00110110";--6
           
          WHEN "0111" => 
       q1 <= "00110111";--7
          
          WHEN "1000" =>
       q1 <= "00111000";--8
          
          WHEN "1001" =>
       q1 <= "00111001";--9
           
          WHEN "1010" => --A   
       q1 <= "01000001";
         
          WHEN "1011" => --B
       q1 <= "01000010";
           
          WHEN "1100" => --C
       q1 <= "01000011";
         
          WHEN "1101" => --D
       q1 <= "01000100";
          
          WHEN "1110" => --E
       q1 <= "01000101";
         
          WHEN "1111" => --F
       q1 <= "01000110"; 
                
           WHEN others =>
           null;
       end case;
end process ascii_look;

--sequential process to have the output opf the multiplexer clock driven to prevent glitching.
    PROCESS(clk)
    begin
     if rising_edge(clk) and  loadDATA = '1' then 
       q <= q1;
     else 
       null;
     end if;
   end PROCESS;

end mux;

