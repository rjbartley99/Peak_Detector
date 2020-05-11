LIBRARY ieee; 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myRegister is 
port(
  clk: in std_logic;
  regreset: in std_logic;
  load: in std_logic;
  D: in std_logic_vector(7 downto 0);
  Q: out std_logic_vector(7 downto 0)
  );
end myRegister; 

ARCHITECTURE Behavioral of myRegister is

begin
    PROCESS(clk,regreset)
    begin
     if regreset ='1' then
     Q <="11111111";
     elsif rising_edge(clk) and load = '1' then 
       Q <= D;
     else 
       null;
     end if;
   end PROCESS;
end ;